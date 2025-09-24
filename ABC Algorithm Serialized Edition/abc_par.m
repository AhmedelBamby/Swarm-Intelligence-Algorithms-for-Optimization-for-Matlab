clc;
clear;
close all;

%% ================================
%  Load Cost Function
% =================================
Fname = 'F1';  % Select your cost function
[lb, ub, dim, CostFunction] = Get_Functions_details(Fname);

nVar = dim;
VarSize = [1 nVar];
VarMin = lb;
VarMax = ub;

%% ================================
%  ABC Parameters
% =================================
MaxIt = 200;           % Maximum iterations (Max_iter)
nPop = 100;            % Population size (SearchAgents_no) 
nOnlooker = 60;        % Number of onlooker bees (FoodNumber) - CHANGED
L = 100;               % Abandonment limit (limit) - CHANGED
a = 1;                 % Perturbation coefficient - unchanged
%% ================================
%  Initialization
% =================================
empty_bee.Position = [];
empty_bee.Cost = [];

pop = repmat(empty_bee, nPop, 1);
C = zeros(nPop, 1);
BestCost = zeros(MaxIt, 1);
MeanCost = zeros(MaxIt, 1);
Diversity = zeros(MaxIt, 1);
ParamHistory = zeros(MaxIt, nVar);

if isempty(gcp('nocreate'))
    parpool;
end

% Init population (parallel-safe)
Positions = zeros(nPop, nVar);
Costs = zeros(nPop, 1);

parfor i = 1:nPop
    pos = VarMin + rand(VarSize) .* (VarMax - VarMin);
    cost = CostFunction(pos);
    Positions(i,:) = pos;
    Costs(i) = cost;
end

for i = 1:nPop
    pop(i).Position = Positions(i,:);
    pop(i).Cost = Costs(i);
end

[~, bestIdx] = min(Costs);
BestSol = pop(bestIdx);

%% ================================
%  Main Loop
% =================================
for it = 1:MaxIt
    fprintf('>> Iteration %d Start...\n', it);

    % ----------------------------
    % Recruited Bees Phase
    % ----------------------------
    newPositions = zeros(nPop, nVar);
    newCosts = zeros(nPop, 1);
    newFlags = false(nPop, 1);

    parfor i = 1:nPop
        K = [1:i-1 i+1:nPop];
        k = K(randi(numel(K)));
        phi = a * rand(VarSize) .* 2 - 1;
        newPos = pop(i).Position + phi .* (pop(i).Position - pop(k).Position);
        newPos = max(min(newPos, VarMax), VarMin);
        newCost = CostFunction(newPos);

        if newCost <= pop(i).Cost
            newPositions(i,:) = newPos;
            newCosts(i) = newCost;
            newFlags(i) = true;
        else
            newPositions(i,:) = pop(i).Position;
            newCosts(i) = pop(i).Cost;
        end
    end

    for i = 1:nPop
        pop(i).Position = newPositions(i,:);
        pop(i).Cost = newCosts(i);
        if newFlags(i)
            C(i) = 0;
        else
            C(i) = C(i) + 1;
        end
    end

    % ----------------------------
    % Onlooker Bees Phase
    % ----------------------------
    Costs = [pop.Cost];
    MeanCost(it) = mean(Costs);
    F = exp(-Costs / MeanCost(it));
    P = F / sum(F);

    onlookerPositions = zeros(nOnlooker, nVar);
    onlookerCosts = zeros(nOnlooker, 1);
    onlookerIndices = zeros(nOnlooker, 1);

    parfor m = 1:nOnlooker
        i = RouletteWheelSelection(P);
        K = [1:i-1 i+1:nPop];
        k = K(randi(numel(K)));
        phi = a * rand(VarSize) .* 2 - 1;

        newPos = pop(i).Position + phi .* (pop(i).Position - pop(k).Position);
        newPos = max(min(newPos, VarMax), VarMin);
        newCost = CostFunction(newPos);

        onlookerPositions(m,:) = newPos;
        onlookerCosts(m) = newCost;
        onlookerIndices(m) = i;
    end

    for m = 1:nOnlooker
        i = onlookerIndices(m);
        if onlookerCosts(m) <= pop(i).Cost
            pop(i).Position = onlookerPositions(m,:);
            pop(i).Cost = onlookerCosts(m);
            C(i) = 0;
        else
            C(i) = C(i) + 1;
        end
    end

    % ----------------------------
    % Scout Bees Phase
    % ----------------------------
    scoutPositions = zeros(nPop, nVar);
    scoutCosts = zeros(nPop, 1);
    scoutFlags = false(nPop, 1);

    parfor i = 1:nPop
        if C(i) >= L
            newPos = VarMin + rand(VarSize) .* (VarMax - VarMin);
            newCost = CostFunction(newPos);
            scoutPositions(i,:) = newPos;
            scoutCosts(i) = newCost;
            scoutFlags(i) = true;
        end
    end

    for i = 1:nPop
        if scoutFlags(i)
            pop(i).Position = scoutPositions(i,:);
            pop(i).Cost = scoutCosts(i);
            C(i) = 0;
        end
    end

    % ----------------------------
    % Update Best Solution
    % ----------------------------
    [~, bestIdx] = min([pop.Cost]);
    if pop(bestIdx).Cost < BestSol.Cost
        BestSol = pop(bestIdx);
    end

    BestCost(it) = BestSol.Cost;
    Diversity(it) = mean(std(reshape([pop.Position], nVar, nPop)', 0, 1));
    ParamHistory(it,:) = BestSol.Position;

    fprintf('>> Iteration %d: Best Cost = %.4e | Diversity = %.4f\n', ...
            it, BestCost(it), Diversity(it));
end

%% ================================
%  Results & Plots
% =================================

figure;
semilogy(BestCost, 'b', 'LineWidth', 2);
xlabel('Iteration'); ylabel('Best Cost');
title('Best Cost vs. Iterations'); grid on;

figure;
plot(MeanCost, 'g', 'LineWidth', 2);
xlabel('Iteration'); ylabel('Mean Cost');
title('Mean Cost vs. Iterations'); grid on;

figure;
plot(Diversity, 'm', 'LineWidth', 2);
xlabel('Iteration'); ylabel('Diversity');
title('Population Diversity vs. Iterations'); grid on;

figure;
histogram(C, 'FaceColor', 'c');
xlabel('Trials'); ylabel('Bee Count');
title('Histogram of Trial Counters'); grid on;

FinalCosts = [pop.Cost];
FinalFitness = exp(-FinalCosts / mean(FinalCosts));
figure;
histogram(FinalFitness, 20, 'FaceColor', 'y');
xlabel('Fitness'); ylabel('Frequency');
title('Final Fitness Distribution'); grid on;

figure;
hold on;
colors = lines(nVar);
for i = 1:nVar
    plot(ParamHistory(:,i), 'Color', colors(i,:), 'LineWidth', 1.5);
end
xlabel('Iteration'); ylabel('Parameter Value');
title('Parameter Trajectories'); grid on;
legend(arrayfun(@(x) sprintf('Var %d', x), 1:nVar, 'UniformOutput', false));
