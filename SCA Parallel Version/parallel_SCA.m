function [Destination_fitness, Destination_position, Convergence_curve, all_agent_history] = parallel_SCA(N, Max_iteration, lb, ub, dim, fobj, varargin)
% PARALLEL_SCA Enhanced Sine Cosine Algorithm with Parallel Processing
%
% This implementation provides:
% - Full parallel evaluation of objective functions
% - Support for process cluster profiles
% - Dynamic load balancing across CPU cores
% - Memory-efficient agent history tracking
% - Real-time convergence monitoring
% - Robust error handling for parallel environments
%
% INPUTS:
%   N             : Number of search agents (population size)
%   Max_iteration : Maximum number of iterations  
%   lb            : Lower bounds (1 x dim vector)
%   ub            : Upper bounds (1 x dim vector)
%   dim           : Problem dimension
%   fobj          : Objective function handle
%   varargin      : Optional parameters [a, bw, PAR, parallel_options]
%
% OUTPUTS:
%   Destination_fitness  : Best fitness value found
%   Destination_position : Best solution position
%   Convergence_curve    : Array of best fitness values per iteration
%   all_agent_history    : Complete agent position history (N x dim x iterations)
%
% USAGE EXAMPLES:
%   % Basic parallel execution
%   [best_fit, best_pos] = parallel_SCA(50, 100, [-10 -10], [10 10], 2, @F1);
%   
%   % With custom parameters and parallel options
%   parallel_opts = struct('UseParallel', true, 'BatchSize', 10);
%   [best_fit, best_pos] = parallel_SCA(100, 200, lb, ub, 4, @F1, 2, 0.05, 0.7, parallel_opts);
%
% PARALLEL REQUIREMENTS:
%   - Parallel Computing Toolbox
%   - Active parallel pool or cluster profile
%
% VERSION: 3.0 - Full Parallel Implementation
% DATE: 2025-08-14
% AUTHOR: Enhanced for Parallel Processing

