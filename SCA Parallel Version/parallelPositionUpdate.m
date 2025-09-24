function X_new = parallelPositionUpdate(X, Destination_position, r1, lb, ub, parallel_opts)
% PARALLELPOSITIONUPDATE Parallel implementation of SCA position updates
%
% This function performs the core SCA position update equations in parallel,
% distributing the computational load across available CPU cores.
%
% INPUTS:
%   X                   : Current agent positions (N x dim)
%   Destination_position: Best position found so far (1 x dim)
%   r1                  : SCA parameter (scalar)
%   lb, ub              : Lower and upper bounds (1 x dim)
%   parallel_opts       : Parallel processing options
%
% OUTPUT:
%   X_new               : Updated agent positions (N x dim)

[N, dim] = size(X);
X_new = zeros(size(X));

% Determine batch processing strategy
batch_size = min(parallel_opts.BatchSize, N);
num_batches = ceil(N / batch_size);

% Process agents in parallel batches
for batch = 1:num_batches
    start_idx = (batch-1) * batch_size + 1;
    end_idx = min(batch * batch_size, N);
    batch_indices = start_idx:end_idx;
    current_batch_size = length(batch_indices);
    
    % Extract current batch
    X_batch = X(batch_indices, :);
    
    % Parallel processing of current batch
    X_batch_new = zeros(current_batch_size, dim);
    
    parfor i = 1:current_batch_size
        % Generate random parameters for each agent
        r2 = 2 * pi * rand();
        r3 = 2 * rand();  
        r4 = rand();
        
        agent_pos = X_batch(i, :);
        new_pos = zeros(1, dim);
        
        % Apply SCA update equations for each dimension
        for j = 1:dim
            if r4 < 0.5
                % Sine-based update
                new_pos(j) = agent_pos(j) + r1 * sin(r2) * abs(r3 * Destination_position(j) - agent_pos(j));
            else  
                % Cosine-based update
                new_pos(j) = agent_pos(j) + r1 * cos(r2) * abs(r3 * Destination_position(j) - agent_pos(j));
            end
        end
        
        % Apply boundary constraints
        new_pos = max(min(new_pos, ub), lb);
        X_batch_new(i, :) = new_pos;
    end
    
    % Store updated batch
    X_new(batch_indices, :) = X_batch_new;
end
end
