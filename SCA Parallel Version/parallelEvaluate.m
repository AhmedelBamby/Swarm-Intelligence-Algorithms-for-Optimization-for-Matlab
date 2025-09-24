function fitness_values = parallelEvaluate(X, fobj, parallel_opts)
% PARALLELEVALUATE Parallel objective function evaluation
%
% This function evaluates the objective function for all agents in parallel,
% with robust error handling and load balancing.
%
% INPUTS:
%   X             : Agent positions (N x dim)
%   fobj          : Objective function handle
%   parallel_opts : Parallel processing options
%
% OUTPUT:
%   fitness_values: Fitness values for all agents (N x 1)

[N, ~] = size(X);
fitness_values = zeros(N, 1);

% Determine optimal batch size based on problem complexity
batch_size = min(parallel_opts.BatchSize, N);
num_batches = ceil(N / batch_size);

fprintf('  Evaluating %d agents in %d parallel batches...\n', N, num_batches);

% Process in parallel batches for memory efficiency
for batch = 1:num_batches
    start_idx = (batch-1) * batch_size + 1;
    end_idx = min(batch * batch_size, N);
    batch_indices = start_idx:end_idx;
    current_batch_size = length(batch_indices);
    
    % Extract current batch
    X_batch = X(batch_indices, :);
    batch_fitness = zeros(current_batch_size, 1);
    
    % Parallel evaluation of current batch
    parfor i = 1:current_batch_size
        try
            batch_fitness(i) = fobj(X_batch(i, :));
        catch ME
            warning('Evaluation failed for agent %d in batch %d: %s', i, batch, ME.message);
            batch_fitness(i) = inf; % Assign worst possible fitness
        end
    end
    
    % Store batch results
    fitness_values(batch_indices) = batch_fitness;
end

% Report evaluation statistics
valid_evals = sum(isfinite(fitness_values));
fprintf('  Completed: %d/%d valid evaluations\n', valid_evals, N);

if valid_evals < N
    warning('%d agents received invalid fitness values', N - valid_evals);
end
end
