function poolObj = setupMemoryOptimizedParallelPool(parallel_config, log_file)
% SETUPMEMORYOPTIMIZEDPARALLELPOOL Memory-safe parallel pool for laptops

fprintf('\n=== MEMORY-OPTIMIZED PARALLEL POOL SETUP ===\n');

% Check current pool
currentPool = gcp('nocreate');
if ~isempty(currentPool) && currentPool.NumWorkers > 0
    fprintf('Using existing pool: %d workers\n', currentPool.NumWorkers);
    logMessage(log_file, sprintf('Using existing pool: %d workers', currentPool.NumWorkers));
    poolObj = currentPool;
    return;
end

% Setup new pool with memory constraints
profiles = parallel.clusterProfiles();
if any(contains(profiles, 'Processes', 'IgnoreCase', true))
    cluster_profile = 'Processes';
else
    cluster_profile = 'local';
end

fprintf('Setting up %s cluster profile\n', cluster_profile);

try
    cluster = parcluster(cluster_profile);
    
    % Conservative worker count for laptop
    max_workers = cluster.NumWorkers;
    system_cores = feature('numcores');
    
    % For memory safety, use fewer workers
    optimal_workers = min(max_workers, max(1, floor(system_cores * 0.6))); % 60% of cores
    
    fprintf('Starting pool with %d workers (of %d available cores)\n', optimal_workers, system_cores);
    logMessage(log_file, sprintf('Starting pool: %d workers', optimal_workers));
    
    poolObj = parpool(cluster, optimal_workers);
    
    % Set conservative idle timeout
    poolObj.IdleTimeout = 60;
    
    fprintf('Pool started successfully: %d workers\n', poolObj.NumWorkers);
    logMessage(log_file, sprintf('Pool started: %d workers', poolObj.NumWorkers));
    
catch ME
    warning(E.identifier,'Failed to start parallel pool: %s', ME.message);
    logMessage(log_file, sprintf('Pool failed: %s', ME.message));
    poolObj = struct('NumWorkers', 1);
end

    function logMessage(log_file, message)
        fid = fopen(log_file, 'a');
        fprintf(fid, '[%s] %s\n', datestr(now, 'HH:MM:SS'), message);
        fclose(fid);
    end

end
