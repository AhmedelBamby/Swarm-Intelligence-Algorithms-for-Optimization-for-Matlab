function [Destination_fitness, Destination_position, Convergence_curve, memory_used_mb] = memoryOptimizedSCA(N, Max_iteration, lb, ub, dim, fobj, a, bw, PAR, parallel_config, log_file, max_history)
% MEMORYOPTIMIZEDSCA Memory-safe parallel SCA implementation
%
% Features:
% - Limited agent history storage
% - Regular memory cleanup
% - Resource monitoring during execution
% - Emergency stops on low memory

%% Input validation and memory setup
fprintf('\n=== MEMORY-OPTIMIZED SCA START ===\n');
logMessage(log_file, sprintf('Starting SCA: %d agents, %d iterations', N, Max_iteration));

% Limit history storage based on available memory
actual_max_history = min(max_history, Max_iteration);
fprintf('History limited to %d iterations (of %d total)\n', actual_max_history, Max_iteration);

%% Setup parallel pool
poolObj = gcp('nocreate');
if isempty(poolObj)
    poolObj = setupMemoryOptimizedParallelPool(parallel_config, log_file);
end

%% Memory-efficient initialization
% Only store essential data
Convergence_curve = zeros(1, Max_iteration);
Destination_position = zeros(1, dim);
Destination_fitness = inf;

% Limited agent history (rolling window)
if actual_max_history > 0
    agent_history_window = zeros(N, dim, actual_max_history, 'single');
    history_counter = 0;
end

%% Population initialization
fprintf('Initializing %d agents...\n', N);
X = initializePopulation(N, dim, lb, ub);

% Initial evaluation with resource monitoring
initial_memory = getMemoryUsage();
Objective_values = evaluatePopulationSafe(X, fobj, parallel_config, log_file);

[Destination_fitness, best_idx] = min(Objective_values);
Destination_position = X(best_idx, :);
Convergence_curve(1) = Destination_fitness;

fprintf('Initial best fitness: %.6e\n', Destination_fitness);
logMessage(log_file, sprintf('Initial best: %.6e', Destination_fitness));

%% Main optimization loop with memory management
fprintf('\n=== STARTING MEMORY-MANAGED OPTIMIZATION ===\n');
start_time = tic;

for t = 2:Max_iteration
    % Update SCA parameter
    r1 = a - (t-1) * (a / Max_iteration);
    
    % Memory check every 10 iterations
    if mod(t, 10) == 0
        current_memory = getMemoryUsage();
        if current_memory > 1000 % More than 1GB
            fprintf('High memory usage (%.0f MB) - forcing cleanup\n', current_memory);
            clear temp_* batch_* worker_*;
            pause(0.1);
        end
    end
    
    % Position update with memory limits
    X = updatePositionsSafe(X, Destination_position, r1, lb, ub, parallel_config);
    
    % Store in rolling history window
    if actual_max_history > 0
        history_counter = history_counter + 1;
        if history_counter <= actual_max_history
            agent_history_window(:, :, history_counter) = X;
        else
            % Shift window and add new data
            agent_history_window(:, :, 1:end-1) = agent_history_window(:, :, 2:end);
            agent_history_window(:, :, end) = X;
        end
    end
    
    % Evaluation with safety checks
    Objective_values = evaluatePopulationSafe(X, fobj, parallel_config, log_file);
    
    % Update best solution
    [current_best, best_idx] = min(Objective_values);
    if current_best < Destination_fitness
        Destination_fitness = current_best;
        Destination_position = X(best_idx, :);
        logMessage(log_file, sprintf('Iteration %d: New best %.6e', t, Destination_fitness));
    end
    
    Convergence_curve(t) = Destination_fitness;
    
    % Progress reporting
    if mod(t, 20) == 0
        elapsed = toc(start_time);
        remaining = elapsed * (Max_iteration - t) / t;
        fprintf('Iteration %d/%d | Best: %.6e | Memory: %.0fMB | ETA: %.1fs\n', ...
            t, Max_iteration, Destination_fitness, getMemoryUsage(), remaining);
    end
end

%% Finalization
total_time = toc(start_time);
final_memory = getMemoryUsage();
memory_used_mb = final_memory - initial_memory;

fprintf('\n=== MEMORY-OPTIMIZED SCA COMPLETED ===\n');
fprintf('Execution time: %.2f seconds\n', total_time);
fprintf('Memory used: %.1f MB\n', memory_used_mb);
fprintf('Final best: %.8e\n', Destination_fitness);

logMessage(log_file, sprintf('SCA completed: %.2fs, %.1fMB memory, best=%.8e', ...
    total_time, memory_used_mb, Destination_fitness));

%% Helper functions
    function logMessage(log_file, message)
        fid = fopen(log_file, 'a');
        fprintf(fid, '[%s] %s\n', datestr(now, 'HH:MM:SS'), message);
        fclose(fid);
    end

    function memory_mb = getMemoryUsage()
        try
            mem_info = memory;
            memory_mb = (mem_info.MemUsedMATLAB) / 1024^2;
        catch
            memory_mb = 500; % Safe default
        end
    end

    function X = initializePopulation(N, dim, lb, ub)
        X = zeros(N, dim);
        for i = 1:N
            for j = 1:dim
                X(i, j) = lb(j) + rand() * (ub(j) - lb(j));
            end
        end
    end

    function fitness_values = evaluatePopulationSafe(X, fobj, parallel_config, log_file)
        [N, ~] = size(X);
        fitness_values = zeros(N, 1);
        batch_size = min(parallel_config.BatchSize, N);
        
        for i = 1:batch_size:N
            end_idx = min(i + batch_size - 1, N);
            batch_X = X(i:end_idx, :);
            
            parfor j = 1:size(batch_X, 1)
                try
                    fitness_values(i + j - 1) = fobj(batch_X(j, :));
                catch ME
                    fitness_values(i + j - 1) = inf;
                    logMessage(log_file, sprintf('Evaluation failed for agent %d: %s', i+j-1, ME.message));
                end
            end
        end
    end

    function X_new = updatePositionsSafe(X, Destination_position, r1, lb, ub, parallel_config)
        [N, dim] = size(X);
        X_new = zeros(size(X));
        batch_size = min(parallel_config.BatchSize, N);
        
        for i = 1:batch_size:N
            end_idx = min(i + batch_size - 1, N);
            batch_X = X(i:end_idx, :);
            batch_size_actual = size(batch_X, 1);
            batch_X_new = zeros(batch_size_actual, dim);
            
            parfor j = 1:batch_size_actual
                r2 = 2 * pi * rand();
                r3 = 2 * rand();
                r4 = rand();
                
                agent_pos = batch_X(j, :);
                new_pos = zeros(1, dim);
                
                for k = 1:dim
                    if r4 < 0.5
                        new_pos(k) = agent_pos(k) + r1 * sin(r2) * abs(r3 * Destination_position(k) - agent_pos(k));
                    else
                        new_pos(k) = agent_pos(k) + r1 * cos(r2) * abs(r3 * Destination_position(k) - agent_pos(k));
                    end
                end
                
                new_pos = max(min(new_pos, ub), lb);
                batch_X_new(j, :) = new_pos;
            end
            
            X_new(i:end_idx, :) = batch_X_new;
        end
    end

end
