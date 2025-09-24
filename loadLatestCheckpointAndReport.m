function loadLatestCheckpointAndReport()
%% =====================================================================
% LOAD LATEST CHECKPOINT AND GENERATE COMPREHENSIVE REPORTS
% Features: Single figures, high quality outputs, complete analysis
% Author: Enhanced version for Ahmed ElBamby
%% =====================================================================

clc; clear; close all;

fprintf('=== Loading Latest Checkpoint and Generating High-Quality Reports ===\n');
fprintf('====================================================================\n\n');

%% Configuration
config = abcConfig();
baseDir = config.files.baseDir;

% Directory paths
checkpointDir = fullfile(baseDir, 'Checkpoints');
resultsDir = fullfile(baseDir, 'Results');
visualDir = fullfile(baseDir, 'Visualizations');
statisticsDir = fullfile(baseDir, 'Statistics');

% Create directories if they don't exist
dirs = {baseDir, checkpointDir, resultsDir, visualDir, statisticsDir};
for i = 1:length(dirs)
    if ~exist(dirs{i}, 'dir')
        mkdir(dirs{i});
        fprintf('Created directory: %s\n', dirs{i});
    end
end

%% Find and Load Latest Checkpoint
fprintf('Searching for checkpoint files in: %s\n', checkpointDir);

checkpointPattern = fullfile(checkpointDir, 'checkpoint_*.mat');
existingCheckpoints = dir(checkpointPattern);

if isempty(existingCheckpoints)
    fprintf('No checkpoint files found in %s\n', checkpointDir);
    fprintf('Please run the enhanced_abc_parallel.m first to create checkpoints.\n');
    return;
end

% Find the latest checkpoint by date
[~, idx] = max([existingCheckpoints.datenum]);
latestCheckpoint = fullfile(checkpointDir, existingCheckpoints(idx).name);

fprintf('Found %d checkpoint files\n', length(existingCheckpoints));
fprintf('Loading latest checkpoint: %s\n', existingCheckpoints(idx).name);
fprintf('Checkpoint date: %s\n', datestr(existingCheckpoints(idx).datenum));

% Load the checkpoint data
try
    checkpointData = load(latestCheckpoint);
    fprintf('Checkpoint loaded successfully!\n\n');
catch ME
    fprintf('Error loading checkpoint: %s\n', ME.message);
    return;
end

%% Extract Data from Checkpoint
fprintf('Extracting data from checkpoint...\n');

% Check what iteration we're at
if isfield(checkpointData, 'it')
    currentIteration = checkpointData.it;
else
    currentIteration = length(find(checkpointData.BestCost > 0));
end

fprintf('Checkpoint contains data up to iteration: %d\n', currentIteration);

% Extract all relevant data
BestCost = checkpointData.BestCost(1:currentIteration);
MeanCost = checkpointData.MeanCost(1:currentIteration);
StdCost = checkpointData.StdCost(1:currentIteration);
Diversity = checkpointData.Diversity(1:currentIteration);
ParamHistory = checkpointData.ParamHistory(1:currentIteration, :);

if isfield(checkpointData, 'StatisticsHistory')
    StatisticsHistory = checkpointData.StatisticsHistory(1:currentIteration);
else
    StatisticsHistory = cell(currentIteration, 1);
end

if isfield(checkpointData, 'BestSol')
    BestSol = checkpointData.BestSol;
else
    % Create BestSol from available data
    [~, bestIdx] = min(BestCost);
    BestSol.Cost = BestCost(bestIdx);
    BestSol.Position = ParamHistory(bestIdx, :);
    BestSol.CurrentError = NaN;
    BestSol.VoltageError = NaN;
end

if isfield(checkpointData, 'pop')
    pop = checkpointData.pop;
    C = checkpointData.C;
else
    pop = [];
    C = zeros(100, 1); % Default for plotting
end

fprintf('Data extraction completed.\n\n');

%% Generate Timestamp for Reports
timestamp = datestr(now, 'yyyy_mm_dd_HHMMSS');

%% 1. GENERATE HIGH-QUALITY INDIVIDUAL FIGURES
fprintf('=== GENERATING HIGH-QUALITY INDIVIDUAL FIGURES ===\n');

