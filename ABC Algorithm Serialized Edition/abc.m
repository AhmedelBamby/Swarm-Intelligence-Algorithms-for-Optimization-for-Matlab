clc;
clear;
close all;
tic;

%% =======================================================================
% INITIALIZATION SECTION
% =======================================================================
fprintf('Artificial Bee Colony Optimization Started\n');
fprintf('-----------------------------------------\n');
fprintf('\n');
fprintf('============================================================\n');
fprintf('                    OPTIMIZATION PROJECT                     \n');
fprintf('============================================================\n');
fprintf('Name: Eng. Ahmed ElBamby\n');
fprintf('College: AAST - Artificial Intelligence (Robotics)\n');
fprintf('Algorithm: Artificial Bee Colony (ABC) Algorithm\n');
fprintf('Work Email: ahmedelbamby1102003@gmail.com\n');
fprintf('Work Phone Number: +201096562363\n');
fprintf('============================================================\n\n');

%% ================================
%  Load Cost Function Details
% =================================
[Fname] = 'F1';  % Selected objective function
[lb, ub, dim, CostFunction] = Get_Functions_details(Fname); 

% Problem dimensions
nVar = dim;               % Number of decision variables
VarSize = [1 nVar];       % Matrix size of decision variables
VarMin = lb;              % Lower bounds of variables
VarMax = ub;              % Upper bounds of variables

%% ================================
%  ABC Algorithm Parameters
% =================================
MaxIt = 5;                % Maximum iterations
nPop = 5;                 % Population size (employed bees)
nOnlooker = nPop;         % Onlooker bees count
L = round(0.6 * nVar * nPop); % Abandonment limit
a = 1;                    % Perturbation coefficient

fprintf('ABC Parameters:\n');
fprintf('  Max Iterations: %d\n', MaxIt);
fprintf('  Population Size: %d\n', nPop);
fprintf('  Abandonment Limit: %d\n', L);
fprintf('  Perturbation Factor: %.1f\n\n', a);

%% ================================
%  Bee Population Initialization
% =================================
empty_bee.Position = [];  % Decision variables
empty_bee.Cost = [];      % Objective value

% Initialize population array
pop = repmat(empty_bee, nPop, 1); 
BestSol.Cost = inf;       % Global best solution tracker

% Generate random initial population
fprintf('Initializing population...\n');
for i = 1:nPop
    pop(i).Position = VarMin + rand(VarSize) .* (VarMax - VarMin);
    
    % Evaluate objective function (modified for compatibility)
    pop(i).Cost = CostFunction(pop(i).Position);
    
    % Get error metrics from base workspace
    pop(i).CurrentError = evalin('base', 'nerr1');
    pop(i).VoltageError = evalin('base', 'nerr2');
    
    % Update global best
    if pop(i).Cost <= BestSol.Cost
        BestSol = pop(i);
    end
end

% Initialize counters and trackers
C = zeros(nPop, 1);           % Trial counters for abandonment
BestCost = zeros(MaxIt, 1);    % Best cost per iteration
AllCosts = cell(MaxIt, 1);     % All costs per iteration
Diversity = zeros(MaxIt, 1);   % Population diversity metric
ParamHistory = cell(MaxIt, 1); % Parameter evolution history
ErrorHistory = cell(MaxIt, 1); % Error metrics history

