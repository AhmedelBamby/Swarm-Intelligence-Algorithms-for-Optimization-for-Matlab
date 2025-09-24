function Positions = initialization(SearchAgents_no, dim, ub, lb)
% ======================================================================
% ENHANCED POPULATION INITIALIZATION FUNCTION
% Features:
%   - Detailed initialization logging
%   - Boundary condition verification
%   - Agent position reporting
%   - Compatible with SCA optimization framework
% Eng.Ahmed ElBamby
% ======================================================================

fprintf('\n=== INITIALIZING SEARCH AGENTS ===\n');
fprintf('Number of agents: %d\n', SearchAgents_no);
fprintf('Problem dimension: %d\n', dim);

Boundary_no = size(ub, 2); % Number of boundaries

% Display boundary information
fprintf('Boundary conditions:\n');
if Boundary_no == 1
    fprintf('  Uniform bounds for all dimensions:\n');
    fprintf('    Lower: %.4f\n', lb);
    fprintf('    Upper: %.4f\n', ub);
else
    fprintf('  Variable-specific bounds:\n');
    for i = 1:min(5, dim) % Display first 5 dimensions for brevity
        fprintf('    Dim %2d: [%.4f, %.4f]\n', i, lb(i), ub(i));
    end
    if dim > 5
        fprintf('    ... (showing first 5 of %d dimensions)\n', dim);
    end
end

% Initialize positions based on boundary conditions
if Boundary_no == 1
    % Uniform bounds case
    Positions = rand(SearchAgents_no, dim) .* (ub - lb) + lb;
    fprintf('Initialized with uniform bounds\n');
else
    % Variable-specific bounds case
    Positions = zeros(SearchAgents_no, dim);
    for i = 1:dim
        ub_i = ub(i);
        lb_i = lb(i);
        Positions(:, i) = rand(SearchAgents_no, 1) .* (ub_i - lb_i) + lb_i;
    end
    fprintf('Initialized with variable-specific bounds\n');
end

% Display sample agent positions
fprintf('\nSample agent positions (first 3 agents):\n');
for agent = 1:min(3, SearchAgents_no)
    fprintf('Agent %2d: [', agent);
    for d = 1:min(5, dim) % Show first 5 dimensions
        fprintf('%.4f', Positions(agent, d));
        if d < min(5, dim), fprintf(', '); end
    end
    if dim > 5, fprintf(', ...]'); else fprintf(']'); end
    fprintf('\n');
end

% Verify initialization
if any(isnan(Positions(:))) || any(isinf(Positions(:)))
    warning('Initialization produced invalid positions (NaN or Inf)');
else
    fprintf('Initialization completed successfully.\n');
    fprintf('Position matrix size: %d x %d\n', size(Positions, 1), size(Positions, 2));
end
end