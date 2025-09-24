function poolObj = setupParallelPool(parallel_opts)
% SETUPPARALLELPOOL Advanced parallel pool management
% Fixed for MATLAB R2025a compatibility

fprintf('\n=== PARALLEL POOL SETUP ===\n');

% Check if Parallel Computing Toolbox is available
if ~license('test', 'Distrib_Computing_Toolbox')
    error('Parallel Computing Toolbox is required for parallel execution');
end

% Get current pool status
currentPool = gcp('nocreate');

if ~isempty(currentPool)
    fprintf('Existing parallel pool found:\n');
    fprintf('  Type: %s\n', currentPool.Cluster.Type);
    fprintf('  Workers: %d\n', currentPool.NumWorkers);
    
    % FIXED: Remove the problematic State check for ProcessPool
    % Instead, just check if pool is connected and has workers
    try
        % Test if pool is functional by checking NumWorkers
        if currentPool.NumWorkers > 0
            fprintf('  Status: Active and functional\n');
            fprintf('Using existing pool.\n');
            poolObj = currentPool;
            return;
        else
            fprintf('  Status: Pool exists but no workers available\n');
            delete(currentPool);
            fprintf('Deleted inactive pool.\n');
        end
    catch
        % If any error occurs, delete and recreate
        delete(currentPool);
        fprintf('Deleted problematic pool.\n');
    end
end

% Determine optimal pool configuration
fprintf('Setting up new parallel pool...\n');

% Get available cluster profiles
profiles = parallel.clusterProfiles();
fprintf('Available cluster profiles: %s\n', strjoin(profiles, ', '));

% Determine best configuration for laptop execution
if parallel_opts.UseParallel
    % For laptop execution, prefer Processes profile
    if any(contains(profiles, 'Processes', 'IgnoreCase', true))
        cluster_profile = 'Processes';
        fprintf('Using Processes cluster profile (optimal for laptop)\n');
    elseif any(strcmp(profiles, 'local'))
        cluster_profile = 'local';
        fprintf('Using local cluster profile\n');
    else
        cluster_profile = profiles{1};
        fprintf('Using default cluster profile: %s\n', cluster_profile);
    end
    
    % Get cluster object
    cluster = parcluster(cluster_profile);
    
    % Determine optimal number of workers for laptop
    max_workers = cluster.NumWorkers;
    system_cores = feature('numcores');
    
    % For laptop execution, use fewer workers to avoid overloading
    if strcmp(cluster_profile, 'Processes')
        % For processes, use 75% of cores to leave room for OS
        optimal_workers = max(1, min(max_workers, floor(system_cores * 0.75)));
    else
        % For threads, can use more cores
        optimal_workers = min(max_workers, system_cores);
    end
    
    % Respect user preferences if specified
    if isfield(parallel_opts, 'NumWorkers') && ~isempty(parallel_opts.NumWorkers)
        requested_workers = parallel_opts.NumWorkers;
        optimal_workers = min(requested_workers, max_workers);
        fprintf('User requested %d workers, using %d\n', requested_workers, optimal_workers);
    end
    
    fprintf('System cores: %d | Cluster max: %d | Using: %d workers\n', ...
        system_cores, max_workers, optimal_workers);
    
    % Start the pool with error handling
    try
        fprintf('Starting parallel pool...\n');
        poolObj = parpool(cluster, optimal_workers);
        fprintf('Successfully started pool with %d workers\n', poolObj.NumWorkers);
        
        % Configure pool properties for optimization
        fprintf('Configuring pool settings...\n');
        
        % Set idle timeout (optional)
        if isfield(parallel_opts, 'IdleTimeout')
            poolObj.IdleTimeout = parallel_opts.IdleTimeout;
        end
        
        % Display final configuration
        fprintf('Pool configuration:\n');
        fprintf('  Cluster type: %s\n', poolObj.Cluster.Type);
        fprintf('  Workers: %d\n', poolObj.NumWorkers);
        fprintf('  Profile: %s\n', cluster_profile);
        
    catch ME
        warning(E.identifier,'Failed to start parallel pool: %s', ME.message);
        fprintf('Falling back to serial execution\n');
        poolObj = [];
    end
else
    fprintf('Parallel execution disabled by user options\n');
    poolObj = [];
end

if isempty(poolObj)
    % Create dummy pool object for serial execution
    poolObj = struct('NumWorkers', 1, 'Cluster', struct('Type', 'serial'));
    fprintf('Running in serial mode\n');
end
end
