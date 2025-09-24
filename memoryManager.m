classdef memoryManager < handle
    % MEMORYMANAGER Lightweight SSD-aware cache for large data in ABC runs.
    % FIXED VERSION with proper error handling
    
    properties (Access = private)
        cacheDir % disk folder
        ownsCacheDir = false
        maxMemoryMB % RAM quota
        currentMemoryMB = 0 % used RAM
        dataMap % containers.Map: key -> meta struct
    end
    
    methods
        %------------------------------------------------------------------%
        function obj = memoryManager(cacheDir, maxMemMB)
            if nargin < 1 || isempty(cacheDir)
                cacheDir = fullfile(pwd, 'mm_cache');
            end
            if nargin < 2 || isempty(maxMemMB)
                maxMemMB = 1024; % 1 GB default
            end
            
            if ~isfolder(cacheDir)
                mkdir(cacheDir);
                obj.ownsCacheDir = true;
            end
            
            obj.cacheDir = cacheDir;
            obj.maxMemoryMB = maxMemMB;
            obj.dataMap = containers.Map('KeyType','char','ValueType','any');
            
            fprintf('[memoryManager] Initialised | Cache: %s | Max-RAM: %.0f MB\n', ...
                obj.cacheDir, obj.maxMemoryMB);
        end
        
        %------------------------------------------------------------------%
        function store(obj, key, data, forceDisk)
            arguments
                obj
                key (1,:) char
                data
                forceDisk (1,1) logical = false
            end
            
            if isKey(obj.dataMap, key) % overwrite → first delete
                obj.remove(key);
            end
            
            try
                s = whos('data');
                sizeMB = s.bytes/1024^2;
            catch
                sizeMB = 1; % Default size if whos fails
            end
            
            if forceDisk || obj.currentMemoryMB + sizeMB > obj.maxMemoryMB
                try
                    fname = fullfile(obj.cacheDir,[key '.mat']);
                    save(fname,'data','-v7.3');
                    meta = struct('location','disk','file',fname,'sizeMB',sizeMB);
                    fprintf('[memoryManager] » %s -> SSD (%.2f MB)\n', key, sizeMB);
                catch ME
                    fprintf('[memoryManager] Warning: Failed to save %s to disk: %s\n', key, ME.message);
                    % Fall back to RAM storage
                    meta = struct('location','ram','payload',data,'sizeMB',sizeMB);
                    obj.currentMemoryMB = obj.currentMemoryMB + sizeMB;
                end
            else
                meta = struct('location','ram','payload',data,'sizeMB',sizeMB);
                obj.currentMemoryMB = obj.currentMemoryMB + sizeMB;
                fprintf('[memoryManager] » %s -> RAM (%.2f MB) | RAM used: %.2f/%.0f MB\n', ...
                    key, sizeMB, obj.currentMemoryMB, obj.maxMemoryMB);
            end
            
            obj.dataMap(key) = meta;
        end
        
        %------------------------------------------------------------------%
        function data = load(obj, key)
            if ~isKey(obj.dataMap, key)
                error('[memoryManager] Key "%s" not found.', key);
            end
            
            meta = obj.dataMap(key);
            
            try
                if strcmp(meta.location,'ram')
                    data = meta.payload;
                else
                    tmp = load(meta.file,'data');
                    data = tmp.data;
                end
            catch ME
                fprintf('[memoryManager] Warning: Failed to load %s: %s\n', key, ME.message);
                data = [];
            end
        end
        
        %------------------------------------------------------------------%
        function remove(obj, key)
            if ~isKey(obj.dataMap, key), return; end
            
            meta = obj.dataMap(key);
            
            try
                if strcmp(meta.location,'ram')
                    obj.currentMemoryMB = max(0, obj.currentMemoryMB - meta.sizeMB);
                else
                    if exist(meta.file,'file'), delete(meta.file); end
                end
                
                remove(obj.dataMap, key);
                fprintf('[memoryManager] « %s removed.\n', key);
            catch ME
                fprintf('[memoryManager] Warning: Failed to remove %s: %s\n', key, ME.message);
            end
        end
        
        %------------------------------------------------------------------%
        function cleanup(obj)
            try
                k = keys(obj.dataMap);
                for i = 1:numel(k)
                    meta = obj.dataMap(k{i});
                    if strcmp(meta.location,'ram')
                        obj.currentMemoryMB = max(0, obj.currentMemoryMB - meta.sizeMB);
                        remove(obj.dataMap, k{i});
                    end
                end
                fprintf('[memoryManager] RAM cache cleared. RAM now: %.2f MB\n', obj.currentMemoryMB);
            catch ME
                fprintf('[memoryManager] Warning: Cleanup failed: %s\n', ME.message);
            end
        end
        
        %------------------------------------------------------------------%
        function s = getStatus(obj)
            s.currentMemoryMB = obj.currentMemoryMB;
            s.maxMemoryMB = obj.maxMemoryMB;
            s.utilisationPercent = 100*obj.currentMemoryMB/obj.maxMemoryMB;
            s.numCachedItems = count(obj.dataMap);
            s.keys = keys(obj.dataMap);
            
            fprintf('\n[memoryManager] STATUS -------------------------------------------\n');
            fprintf(' RAM : %.2f / %.0f MB (%.1f%%)\n', ...
                s.currentMemoryMB, s.maxMemoryMB, s.utilisationPercent);
            fprintf(' Items : %d\n', s.numCachedItems);
            if s.numCachedItems, fprintf(' Keys : %s\n', strjoin(s.keys,', ')); end
            fprintf('------------------------------------------------------------------\n');
        end
        
        %------------------------------------------------------------------%
        function delete(obj)
            % Destructor - FIXED
            try
                if obj.ownsCacheDir
                    remaining = dir(obj.cacheDir);
                    remaining = remaining(~ismember({remaining.name},{'.','..'}));
                    if isempty(remaining)
                        rmdir(obj.cacheDir,'s');
                        fprintf('[memoryManager] Cache directory removed.\n');
                    else
                        fprintf('[memoryManager] Cache kept because files remain.\n');
                    end
                end
            catch ME
                warning(ME.identifier,'[memoryManager] Destructor cleanup failed: %s', ME.message);
            end
        end
    end
end
