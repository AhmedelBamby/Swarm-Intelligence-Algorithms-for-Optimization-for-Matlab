function [Alpha_score, Alpha_pos, Convergence_curve, tracking_data] = GWO(SearchAgents_no, Max_iter, lb, ub, dim, fobj)
%% Initialization Phase 
% initialize alpha, beta, and delta_pos
Alpha_pos = zeros(1,dim);
Alpha_score = inf; %change this to -inf for maximization problems

Beta_pos = zeros(1,dim);
Beta_score = inf; %change this to -inf for maximization problems

Delta_pos = zeros(1,dim);
Delta_score = inf; %change this to -inf for maximization problems

% Initialize tracking structure
tracking_data = struct();
tracking_data.iterations = zeros(1, Max_iter);
tracking_data.positions = cell(1, Max_iter);
tracking_data.fitness = zeros(SearchAgents_no, Max_iter);
tracking_data.current_error = zeros(SearchAgents_no, Max_iter);
tracking_data.voltage_error = zeros(SearchAgents_no, Max_iter);
tracking_data.alpha = zeros(Max_iter, dim);
tracking_data.alpha_score = zeros(1, Max_iter);

% Initialize the positions of search agents
Boundary_no = size(ub, 2);
if Boundary_no == 1
    Positions = rand(SearchAgents_no, dim) .* (ub - lb) + lb;
else
    Positions = zeros(SearchAgents_no, dim);
    for i = 1:dim
        Positions(:, i) = rand(SearchAgents_no, 1) .* (ub(i) - lb(i)) + lb(i);
    end
end

Convergence_curve = zeros(1,Max_iter);
%% Main Loop
l = 0; % Loop counter

% Create a parallel pool if none exists
if isempty(gcp('nocreate'))
    parpool;
end

% Main loop
while l < Max_iter
    % Evaluate fitness in parallel
    fitness = zeros(SearchAgents_no, 1);
    current_err = zeros(SearchAgents_no, 1);
    voltage_err = zeros(SearchAgents_no, 1);
    
    parfor i = 1:size(Positions,1)
        % Return back the search agents that go beyond the boundaries
        Flag4ub = Positions(i,:) > ub;
        Flag4lb = Positions(i,:) < lb;
        Positions(i,:) = (Positions(i,:) .* (~(Flag4ub + Flag4lb))) + ub .* Flag4ub + lb .* Flag4lb;
        
        % Calculate objective function for each search agent
        [fitness(i), current_err(i), voltage_err(i)] = fobj(Positions(i,:));
    end
    
    % Update Alpha, Beta, and Delta (needs to be done serially)
    for i = 1:size(Positions,1)
        if fitness(i) < Alpha_score
            Alpha_score = fitness(i); % Update alpha
            Alpha_pos = Positions(i,:);
        end
        
        if fitness(i) > Alpha_score && fitness(i) < Beta_score
            Beta_score = fitness(i); % Update beta
            Beta_pos = Positions(i,:);
        end
        
        if fitness(i) > Alpha_score && fitness(i) > Beta_score && fitness(i) < Delta_score
            Delta_score = fitness(i); % Update delta
            Delta_pos = Positions(i,:);
        end
    end
    
    a = 2 - l * ((2)/Max_iter); % a decreases linearly from 2 to 0
    
    % Update positions - this part remains serial as it's not easily parallelizable
    % due to dependencies between iterations
    for i = 1:size(Positions,1)
        for j = 1:size(Positions,2)
            r1 = rand();
            r2 = rand();
            
            A1 = 2*a*r1 - a;
            C1 = 2*r2;
            
            D_alpha = abs(C1*Alpha_pos(j) - Positions(i,j));
            X1 = Alpha_pos(j) - A1*D_alpha;
                       
            r1 = rand();
            r2 = rand();
            
            A2 = 2*a*r1 - a;
            C2 = 2*r2;
            
            D_beta = abs(C2*Beta_pos(j) - Positions(i,j));
            X2 = Beta_pos(j) - A2*D_beta;
            
            r1 = rand();
            r2 = rand();
            
            A3 = 2*a*r1 - a;
            C3 = 2*r2;
            
            D_delta = abs(C3*Delta_pos(j) - Positions(i,j));
            X3 = Delta_pos(j) - A3*D_delta;
            
            Positions(i,j) = (X1 + X2 + X3)/3;
        end
    end
    
    fprintf("==================================================")
    fprintf('============================================================\n\n');
    fprintf("Iteration : %i out of %i \n", (l+1), Max_iter);
    fprintf('Name: Eng. Ahmed ElBamby\n');
    fprintf('College: AAST - Artificial Intelligence (Robotics)\n');
    fprintf('Algorithm: Grey Wolf Optimization Algorithm\n');
    fprintf('Work Email: ahmedelbamby1102003@gmail.com\n');
    fprintf('Work Phone Number: +201096562363\n');
    fprintf('============================================================\n');
    fprintf("==================================================\n")
    
    % Track iteration data
    tracking_data.iterations(l+1) = l+1;
    tracking_data.positions{l+1} = Positions;
    tracking_data.fitness(:,l+1) = fitness;
    tracking_data.current_error(:,l+1) = current_err;
    tracking_data.voltage_error(:,l+1) = voltage_err;
    tracking_data.alpha(l+1,:) = Alpha_pos;
    tracking_data.alpha_score(l+1) = Alpha_score;
    
    % Call the tracker function with all error metrics
    iteration_tracker(l+1, Positions, fitness, Alpha_pos, Alpha_score, current_err, voltage_err);    
    l = l+1;
    Convergence_curve(l) = Alpha_score;
end