%% =====================================================================
% ENHANCED PARALLEL ARTIFICIAL BEE COLONY (ABC) ALGORITHM
% WITH CHECKPOINT-BASED REPORTING SYSTEM
% =====================================================================

function enhanced_abc_parallel()
    clc; clear; close all; tic;
    
    %% Load Configuration
    config = abcConfig();
    
    %% Load Cost Function Details
    fprintf('Enhanced Parallel ABC Optimization with Checkpoint Reporting Started\n');
    fprintf('==================================================================\n\n');
    
    Fname = 'F1';
    [lb, ub, dim, CostFunction] = Get_Functions_details(Fname);
    
    nVar = dim;
    VarSize = [1 nVar];
    VarMin = lb;
    VarMax = ub;
    
    % Read ABC parameters from config
    MaxIt = config.algorithm.MaxIt;
    nPop = config.algorithm.nPop;
    nOnlooker = config.algorithm.nOnlooker;
    L = config.algorithm.L;
    a = config.algorithm.a;
    
    % Initialize checkpoint manager
    baseDir = config.files.baseDir;
    checkpointMgr = checkpointManager(baseDir);
    
    %% Checkpoint Handling: Resume?
    resumeFromCheckpoint = false;
    startIter = 1;
    
    checkpointPattern = fullfile(checkpointMgr.checkpointDir, 'checkpoint_*.mat');
    existingCheckpoints = dir(checkpointPattern);
    
    if ~isempty(existingCheckpoints)
        [~, idx] = max([existingCheckpoints.datenum]);
        latestCheckpoint = fullfile(checkpointMgr.checkpointDir, existingCheckpoints(idx).name);
        
        choice = input(sprintf('Found checkpoint: %s\nResume? (1=Yes, 0=No): ', existingCheckpoints(idx).name));
        if choice == 1
            fprintf('Loading checkpoint from: %s\n', latestCheckpoint);
            data = load(latestCheckpoint);
            
            % Restore all variables
            pop = data.pop;
            C = data.C;
            BestSol = data.BestSol;
            BestCost = data.BestCost;
            MeanCost = data.MeanCost;
            StdCost = data.StdCost;
            Diversity = data.Diversity;
            ParamHistory = data.ParamHistory;
            StatisticsHistory = data.StatisticsHistory;
            startIter = data.it + 1;
            resumeFromCheckpoint = true;
            
            fprintf('Resuming from iteration %d of %d\n', startIter, MaxIt);
        end
    end
    
    %% Initialization Section
    if ~resumeFromCheckpoint
        if isempty(gcp('nocreate'))
            parpool(config.parallel.numWorkers);
        end
        
        % Initialize population and variables
        empty_bee.Position = [];
        empty_bee.Cost = [];
        empty_bee.CurrentError = [];
        empty_bee.VoltageError = [];
        
        pop = repmat(empty_bee, nPop, 1);
        C = zeros(nPop, 1);
        BestCost = zeros(MaxIt, 1);
        MeanCost = zeros(MaxIt, 1);
        StdCost = zeros(MaxIt, 1);
        Diversity = zeros(MaxIt, 1);
        ParamHistory = zeros(MaxIt, nVar);
        StatisticsHistory = cell(MaxIt, 1);
        
        fprintf('Initializing population with %d bees...\n', nPop);
        
        % Parallel initialization
        Positions = zeros(nPop, nVar);
        Costs = zeros(nPop, 1);
        CurrentErrors = zeros(nPop, 1);
        VoltageErrors = zeros(nPop, 1);
        
        parfor i = 1:nPop
            pos = VarMin + rand(VarSize).*(VarMax - VarMin);
            cost = CostFunction(pos);
            Positions(i,:) = pos;
            Costs(i) = cost;
            CurrentErrors(i) = evalin('base','nerr1');
            VoltageErrors(i) = evalin('base','nerr2');
        end
        
        for i = 1:nPop
            pop(i).Position = Positions(i,:);
            pop(i).Cost = Costs(i);
            pop(i).CurrentError = CurrentErrors(i);
            pop(i).VoltageError = VoltageErrors(i);
        end
        
        [~, bestIdx] = min(Costs);
        BestSol = pop(bestIdx);
        
        fprintf('Population initialized. Best initial cost: %.6e\n', BestSol.Cost);
    end
    
    %% Main Optimization Loop
    fprintf('\nStarting main optimization loop...\n');
    fprintf('Progress: [Iter/Total] | Best Cost | Mean Cost | Std Cost | Diversity\n');
    fprintf('----------------------------------------------------------------------\n');
    
    for it = startIter:MaxIt
        progressPercent = (it-1)/MaxIt*100;
        fprintf('[%3d/%3d] (%.1f%%) | ', it, MaxIt, progressPercent);
        
        % Employed Bees Phase
        newPositions = zeros(nPop, nVar);
        newCosts = zeros(nPop, 1);
        newCurrentErrors = zeros(nPop, 1);
        newVoltageErrors = zeros(nPop, 1);
        newFlags = false(nPop,1);
        
        parfor i=1:nPop
            K = [1:i-1 i+1:nPop];
            k = K(randi(numel(K)));
            phi = a*rand(VarSize)*2 - 1;
            newPos = pop(i).Position + phi.*(pop(i).Position - pop(k).Position);
            newPos = max(min(newPos, VarMax), VarMin);
            
            newCost = CostFunction(newPos);
            newCurrentErr = evalin('base', 'nerr1');
            newVoltageErr = evalin('base', 'nerr2');
            
            if newCost <= pop(i).Cost
                newPositions(i,:) = newPos;
                newCosts(i) = newCost;
                newCurrentErrors(i) = newCurrentErr;
                newVoltageErrors(i) = newVoltageErr;
                newFlags(i) = true;
            else
                newPositions(i,:) = pop(i).Position;
                newCosts(i) = pop(i).Cost;
                newCurrentErrors(i) = pop(i).CurrentError;
                newVoltageErrors(i) = pop(i).VoltageError;
            end
        end
        
        % Update population
        for i=1:nPop
            pop(i).Position = newPositions(i,:);
            pop(i).Cost = newCosts(i);
            pop(i).CurrentError = newCurrentErrors(i);
            pop(i).VoltageError = newVoltageErrors(i);
            if newFlags(i)
                C(i) = 0;
            else
                C(i) = C(i) + 1;
            end
        end
        
        % Onlooker Bees Phase
        Costs = [pop.Cost];
        MeanCost(it) = mean(Costs);
        F = exp(-Costs / MeanCost(it));
        P = F / sum(F);
        
        onlookerPositions = zeros(nOnlooker, nVar);
        onlookerCosts = zeros(nOnlooker, 1);
        onlookerCurrentErrors = zeros(nOnlooker,1);
        onlookerVoltageErrors = zeros(nOnlooker,1);
        onlookerIndices = zeros(nOnlooker,1);
        
        parfor m=1:nOnlooker
            i = RouletteWheelSelection(P);
            K = [1:i-1 i+1:nPop];
            k = K(randi(numel(K)));
            phi = a*rand(VarSize)*2 - 1;
            newPos = pop(i).Position + phi.*(pop(i).Position - pop(k).Position);
            newPos = max(min(newPos, VarMax), VarMin);
            
            newCost = CostFunction(newPos);
            newCurrentErr = evalin('base', 'nerr1');
            newVoltageErr = evalin('base', 'nerr2');
            
            onlookerPositions(m,:) = newPos;
            onlookerCosts(m) = newCost;
            onlookerCurrentErrors(m) = newCurrentErr;
            onlookerVoltageErrors(m) = newVoltageErr;
            onlookerIndices(m) = i;
        end
        
        for m=1:nOnlooker
            i = onlookerIndices(m);
            if onlookerCosts(m) <= pop(i).Cost
                pop(i).Position = onlookerPositions(m,:);
                pop(i).Cost = onlookerCosts(m);
                pop(i).CurrentError = onlookerCurrentErrors(m);
                pop(i).VoltageError = onlookerVoltageErrors(m);
                C(i) = 0;
            else
                C(i) = C(i) + 1;
            end
        end
        
        % Scout Bees Phase
        scoutIndices = find(C >= L);
        numScouts = length(scoutIndices);
        
        if numScouts > 0
            scoutPositions = zeros(numScouts, nVar);
            scoutCosts = zeros(numScouts, 1);
            scoutCurrentErrors = zeros(numScouts, 1);
            scoutVoltageErrors = zeros(numScouts, 1);
            
            parfor s=1:numScouts
                newPos = VarMin + rand(VarSize).*(VarMax-VarMin);
                newCost = CostFunction(newPos);
                newCurrentErr = evalin('base','nerr1');
                newVoltageErr = evalin('base','nerr2');
                
                scoutPositions(s,:) = newPos;
                scoutCosts(s) = newCost;
                scoutCurrentErrors(s) = newCurrentErr;
                scoutVoltageErrors(s) = newVoltageErr;
            end
            
            for s=1:numScouts
                i = scoutIndices(s);
                pop(i).Position = scoutPositions(s,:);
                pop(i).Cost = scoutCosts(s);
                pop(i).CurrentError = scoutCurrentErrors(s);
                pop(i).VoltageError = scoutVoltageErrors(s);
                C(i) = 0;
            end
        end
        
        % Update Best Solution & Statistics
        [~, bestIdx] = min([pop.Cost]);
        if pop(bestIdx).Cost < BestSol.Cost
            BestSol = pop(bestIdx);
        end
        
        BestCost(it) = BestSol.Cost;
        allCosts = [pop.Cost];
        MeanCost(it) = mean(allCosts);
        StdCost(it) = std(allCosts);
        
        positionMatrix = reshape([pop.Position], nVar, nPop)';
        Diversity(it) = mean(std(positionMatrix, 0, 1));
        ParamHistory(it,:) = BestSol.Position;
        
        % Store iteration statistics
        iterStats.iteration = it;
        iterStats.bestCost = BestCost(it);
        iterStats.meanCost = MeanCost(it);
        iterStats.stdCost = StdCost(it);
        iterStats.diversity = Diversity(it);
        iterStats.numScouts = numScouts;
        iterStats.bestParams = BestSol.Position;
        iterStats.allCosts = allCosts;
        iterStats.currentErrors = [pop.CurrentError];
        iterStats.voltageErrors = [pop.VoltageError];
        StatisticsHistory{it} = iterStats;
        
        fprintf('%.6e | %.6e | %.6e | %.4f\n', BestCost(it), MeanCost(it), StdCost(it), Diversity(it));
        
        % Real-time visualization
        if mod(it, config.visualization.updateInterval) == 0 || it == 1
            figure(100); clf;
            if nVar >= 3
                scatter3(positionMatrix(:,1), positionMatrix(:,2), positionMatrix(:,3), ...
                    50, allCosts, 'filled', 'MarkerEdgeColor', 'k');
                xlabel('Kp_I'); ylabel('Ki_I'); zlabel('Kp_V');
                view(45, 30);
            else
                scatter(positionMatrix(:,1), positionMatrix(:,2), ...
                    50, allCosts, 'filled', 'MarkerEdgeColor', 'k');
                xlabel('Parameter 1'); ylabel('Parameter 2');
            end
            colorbar;
            title(sprintf('Agent Positions - Iteration %d/%d (%.1f%%)', it, MaxIt, progressPercent));
            grid on;
            drawnow;
            
            if mod(it, config.visualization.saveInterval) == 0
                saveas(gcf, fullfile(checkpointMgr.visualDir, sprintf('agents_iter_%03d.png', it)));
            end
        end
        
        % CHECKPOINT SYSTEM WITH AUTOMATIC REPORT GENERATION
        if mod(it, config.memory.checkpointInterval) == 0 || it == MaxIt
            fprintf('Saving checkpoint with reports...\n');
            
            % Prepare checkpoint data
            checkpointData = struct();
            checkpointData.pop = pop;
            checkpointData.C = C;
            checkpointData.BestSol = BestSol;
            checkpointData.BestCost = BestCost;
            checkpointData.MeanCost = MeanCost;
            checkpointData.StdCost = StdCost;
            checkpointData.Diversity = Diversity;
            checkpointData.ParamHistory = ParamHistory;
            checkpointData.StatisticsHistory = StatisticsHistory;
            checkpointData.it = it;
            checkpointData.MaxIt = MaxIt;
            checkpointData.nPop = nPop;
            checkpointData.nOnlooker = nOnlooker;
            checkpointData.L = L;
            checkpointData.a = a;
            checkpointData.VarMin = VarMin;
            checkpointData.VarMax = VarMax;
            checkpointData.nVar = nVar;
            
            % Save checkpoint with automatic report generation
            checkpointMgr.save(checkpointData, it);
            
            fprintf('Checkpoint and reports saved successfully.\n');
        end
        
        % Memory cleanup
        if mod(it, config.memory.cleanupInterval) == 0
            fprintf('Performing memory cleanup...\n');
            clear scoutPositions scoutCosts onlookerPositions onlookerCosts;
        end
    end
    
    %% Final Results Processing
    totalTime = toc;
    
    fprintf('\n==========================================\n');
    fprintf('Optimization completed in %.2f seconds\n', totalTime);
    fprintf('Best solution found:\n');
    fprintf(' Cost: %.6e\n', BestSol.Cost);
    fprintf(' Parameters: [%.4f, %.4f, %.4f, %.4f]\n', BestSol.Position);
    fprintf(' Current Error: %.6f\n', BestSol.CurrentError);
    fprintf(' Voltage Error: %.6f\n', BestSol.VoltageError);
    
    % Generate comprehensive final report from latest checkpoint
    fprintf('\nGenerating comprehensive final report...\n');
    checkpointMgr.generateFinalReportFromLatestCheckpoint();
    
    % Log final results to Excel
    try
        logExperimentResultsExcel(BestSol.Position(1), BestSol.Position(2), ...
            BestSol.Position(3), BestSol.Position(4), BestSol.CurrentError, ...
            BestSol.VoltageError, BestSol.Cost, MaxIt, totalTime);
    catch ME
        fprintf('Warning: Could not log to Excel: %s\n', ME.message);
    end
    
    fprintf('\nAll results and reports saved to: %s\n', baseDir);
    fprintf('Checkpoint-based reporting completed successfully!\n');
end