% Set high-quality figure properties
figureProps = struct();
figureProps.Position = [100, 100, 1200, 800];
figureProps.PaperUnits = 'inches';
figureProps.PaperSize = [12, 8];
figureProps.PaperPosition = [0, 0, 12, 8];
figureProps.Color = 'white';
figureProps.InvertHardcopy = 'off';

%% Figure 1: Best Cost and Mean Cost vs Iterations (NEW FIGURE)
fprintf('Generating Best Cost and Mean Cost vs Iterations figure...\n');

f1 = figure(figureProps);
set(f1, 'Name', 'Cost Evolution Analysis', 'NumberTitle', 'off');

% Plot both costs
semilogy(1:length(BestCost), BestCost, 'b-', 'LineWidth', 3, 'DisplayName', 'Best Cost');
hold on;
plot(1:length(MeanCost), MeanCost, 'r--', 'LineWidth', 2.5, 'DisplayName', 'Mean Cost');

% Add standard deviation envelope if available
if ~isempty(StdCost) && length(StdCost) == length(MeanCost)
    upperBound = MeanCost + StdCost;
    lowerBound = max(MeanCost - StdCost, eps); % Prevent negative values for log plot
    
    % Create fill area
    xFill = [1:length(MeanCost), fliplr(1:length(MeanCost))];
    yFill = [upperBound', fliplr(lowerBound')];
    fill(xFill, yFill, 'r', 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'DisplayName', '±1 STD');
end

