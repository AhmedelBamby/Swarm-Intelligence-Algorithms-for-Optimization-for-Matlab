function [Destination_fitness, Destination_position, Convergence_curve, all_agent_history] = SCA(N, Max_iteration, lb, ub, dim, fobj, varargin)
% SCA Sine Cosine Algorithm for optimization problems
%
% Enhanced version with:
% - Robust progress bar handling
% - Complete documentation
% - Improved error handling
% - Optimized performance
%
% INPUTS:
%   N               : Number of search agents (population size)
%   Max_iteration   : Maximum number of iterations
%   lb              : Lower bounds (1 x dim vector)
%   ub              : Upper bounds (1 x dim vector)
%   dim             : Problem dimension
%   fobj            : Objective function handle
%   varargin        : Optional parameters [a, bw, PAR]
%
% OUTPUTS:
%   Destination_fitness    : Best fitness value found
%   Destination_position   : Best solution position
%   Convergence_curve      : Array of best fitness values
%   all_agent_history      : All agent positions (N x dim x iterations)
%
% USAGE EXAMPLE:
%   [best_fitness, best_pos] = SCA(30, 100, [-10 -10], [10 10], 2, @sphere);
%
% VERSION: 2.1
% DATE: 2023-11-15
% AUTHOR: Eng.Ahmed ElBamby

    %% Initialization
    fprintf('\n=== SCA INITIALIZATION ===\n');
    
    % Validate inputs
    validateattributes(N, {'numeric'}, {'scalar', 'integer', 'positive'});
    validateattributes(Max_iteration, {'numeric'}, {'scalar', 'integer', 'positive'});
    validateattributes(lb, {'numeric'}, {'vector'});
    validateattributes(ub, {'numeric'}, {'vector'});
    validateattributes(dim, {'numeric'}, {'scalar', 'integer', 'positive'});
    validateattributes(fobj, {'function_handle'}, {});
    
    % Initialize progress bar with error handling
    try
        progressBar = waitbar(0, 'Initializing SCA...', 'Name', 'SCA Progress', ...
            'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
        setappdata(progressBar, 'canceling', 0);
        progressActive = true;
    catch
        progressActive = false;
        warning('Progress bar initialization failed. Running in console mode.');
    end
    
    %% Nested helper functions
    function updateProgress(progress, message)
        % Safe progress bar update with error handling
        if progressActive && ishandle(progressBar)
            try
                waitbar(min(max(progress,0),1), progressBar, message);
            catch
                progressActive = false;
            end
        end
    end
    
    function str = formatAgentInfo(position, fitness)
        % Format agent information for display
        str = sprintf('Position: %s | Fitness: %.4e', mat2str(position,4), fitness);
    end
    
    function cleanUp()
        % Ensure proper cleanup of resources
        if progressActive && ishandle(progressBar)
            close(progressBar);
            drawnow;
        end
    end

    %% Algorithm Setup
    all_agent_history = zeros(N, dim, Max_iteration);
    
    % Display parameters
    paramInfo = {
        'Search agents', N
        'Maximum iterations', Max_iteration
        'Lower bounds', mat2str(lb,3)
        'Upper bounds', mat2str(ub,3)
        'Problem dimension', dim
    };
    
    fprintf('\n=== ALGORITHM PARAMETERS ===\n');
    for i = 1:size(paramInfo,1)
        fprintf('%-25s: %s\n', paramInfo{i,1}, string(paramInfo{i,2}));
    end
    
    % Handle optional parameters
    if nargin > 6
        params = varargin(1:min(3,numel(varargin)));
        [a, bw, PAR] = deal(params{:});
        tuned_mode = true;
        fprintf('\n%-25s: %s\n', 'Tuned mode', 'Enabled');
        fprintf('%-25s: %.2f\n', 'Parameter a', a);
        fprintf('%-25s: %.3f\n', 'Parameter bw', bw);
        fprintf('%-25s: %.2f\n', 'Parameter PAR', PAR);
    else
        a = 2; bw = 0.1; PAR = 0.95; tuned_mode = false;
        fprintf('\n%-25s: %s\n', 'Standard mode', 'Using default parameters');
    end

    %% Algorithm Execution
    try
        % Initial population
        updateProgress(0.1, 'Initializing population...');
        X = initialization(N, dim, ub, lb);
        all_agent_history(:,:,1) = X;
        
        % Initialize tracking variables
        Destination_position = zeros(1,dim);
        Destination_fitness = inf;
        Convergence_curve = zeros(1, Max_iteration);
        Objective_values = zeros(N,1);
        
        % Main optimization loop
        for t = 1:Max_iteration
            % Check for cancellation
            if progressActive && getappdata(progressBar, 'canceling')
                cleanUp();
                error('Operation canceled by user');
            end
            
            % Store current positions
            all_agent_history(:,:,t) = X;
            
            % Update positions
            r1 = a - t*(a/Max_iteration);
            for i = 1:N
                r2 = 2*pi*rand();
                r3 = 2*rand();
                r4 = rand();
                
                for j = 1:dim
                    if r4 < 0.5
                        X(i,j) = X(i,j) + r1*sin(r2)*abs(r3*Destination_position(j)-X(i,j));
                    else
                        X(i,j) = X(i,j) + r1*cos(r2)*abs(r3*Destination_position(j)-X(i,j));
                    end
                end
                
                % Apply bounds
                X(i,:) = min(max(X(i,:), lb), ub);
                
                % Evaluate
                try
                    Objective_values(i) = fobj(X(i,:));
                    if Objective_values(i) < Destination_fitness
                        Destination_position = X(i,:);
                        Destination_fitness = Objective_values(i);
                    end
                catch ME
                    warning(ME.identifier,'Evaluation failed: %s', ME.message);
                    Objective_values(i) = inf;
                end
            end
            
            % Update convergence curve
            Convergence_curve(t) = Destination_fitness;
            
            % Update progress (every 10 iterations or at boundaries)
            if mod(t,ceil(Max_iteration/10)) == 0 || t == 1 || t == Max_iteration
                updateProgress(t/Max_iteration, sprintf('Iteration %d/%d', t, Max_iteration));
            end
        end
        
        %% Finalization
        updateProgress(1, 'Optimization complete!');
        fprintf('\n=== OPTIMIZATION COMPLETED ===\n');
        fprintf('Best fitness: %.6e\n', Destination_fitness);
        fprintf('Best position: %s\n', mat2str(Destination_position,5));
        
    catch ME
        cleanUp();
        rethrow(ME);
    end
    
    cleanUp();
end