%% =======================================================================
% MAIN ABC OPTIMIZATION LOOP
% =======================================================================
fprintf('\nStarting ABC optimization...\n');
for it = 1:MaxIt
    fprintf('\nIteration %d/%d\n', it, MaxIt);
    
    %% Employed Bees Phase
    for i = 1:nPop
        K = [1:i-1 i+1:nPop];
        k = K(randi(numel(K)));
        phi = a * rand(VarSize) .* 2 - 1;
        
        newbee.Position = pop(i).Position + phi .* (pop(i).Position - pop(k).Position);
        newbee.Position = max(newbee.Position, VarMin);
        newbee.Position = min(newbee.Position, VarMax);
        
        % Evaluate new solution
        newbee.Cost = CostFunction(newbee.Position);
        newbee.CurrentError = evalin('base', 'nerr1');
        newbee.VoltageError = evalin('base', 'nerr2');
        
        if newbee.Cost <= pop(i).Cost
            pop(i) = newbee;
            C(i) = 0;
        else
            C(i) = C(i) + 1;
        end
    end
    
    %% Onlooker Bees Phase
    Costs = [pop.Cost];
    MeanCost = mean(Costs);
    F = exp(-Costs / MeanCost);
    P = F / sum(F);
    
    for m = 1:nOnlooker
        i = RouletteWheelSelection(P);
        K = [1:i-1 i+1:nPop];
        k = K(randi(numel(K)));
        phi = a * rand(VarSize) .* 2 - 1;
        
        newbee.Position = pop(i).Position + phi .* (pop(i).Position - pop(k).Position);
        newbee.Position = max(newbee.Position, VarMin);
        newbee.Position = min(newbee.Position, VarMax);
        
        % Evaluate new solution
        newbee.Cost = CostFunction(newbee.Position);
        newbee.CurrentError = evalin('base', 'nerr1');
        newbee.VoltageError = evalin('base', 'nerr2');
        
        if newbee.Cost <= pop(i).Cost
            pop(i) = newbee;
            C(i) = 0;
        else
            C(i) = C(i) + 1;
        end
    end
    
    %% Scout Bees Phase
    for i = 1:nPop
        if C(i) >= L
            pop(i).Position = VarMin + rand(VarSize) .* (VarMax - VarMin);
            pop(i).Cost = CostFunction(pop(i).Position);
            pop(i).CurrentError = evalin('base', 'nerr1');
            pop(i).VoltageError = evalin('base', 'nerr2');
            C(i) = 0;
            fprintf('  Scout activated for bee %d\n', i);
        end
    end
    
    %% Update Best Solution
    for i = 1:nPop
        if pop(i).Cost <= BestSol.Cost
            BestSol = pop(i);
        end
    end
    
    % Store iteration data
    BestCost(it) = BestSol.Cost;
    AllCosts{it} = [pop.Cost];
    positions = reshape([pop.Position], nVar, nPop)';
    ParamHistory{it} = positions;
    ErrorHistory{it} = [[pop.CurrentError]', [pop.VoltageError]'];
    Diversity(it) = mean(pdist(positions, 'euclidean'));
    
    fprintf('  Best Cost: %.6f  Diversity: %.6f\n', BestCost(it), Diversity(it));
end

fprintf('\nABC optimization completed!\n');

%% =======================================================================
% RESULTS PROCESSING (CORRECTED VERSION)
% =======================================================================
execTime = toc;
MeanCost = cellfun(@mean, AllCosts);

% Prepare comprehensive solution logging
allPositions = [];
allCurrentErrors = [];
allVoltageErrors = [];
allTotalErrors = [];
allIterations = [];

% Collect data ensuring consistent lengths
for it = 1:MaxIt
    nBees = size(ParamHistory{it}, 1);
    allPositions = [allPositions; ParamHistory{it}];
    allCurrentErrors = [allCurrentErrors; ErrorHistory{it}(:,1)];
    allVoltageErrors = [allVoltageErrors; ErrorHistory{it}(:,2)];
    allTotalErrors = [allTotalErrors; AllCosts{it}(:)];
    allIterations = [allIterations; it*ones(nBees,1)];
end

% Verify all arrays have same length
assert(length(allIterations) == length(allCurrentErrors) && ...
       length(allIterations) == length(allVoltageErrors) && ...
       length(allIterations) == length(allTotalErrors) && ...
       length(allIterations) == size(allPositions,1), ...
       'Data size mismatch in table creation');

% Create results table
resultTable = table(...
    allIterations, ...
    allPositions(:,1), allPositions(:,2), allPositions(:,3), allPositions(:,4), ...
    allCurrentErrors, allVoltageErrors, allTotalErrors, ...
    'VariableNames', {'Iteration', 'Kp_I', 'Ki_I', 'Kp_V', 'Ki_V', ...
                     'CurrentError', 'VoltageError', 'TotalError'});

% Save to Excel with timestamp
logFolder = 'Important_Excels';
if ~exist(logFolder, 'dir')
    mkdir(logFolder);
end
logFile = fullfile(logFolder, sprintf('ABC_Results_%s.xlsx', datestr(now, 'yyyy_mm_dd_HHMMSS')));
writetable(resultTable, logFile);
fprintf('All solutions saved to: %s\n', logFile);

%% =======================================================================
% VISUALIZATION
% =======================================================================
% Call visualization with additional parameters
if exist('SaveAndPlotResults', 'file')
    try
        SaveAndPlotResults(BestCost, MeanCost, Diversity, C, ParamHistory, ...
                         allCurrentErrors, allVoltageErrors, allTotalErrors);
    catch ME
        warning(ME.identifier,'Visualization failed: %s', ME.message);
    end
end

fprintf('Optimization completed in %.2f seconds\n', execTime);
%% =======================================================================
% HELPER FUNCTION
% =======================================================================
function i = RouletteWheelSelection(P)
    r = rand;
    C = cumsum(P);
    i = find(r <= C, 1, 'first');
end