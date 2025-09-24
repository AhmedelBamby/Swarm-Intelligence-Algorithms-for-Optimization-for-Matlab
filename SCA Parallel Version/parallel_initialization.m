function Positions = parallel_initialization(SearchAgents_no, dim, ub, lb, poolObj)
% PARALLEL_INITIALIZATION Enhanced parallel population initialization
%
% This function creates the initial population in parallel, ensuring
% proper distribution across the search space and efficient memory usage.
%
% INPUTS:
%   SearchAgents_no : Number of search agents
%   dim            : Problem dimension
%   ub, lb         : Upper and lower bounds
%   poolObj        : Parallel pool object
%
% OUTPUT:
%   Positions      : Initial agent positions (SearchAgents_no x dim)

fprintf('\n=== PARALLEL POPULATION INITIALIZATION ===\n');
fprintf('Agents: %d | Dimensions: %d | Workers: %d\n', SearchAgents_no, dim, poolObj.NumWorkers);

% Display boundary information
fprintf('Boundary conditions:\n');
if length(ub) == 1
    fprintf('  Uniform bounds: [%.4f, %.4f]\n', lb, ub);
else
    fprintf('  Variable bounds:\n');
    for i = 1:min(5, dim)
        fprintf('    Dim %2d: [%.4f, %.4f]\n', i, lb(i), ub(i));
    end
    if dim > 5
        fprintf('    ... (%d total dimensions)\n', dim);
    end
end

% Pre-allocate positions matrix
Positions = zeros(SearchAgents_no, dim);

% Determine parallel processing strategy
workers_available = poolObj.NumWorkers;
batch_size = ceil(SearchAgents_no / workers_available);

% Parallel initialization with proper random seeding
fprintf('Initializing in parallel batches...\n');

parfor worker = 1:workers_available
    % Calculate agent range for this worker
    start_agent = (worker-1) * batch_size + 1;
    end_agent = min(worker * batch_size, SearchAgents_no);
    
    if start_agent <= SearchAgents_no
        % Initialize random seed for reproducibility (optional)
        rng(worker + 1000); % Unique seed per worker
        
        % Generate positions for this worker's batch
        num_agents = end_agent - start_agent + 1;
        worker_positions = zeros(num_agents, dim);
        
        if length(ub) == 1
            % Uniform bounds case
            worker_positions = rand(num_agents, dim) .* (ub - lb) + lb;
        else
            % Variable-specific bounds case
            for d = 1:dim
                worker_positions(:, d) = rand(num_agents, 1) .* (ub(d) - lb(d)) + lb(d);
            end
        end
        
        % Store in main matrix (this will be combined after parfor)
        temp_positions{worker} = {start_agent:end_agent, worker_positions};
    else
        temp_positions{worker} = {[], []};
    end
end

% Combine results from all workers
fprintf('Combining results from parallel workers...\n');
for worker = 1:workers_available
    if ~isempty(temp_positions{worker}{1})
        indices = temp_positions{worker}{1};
        positions = temp_positions{worker}{2};
        Positions(indices, :) = positions;
    end
end

% Validation and reporting
fprintf('Initialization validation:\n');
if any(isnan(Positions(:))) || any(isinf(Positions(:)))
    error('Invalid positions detected (NaN or Inf)');
end

% Verify bounds compliance
for d = 1:dim
    lb_val = lb(min(d, length(lb)));
    ub_val = ub(min(d, length(ub)));
    
    if any(Positions(:,d) < lb_val) || any(Positions(:,d) > ub_val)
        warning('Boundary violations detected in dimension %d', d);
    end
end

% Display sample positions
fprintf('Sample initial positions:\n');
sample_count = min(3, SearchAgents_no);
for agent = 1:sample_count
    pos_str = sprintf('%.4f ', Positions(agent, 1:min(5, dim)));
    if dim > 5
        pos_str = [pos_str '...'];
    end
    fprintf('  Agent %2d: [%s]\n', agent, pos_str);
end

fprintf('Parallel initialization completed successfully.\n');
fprintf('Final population size: %d x %d\n', size(Positions, 1), size(Positions, 2));
end