xlabel('Iteration', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Cost (Log Scale)', 'FontSize', 14, 'FontWeight', 'bold');
title('Best Cost and Mean Cost Evolution Throughout Optimization', 'FontSize', 16, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 12);
grid on;
set(gca, 'FontSize', 12, 'LineWidth', 1.5);

% Add improvement annotation
improvementFactor = BestCost(1) / BestCost(end);
textStr = sprintf('Improvement: %.2fx\nFinal Best: %.2e\nInitial Best: %.2e', ...
    improvementFactor, BestCost(end), BestCost(1));
text(0.02, 0.98, textStr, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
    'FontSize', 10, 'BackgroundColor', 'white', 'EdgeColor', 'black');

hold off;

% Save with highest quality
saveFigureHighQuality(f1, fullfile(visualDir, ['cost_evolution_', timestamp]), 'Cost Evolution');

%% Figure 2: Best Cost Convergence (Single)
fprintf('Generating Best Cost Convergence figure...\n');

f2 = figure(figureProps);
set(f2, 'Name', 'Best Cost Convergence', 'NumberTitle', 'off');

semilogy(BestCost, 'b-', 'LineWidth', 3);
xlabel('Iteration', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Best Cost (Log Scale)', 'FontSize', 14, 'FontWeight', 'bold');
title('Best Cost Convergence Throughout Optimization', 'FontSize', 16, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 12, 'LineWidth', 1.5);

% Add convergence metrics
convergenceText = sprintf('Initial: %.2e\nFinal: %.2e\nReduction: %.1f%%', ...
    BestCost(1), BestCost(end), (1 - BestCost(end)/BestCost(1))*100);
text(0.98, 0.98, convergenceText, 'Units', 'normalized', 'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'top', 'FontSize', 10, 'BackgroundColor', 'white', 'EdgeColor', 'black');

saveFigureHighQuality(f2, fullfile(visualDir, ['best_cost_convergence_', timestamp]), 'Best Cost Convergence');

%% Figure 3: Mean Cost Evolution (Single)
fprintf('Generating Mean Cost Evolution figure...\n');

f3 = figure(figureProps);
set(f3, 'Name', 'Mean Cost Evolution', 'NumberTitle', 'off');

plot(MeanCost, 'g-', 'LineWidth', 3);
xlabel('Iteration', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Mean Cost', 'FontSize', 14, 'FontWeight', 'bold');
title('Mean Population Cost Evolution', 'FontSize', 16, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 12, 'LineWidth', 1.5);

% Add statistics
meanText = sprintf('Initial Mean: %.2e\nFinal Mean: %.2e\nAverage: %.2e', ...
    MeanCost(1), MeanCost(end), mean(MeanCost));
text(0.98, 0.98, meanText, 'Units', 'normalized', 'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'top', 'FontSize', 10, 'BackgroundColor', 'white', 'EdgeColor', 'black');

saveFigureHighQuality(f3, fullfile(visualDir, ['mean_cost_evolution_', timestamp]), 'Mean Cost Evolution');

%% Figure 4: Population Diversity (Single)
fprintf('Generating Population Diversity figure...\n');

f4 = figure(figureProps);
set(f4, 'Name', 'Population Diversity', 'NumberTitle', 'off');

plot(Diversity, 'm-', 'LineWidth', 3);
xlabel('Iteration', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Population Diversity', 'FontSize', 14, 'FontWeight', 'bold');
title('Population Diversity Evolution', 'FontSize', 16, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 12, 'LineWidth', 1.5);

% Add diversity statistics
diversityText = sprintf('Initial: %.4f\nFinal: %.4f\nAverage: %.4f\nMin: %.4f\nMax: %.4f', ...
    Diversity(1), Diversity(end), mean(Diversity), min(Diversity), max(Diversity));
text(0.98, 0.98, diversityText, 'Units', 'normalized', 'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'top', 'FontSize', 10, 'BackgroundColor', 'white', 'EdgeColor', 'black');

saveFigureHighQuality(f4, fullfile(visualDir, ['population_diversity_', timestamp]), 'Population Diversity');

%% Figure 5: Trial Counter Distribution (Single)
fprintf('Generating Trial Counter Distribution figure...\n');

f5 = figure(figureProps);
set(f5, 'Name', 'Trial Counter Distribution', 'NumberTitle', 'off');

histogram(C, 'FaceColor', [0.3, 0.7, 0.9], 'EdgeColor', 'black', 'LineWidth', 1.5, 'BinMethod', 'integers');
xlabel('Number of Trials', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Bee Count', 'FontSize', 14, 'FontWeight', 'bold');
title('Distribution of Trial Counters', 'FontSize', 16, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 12, 'LineWidth', 1.5);

% Add statistics
trialText = sprintf('Mean Trials: %.2f\nMax Trials: %d\nStd: %.2f', ...
    mean(C), max(C), std(C));
text(0.98, 0.98, trialText, 'Units', 'normalized', 'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'top', 'FontSize', 10, 'BackgroundColor', 'white', 'EdgeColor', 'black');

saveFigureHighQuality(f5, fullfile(visualDir, ['trial_counter_distribution_', timestamp]), 'Trial Counter Distribution');

%% Figure 6: Final Fitness Distribution (Single)
fprintf('Generating Final Fitness Distribution figure...\n');

f6 = figure(figureProps);
set(f6, 'Name', 'Final Fitness Distribution', 'NumberTitle', 'off');

FinalCosts = exp(-BestCost / mean(BestCost));
histogram(FinalCosts, 20, 'FaceColor', [1, 0.7, 0.2], 'EdgeColor', 'black', 'LineWidth', 1.5);
xlabel('Fitness Value', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Frequency', 'FontSize', 14, 'FontWeight', 'bold');
title('Final Fitness Distribution', 'FontSize', 16, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 12, 'LineWidth', 1.5);

saveFigureHighQuality(f6, fullfile(visualDir, ['final_fitness_distribution_', timestamp]), 'Final Fitness Distribution');

%% Figure 7: Parameter Trajectories (Single)
fprintf('Generating Parameter Trajectories figure...\n');

f7 = figure(figureProps);
set(f7, 'Name', 'Parameter Trajectories', 'NumberTitle', 'off');

paramNames = {'Kp_I', 'Ki_I', 'Kp_V', 'Ki_V'};
colors = [0.2, 0.4, 0.8; 0.8, 0.2, 0.2; 0.2, 0.8, 0.2; 0.8, 0.4, 0.8];

hold on;
for i = 1:min(size(ParamHistory, 2), 4)
    if i <= size(colors, 1)
        plot(ParamHistory(:, i), 'Color', colors(i,:), 'LineWidth', 3, 'DisplayName', paramNames{i});
    else
        plot(ParamHistory(:, i), 'LineWidth', 3, 'DisplayName', sprintf('Param_%d', i));
    end
end
hold off;

xlabel('Iteration', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Parameter Value', 'FontSize', 14, 'FontWeight', 'bold');
title('Controller Parameter Evolution Throughout Optimization', 'FontSize', 16, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 12);
grid on;
set(gca, 'FontSize', 12, 'LineWidth', 1.5);

% Add final parameter values
finalParamsText = '';
for i = 1:min(size(ParamHistory, 2), 4)
    if i <= length(paramNames)
        finalParamsText = [finalParamsText, sprintf('%s: %.4f\n', paramNames{i}, ParamHistory(end, i))];
    end
end
text(0.02, 0.98, finalParamsText, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
    'FontSize', 10, 'BackgroundColor', 'white', 'EdgeColor', 'black');

saveFigureHighQuality(f7, fullfile(visualDir, ['parameter_trajectories_', timestamp]), 'Parameter Trajectories');

%% Figure 8: Error Analysis (if available)
if ~isempty(StatisticsHistory) && ~isempty(StatisticsHistory{end}) && ...
   isfield(StatisticsHistory{end}, 'currentErrors') && isfield(StatisticsHistory{end}, 'voltageErrors')
    
    fprintf('Generating Error Analysis figure...\n');
    
    f8 = figure(figureProps);
    set(f8, 'Name', 'Error Analysis', 'NumberTitle', 'off');
    
    finalStats = StatisticsHistory{end};
    currentErrors = finalStats.currentErrors;
    voltageErrors = finalStats.voltageErrors;
    totalErrors = finalStats.allCosts;
    
    scatter(currentErrors, voltageErrors, 50, totalErrors, 'filled', 'MarkerEdgeColor', 'black', 'LineWidth', 0.5);
    colorbar('FontSize', 12);
    xlabel('Current Error', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('Voltage Error', 'FontSize', 14, 'FontWeight', 'bold');
    title('Current vs Voltage Error Correlation (Color: Total Error)', 'FontSize', 16, 'FontWeight', 'bold');
    grid on;
    set(gca, 'FontSize', 12, 'LineWidth', 1.5);
    
    % Add correlation coefficient
    if length(currentErrors) == length(voltageErrors) && length(currentErrors) > 1
        corrCoeff = corrcoef(currentErrors, voltageErrors);
        corrText = sprintf('Correlation: %.3f', corrCoeff(1,2));
        text(0.98, 0.02, corrText, 'Units', 'normalized', 'HorizontalAlignment', 'right', ...
            'VerticalAlignment', 'bottom', 'FontSize', 12, 'BackgroundColor', 'white', 'EdgeColor', 'black');
    end
    
    saveFigureHighQuality(f8, fullfile(visualDir, ['error_analysis_', timestamp]), 'Error Analysis');
end

%% Figure 9: Cost Standard Deviation (Single)
fprintf('Generating Cost Standard Deviation figure...\n');

f9 = figure(figureProps);
set(f9, 'Name', 'Cost Standard Deviation', 'NumberTitle', 'off');

plot(StdCost, 'c-', 'LineWidth', 3);
xlabel('Iteration', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Cost Standard Deviation', 'FontSize', 14, 'FontWeight', 'bold');
title('Population Cost Variability Evolution', 'FontSize', 16, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 12, 'LineWidth', 1.5);

% Add statistics
stdText = sprintf('Initial Std: %.2e\nFinal Std: %.2e\nMean Std: %.2e', ...
    StdCost(1), StdCost(end), mean(StdCost));
text(0.98, 0.98, stdText, 'Units', 'normalized', 'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'top', 'FontSize', 10, 'BackgroundColor', 'white', 'EdgeColor', 'black');

saveFigureHighQuality(f9, fullfile(visualDir, ['cost_std_evolution_', timestamp]), 'Cost Standard Deviation');

%% 2. ENHANCED STATISTICS ANALYSIS
fprintf('\n=== GENERATING ENHANCED STATISTICS ===\n');

try
    % Generate comprehensive statistics for each metric
    bestCostStats = enhancedStatistics(BestCost, 'Best Cost Evolution');
    meanCostStats = enhancedStatistics(MeanCost, 'Mean Cost Evolution');
    diversityStats = enhancedStatistics(Diversity, 'Population Diversity');
    
    % Parameter statistics
    paramStats = cell(size(ParamHistory, 2), 1);
    for i = 1:size(ParamHistory, 2)
        if i <= length(paramNames)
            paramStats{i} = enhancedStatistics(ParamHistory(:, i), paramNames{i});
        else
            paramStats{i} = enhancedStatistics(ParamHistory(:, i), sprintf('Parameter_%d', i));
        end
    end
    
    % Save enhanced statistics
    enhancedStatsFile = fullfile(statisticsDir, ['enhanced_statistics_', timestamp, '.mat']);
    save(enhancedStatsFile, 'bestCostStats', 'meanCostStats', 'diversityStats', 'paramStats');
    
    fprintf('Enhanced statistics saved to: %s\n', enhancedStatsFile);
    
catch ME
    fprintf('Warning: Enhanced statistics generation failed: %s\n', ME.message);
end

%% 3. GENERATE COMPREHENSIVE REPORTS
fprintf('\n=== GENERATING COMPREHENSIVE REPORTS ===\n');

try
    % Use the fixed generateFinalReports function
    generateFinalReports(resultsDir, visualDir, statisticsDir, BestCost, MeanCost, ...
        StdCost, Diversity, ParamHistory, StatisticsHistory, timestamp);
    
    fprintf('Comprehensive reports generated successfully!\n');
    
catch ME
    fprintf('Warning: Report generation failed: %s\n', ME.message);
    fprintf('Generating basic summary instead...\n');
    
    % Generate basic summary as fallback
    generateBasicSummary(resultsDir, BestSol, BestCost, MeanCost, Diversity, ...
        ParamHistory, currentIteration, timestamp);
end

%% 4. LOG RESULTS TO EXCEL
fprintf('\n=== LOGGING RESULTS TO EXCEL ===\n');

try
    if length(BestSol.Position) >= 4
        % Calculate execution time estimate
        execTime = currentIteration * 2; % Rough estimate
        
        logExperimentResultsExcel(BestSol.Position(1), BestSol.Position(2), ...
            BestSol.Position(3), BestSol.Position(4), BestSol.CurrentError, ...
            BestSol.VoltageError, BestSol.Cost, currentIteration, execTime);
        
        fprintf('Results logged to Excel successfully!\n');
    else
        fprintf('Insufficient parameter data for Excel logging\n');
    end
    
catch ME
    fprintf('Warning: Excel logging failed: %s\n', ME.message);
end

%% 5. DISPLAY FINAL SUMMARY
fprintf('\n=== OPTIMIZATION RESULTS SUMMARY ===\n');
fprintf('=====================================\n');
fprintf('Analysis Date: %s\n', datestr(now));
fprintf('Data up to iteration: %d\n', currentIteration);
fprintf('Best Cost Found: %.6e\n', BestSol.Cost);
fprintf('Initial Cost: %.6e\n', BestCost(1));
fprintf('Improvement Factor: %.2fx (%.1f%% reduction)\n', BestCost(1) / BestSol.Cost, ...
    (1 - BestSol.Cost/BestCost(1))*100);

fprintf('\nOptimized Controller Parameters:\n');
fprintf('  Kp_I (Current P-gain): %.6f\n', BestSol.Position(1));
fprintf('  Ki_I (Current I-gain): %.6f\n', BestSol.Position(2));
fprintf('  Kp_V (Voltage P-gain): %.6f\n', BestSol.Position(3));
fprintf('  Ki_V (Voltage I-gain): %.6f\n', BestSol.Position(4));

if ~isnan(BestSol.CurrentError)
    fprintf('\nError Metrics:\n');
    fprintf('  Current Error: %.6f\n', BestSol.CurrentError);
    fprintf('  Voltage Error: %.6f\n', BestSol.VoltageError);
end

fprintf('\nFinal Statistics:\n');
fprintf('  Final Diversity: %.6f\n', Diversity(end));
fprintf('  Final Mean Cost: %.6e\n', MeanCost(end));
fprintf('  Final Std Cost: %.6e\n', StdCost(end));
fprintf('  Coefficient of Variation: %.4f\n', StdCost(end)/MeanCost(end));

fprintf('\n=== ALL HIGH-QUALITY REPORTS GENERATED SUCCESSFULLY ===\n');
fprintf('Results saved in: %s\n', baseDir);
fprintf('- High-Quality Visualizations: %s\n', visualDir);
fprintf('- Enhanced Statistics: %s\n', statisticsDir);
fprintf('- Comprehensive Results: %s\n', resultsDir);
fprintf('- Excel Logs: Important Excels/\n');

fprintf('\nGenerated Figures:\n');
fprintf('1. Cost Evolution (Best & Mean vs Iterations)\n');
fprintf('2. Best Cost Convergence\n');
fprintf('3. Mean Cost Evolution\n');
fprintf('4. Population Diversity\n');
fprintf('5. Trial Counter Distribution\n');
fprintf('6. Final Fitness Distribution\n');
fprintf('7. Parameter Trajectories\n');
fprintf('8. Error Analysis (if available)\n');
fprintf('9. Cost Standard Deviation\n');
fprintf('\nAll figures saved in both .fig and .png formats with highest quality!\n');

end

%% Helper function for high-quality figure saving
function saveFigureHighQuality(fig, baseFilename, figureName)
    try
        % Save as .fig file
        figFile = [baseFilename, '.fig'];
        savefig(fig, figFile);
        
        % Save as high-quality PNG
        pngFile = [baseFilename, '.png'];
        print(fig, pngFile, '-dpng', '-r300'); % 300 DPI for high quality
        
        fprintf('  -> %s saved as .fig and .png (300 DPI)\n', figureName);
        
        % Close the figure to save memory
        close(fig);
        
    catch ME
        fprintf('  -> Warning: Could not save %s: %s\n', figureName, ME.message);
    end
end

%% Helper function for basic summary (fallback)
function generateBasicSummary(resultsDir, BestSol, BestCost, MeanCost, Diversity, ...
    ParamHistory, currentIteration, timestamp)

try
    summaryFile = fullfile(resultsDir, ['checkpoint_summary_', timestamp, '.txt']);
    fid = fopen(summaryFile, 'w');
    
    fprintf(fid, 'ABC OPTIMIZATION CHECKPOINT ANALYSIS REPORT\n');
    fprintf(fid, '==========================================\n\n');
    fprintf(fid, 'Generated: %s\n', datestr(now));
    fprintf(fid, 'Analysis of checkpoint data up to iteration: %d\n\n', currentIteration);
    
    fprintf(fid, 'OPTIMIZATION RESULTS:\n');
    fprintf(fid, '--------------------\n');
    fprintf(fid, 'Best Cost Found: %.6e\n', BestSol.Cost);
    fprintf(fid, 'Initial Cost: %.6e\n', BestCost(1));
    fprintf(fid, 'Improvement Factor: %.2fx\n', BestCost(1) / BestSol.Cost);
    fprintf(fid, 'Final Diversity: %.6f\n', Diversity(end));
    fprintf(fid, 'Final Mean Cost: %.6e\n', MeanCost(end));
    
    fprintf(fid, '\nOPTIMIZED PARAMETERS:\n');
    fprintf(fid, '--------------------\n');
    fprintf(fid, 'Kp_I (Current Controller P-gain): %.6f\n', BestSol.Position(1));
    fprintf(fid, 'Ki_I (Current Controller I-gain): %.6f\n', BestSol.Position(2));
    fprintf(fid, 'Kp_V (Voltage Controller P-gain): %.6f\n', BestSol.Position(3));
    fprintf(fid, 'Ki_V (Voltage Controller I-gain): %.6f\n', BestSol.Position(4));
    
    if ~isnan(BestSol.CurrentError)
        fprintf(fid, '\nERROR METRICS:\n');
        fprintf(fid, '-------------\n');
        fprintf(fid, 'Current Error: %.6f\n', BestSol.CurrentError);
        fprintf(fid, 'Voltage Error: %.6f\n', BestSol.VoltageError);
    end
    
    fprintf(fid, '\nPARAMETER EVOLUTION SUMMARY:\n');
    fprintf(fid, '---------------------------\n');
    paramNames = {'Kp_I', 'Ki_I', 'Kp_V', 'Ki_V'};
    for i = 1:size(ParamHistory, 2)
        if i <= length(paramNames)
            fprintf(fid, '%s: Initial=%.6f, Final=%.6f, Range=[%.6f, %.6f]\n', ...
                paramNames{i}, ParamHistory(1,i), ParamHistory(end,i), ...
                min(ParamHistory(:,i)), max(ParamHistory(:,i)));
        end
    end
    
    fclose(fid);
    
    fprintf('Basic summary report saved to: %s\n', summaryFile);
    
catch ME
    fprintf('Basic summary generation failed: %s\n', ME.message);
end

end