%% Input Validation and Setup
fprintf('\n=== PARALLEL SCA INITIALIZATION ===\n');
fprintf('Timestamp: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

% Validate required inputs
validateattributes(N, {'numeric'}, {'scalar', 'integer', 'positive'});
validateattributes(Max_iteration, {'numeric'}, {'scalar', 'integer', 'positive'});
validateattributes(lb, {'numeric'}, {'vector'});
validateattributes(ub, {'numeric'}, {'vector'});
validateattributes(dim, {'numeric'}, {'scalar', 'integer', 'positive'});

% Ensure bounds are compatible
if length(lb) == 1, lb = repmat(lb, 1, dim); end
if length(ub) == 1, ub = repmat(ub, 1, dim); end
assert(length(lb) == dim && length(ub) == dim, 'Bounds must match problem dimension');

% In the parallel_SCA.m function, replace the pool setup section with:

%% Parallel Environment Setup
parallel_opts = struct('UseParallel', true, 'BatchSize', min(N, 20), 'PreferSpmd', false);

% Parse optional parameters (existing code)
if nargin >= 7, a = varargin{1}; else, a = 2; end
if nargin >= 8, bw = varargin{2}; else, bw = 0.1; end  
if nargin >= 9, PAR = varargin{3}; else, PAR = 0.95; end
if nargin >= 10 && isstruct(varargin{4})
    user_opts = varargin{4};
    parallel_opts = mergeStructs(parallel_opts, user_opts);
end

% Setup parallel pool with corrected validation
try
    poolObj = setupParallelPool(parallel_opts);
    
    % FIXED: Properly check if pool is a real parallel pool object
    if isa(poolObj, 'parallel.Pool') && poolObj.NumWorkers > 1
        fprintf('Parallel pool active: %d workers\n', poolObj.NumWorkers);
    elseif isobject(poolObj) && isprop(poolObj, 'NumWorkers') && poolObj.NumWorkers > 1
        fprintf('Parallel pool active: %d workers\n', poolObj.NumWorkers);
    else
        fprintf('Serial execution mode activated\n');
        poolObj = struct('NumWorkers', 1);
    end
catch ME
    warning(E.identifier,'Parallel setup failed: %s. Running in serial mode.', ME.message);
    poolObj = struct('NumWorkers', 1);
end
%% Parallel Environment Setup
parallel_opts = struct('UseParallel', true, 'BatchSize', min(N, 20), 'PreferSpmd', false);

% Parse optional parameters (existing code stays the same)
if nargin >= 7, a = varargin{1}; else, a = 2; end
if nargin >= 8, bw = varargin{2}; else, bw = 0.1; end  
if nargin >= 9, PAR = varargin{3}; else, PAR = 0.95; end
if nargin >= 10 && isstruct(varargin{4})
    user_opts = varargin{4};
    parallel_opts = mergeStructs(parallel_opts, user_opts);
end

% Setup parallel pool with improved error handling
try
    poolObj = setupParallelPool(parallel_opts);
    if isstruct(poolObj) && isfield(poolObj, 'NumWorkers')
        fprintf('Parallel environment ready: %d workers\n', poolObj.NumWorkers);
    else
        fprintf('Serial execution mode activated\n');
        poolObj = struct('NumWorkers', 1);
    end
catch ME
    warning(E.identifier,'Parallel setup failed: %s. Running in serial mode.', ME.message);
    poolObj = struct('NumWorkers', 1);
end


%% Initialize Progress Tracking
try
    progressBar = waitbar(0, 'Initializing Parallel SCA...', 'Name', 'Parallel SCA Progress');
    progressActive = true;
catch
    progressActive = false;
    warning('Progress bar unavailable - using console output');
end

%% Algorithm Parameters Display
fprintf('\n=== ALGORITHM CONFIGURATION ===\n');
fprintf('Population size (N): %d\n', N);
fprintf('Maximum iterations: %d\n', Max_iteration);
fprintf('Problem dimension: %d\n', dim);
fprintf('Lower bounds: %s\n', mat2str(lb, 3));
fprintf('Upper bounds: %s\n', mat2str(ub, 3));
fprintf('SCA parameter a: %.3f\n', a);
fprintf('Bandwidth bw: %.4f\n', bw);
fprintf('PAR parameter: %.3f\n', PAR);
fprintf('Batch size: %d\n', parallel_opts.BatchSize);

%% Memory Pre-allocation
all_agent_history = zeros(N, dim, Max_iteration, 'single'); % Use single precision for memory efficiency
Convergence_curve = zeros(1, Max_iteration);
Destination_position = zeros(1, dim);
Destination_fitness = inf;

%% Population Initialization
updateProgress(0.05, 'Initializing population...');
X = parallel_initialization(N, dim, ub, lb, poolObj);
all_agent_history(:, :, 1) = X;

% Initial parallel evaluation
updateProgress(0.1, 'Initial population evaluation...');
Objective_values = parallelEvaluate(X, fobj, parallel_opts);

% Find initial best solution
[Destination_fitness, best_idx] = min(Objective_values);
Destination_position = X(best_idx, :);
Convergence_curve(1) = Destination_fitness;

fprintf('Initial best fitness: %.6e\n', Destination_fitness);

%% Main Optimization Loop
fprintf('\n=== STARTING PARALLEL OPTIMIZATION ===\n');
start_time = tic;

try
    for t = 2:Max_iteration
        % Update SCA parameter
        r1 = a - (t-1) * (a / Max_iteration);
        
        % Parallel position update
        updateProgress((t-1)/Max_iteration, sprintf('Iteration %d/%d - Updating positions...', t, Max_iteration));
        X = parallelPositionUpdate(X, Destination_position, r1, lb, ub, parallel_opts);
        
        % Store positions
        all_agent_history(:, :, t) = X;
        
        % Parallel evaluation
        updateProgress((t-0.5)/Max_iteration, sprintf('Iteration %d/%d - Evaluating fitness...', t, Max_iteration));
        Objective_values = parallelEvaluate(X, fobj, parallel_opts);
        
        % Update best solution
        [current_best, best_idx] = min(Objective_values);
        if current_best < Destination_fitness
            Destination_fitness = current_best;
            Destination_position = X(best_idx, :);
        end
        
        Convergence_curve(t) = Destination_fitness;
        
        % Progress reporting (every 10% or significant improvement)
        if mod(t, ceil(Max_iteration/10)) == 0
            elapsed = toc(start_time);
            remaining = elapsed * (Max_iteration - t) / t;
            fprintf('Iteration %d/%d | Best: %.6e | Elapsed: %.1fs | ETA: %.1fs\n', ...
                t, Max_iteration, Destination_fitness, elapsed, remaining);
        end
    end
    
catch ME
    warning(E.identifier,'Optimization interrupted: %s', ME.message);
end

%% Finalization
total_time = toc(start_time);
updateProgress(1, 'Optimization complete!');

fprintf('\n=== PARALLEL OPTIMIZATION COMPLETED ===\n');
fprintf('Total execution time: %.2f seconds\n', total_time);
fprintf('Final best fitness: %.8e\n', Destination_fitness);
fprintf('Final best position: %s\n', mat2str(Destination_position, 6));
fprintf('Average time per iteration: %.3f seconds\n', total_time/Max_iteration);

% Cleanup
if progressActive && ishandle(progressBar)
    close(progressBar);
end

%% Nested Helper Functions
    function updateProgress(progress, message)
        if progressActive && ishandle(progressBar)
            try
                waitbar(progress, progressBar, message);
            catch
                progressActive = false;
            end
        end
    end

    function merged = mergeStructs(struct1, struct2)
        merged = struct1;
        fields = fieldnames(struct2);
        for i = 1:length(fields)
            merged.(fields{i}) = struct2.(fields{i});
        end
    end
end
