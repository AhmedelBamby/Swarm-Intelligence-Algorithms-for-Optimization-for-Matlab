function generateFinalReports(resultsDir, visualDir, statisticsDir, BestCost, MeanCost, ...
    StdCost, Diversity, ParamHistory, StatisticsHistory, timestamp)

%% ====================================================================
% GENERATE COMPREHENSIVE FINAL REPORTS - FIXED VERSION
% ====================================================================

fprintf('Generating final reports and visualizations...\n');

%% Statistical Analysis
fprintf('Computing statistical analysis...\n');

% Ensure all arrays are column vectors
BestCost = BestCost(:);
MeanCost = MeanCost(:);
StdCost = StdCost(:);
Diversity = Diversity(:);

% Convergence statistics
convergenceStats = struct();
convergenceStats.finalBestCost = BestCost(end);
convergenceStats.initialBestCost = BestCost(1);
convergenceStats.improvementRatio = BestCost(1) / BestCost(end);

% Calculate mean convergence rate safely
validBestCost = BestCost(BestCost > 0 & ~isnan(BestCost) & ~isinf(BestCost));
if length(validBestCost) > 1
    convergenceStats.meanConvergenceRate = mean(diff(log(validBestCost)));
else
    convergenceStats.meanConvergenceRate = 0;
end

% Find convergence point (95% of final improvement)
targetCost = BestCost(1) - 0.95 * (BestCost(1) - BestCost(end));
convergenceIter = find(BestCost <= targetCost, 1, 'first');
if isempty(convergenceIter)
    convergenceIter = length(BestCost);
end
convergenceStats.convergenceIteration = convergenceIter;

% Parameter statistics
paramStats = struct();
for i = 1:size(ParamHistory, 2)
    paramStats.(sprintf('param_%d_mean', i)) = mean(ParamHistory(:, i));
    paramStats.(sprintf('param_%d_std', i)) = std(ParamHistory(:, i));
    paramStats.(sprintf('param_%d_range', i)) = [min(ParamHistory(:, i)), max(ParamHistory(:, i))];
end

% Save statistics
statsFile = fullfile(statisticsDir, ['statistics_', timestamp, '.mat']);
save(statsFile, 'convergenceStats', 'paramStats');

%% Generate Comprehensive Plots
fprintf('Creating comprehensive visualizations...\n');

% Figure 1: Convergence Analysis - FIXED
f1 = figure('Position', [100, 100, 1200, 800]);

subplot(2,2,1);
semilogy(BestCost, 'b-', 'LineWidth', 2);
hold on;
plot(MeanCost, 'g--', 'LineWidth', 1.5);

% FIXED: Safe fill operation with proper bounds checking
upperBound = MeanCost + StdCost;
lowerBound = MeanCost - StdCost;

% Ensure positive values for log plot and same dimensions
upperBound = max(upperBound, eps); % Prevent negative values
lowerBound = max(lowerBound, eps);
upperBound = upperBound(:);
lowerBound = lowerBound(:);
xData = (1:length(MeanCost))';

try
    % Create fill area safely
    fill([xData; flipud(xData)], [upperBound; flipud(lowerBound)], ...
        'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
catch ME
    fprintf('Warning: Could not create fill area: %s\n', ME.message);
    plot(upperBound, 'r:', 'LineWidth', 1);
    plot(lowerBound, 'r:', 'LineWidth', 1);
end

xlabel('Iteration');
ylabel('Cost (log scale)');
title('Cost Convergence with Uncertainty');
legend('Best Cost', 'Mean Cost', '±1 STD', 'Location', 'best');
grid on;

subplot(2,2,2);
plot(Diversity, 'm-', 'LineWidth', 2);
xlabel('Iteration');
ylabel('Population Diversity');
title('Population Diversity Evolution');
grid on;

subplot(2,2,3);
plot(StdCost, 'c-', 'LineWidth', 2);
xlabel('Iteration');
ylabel('Cost Standard Deviation');
title('Population Cost Variability');
grid on;

subplot(2,2,4);
% FIXED: Safe improvement rate calculation
if length(BestCost) > 1
    improvementRate = -diff(BestCost);
    improvementRate(improvementRate < 0) = 0;
    plot(2:length(BestCost), improvementRate, 'k-', 'LineWidth', 1.5);
end
xlabel('Iteration');
ylabel('Improvement Rate');
title('Best Cost Improvement Rate');
grid on;

sgtitle('ABC Algorithm Convergence Analysis', 'FontSize', 16, 'FontWeight', 'bold');
saveas(f1, fullfile(visualDir, ['convergence_analysis_', timestamp, '.png']));
savefig(f1, fullfile(visualDir, ['convergence_analysis_', timestamp, '.fig']));

% Figure 2: Parameter Evolution - FIXED
f2 = figure('Position', [150, 150, 1200, 600]);
nParams = size(ParamHistory, 2);
paramNames = {'Kp_I', 'Ki_I', 'Kp_V', 'Ki_V'};

for i = 1:min(nParams, 4) % Limit to 4 subplots
    subplot(2, 2, i);
    plot(ParamHistory(:, i), 'LineWidth', 2);
    xlabel('Iteration');
    ylabel('Parameter Value');
    if i <= length(paramNames)
        title(sprintf('Evolution of %s', paramNames{i}));
    else
        title(sprintf('Evolution of Parameter %d', i));
    end
    grid on;
end

sgtitle('Parameter Evolution Throughout Optimization', 'FontSize', 16, 'FontWeight', 'bold');
saveas(f2, fullfile(visualDir, ['parameter_evolution_', timestamp, '.png']));
savefig(f2, fullfile(visualDir, ['parameter_evolution_', timestamp, '.fig']));

% Figure 3: Statistical Summary - FIXED
f3 = figure('Position', [200, 200, 1000, 800]);

% Cost distribution at different stages - FIXED
subplot(2,3,1);
try
    earlyIdx = min(10, length(StatisticsHistory));
    midIdx = round(length(StatisticsHistory)/2);
    lateIdx = length(StatisticsHistory);
    
    if ~isempty(StatisticsHistory{earlyIdx}) && isfield(StatisticsHistory{earlyIdx}, 'allCosts')
        earlyStats = StatisticsHistory{earlyIdx};
        midStats = StatisticsHistory{midIdx};
        lateStats = StatisticsHistory{lateIdx};
        
        histogram(earlyStats.allCosts, 'FaceAlpha', 0.7, 'DisplayName', 'Early (10%)');
        hold on;
        histogram(midStats.allCosts, 'FaceAlpha', 0.7, 'DisplayName', 'Middle (50%)');
        histogram(lateStats.allCosts, 'FaceAlpha', 0.7, 'DisplayName', 'Final (100%)');
        legend('Location', 'best');
    end
catch ME
    fprintf('Warning: Could not create cost distribution plot: %s\n', ME.message);
    text(0.5, 0.5, 'Cost Distribution\nData Unavailable', 'HorizontalAlignment', 'center');
end
xlabel('Cost Value');
ylabel('Frequency');
title('Cost Distribution Evolution');
grid on;

% Scout activity - FIXED
subplot(2,3,2);
try
    scoutActivity = zeros(length(StatisticsHistory), 1);
    for i = 1:length(StatisticsHistory)
        if ~isempty(StatisticsHistory{i}) && isfield(StatisticsHistory{i}, 'numScouts')
            scoutActivity(i) = StatisticsHistory{i}.numScouts;
        end
    end
    plot(scoutActivity, 'r-', 'LineWidth', 2);
catch ME
    fprintf('Warning: Could not create scout activity plot: %s\n', ME.message);
end
xlabel('Iteration');
ylabel('Number of Scouts');
title('Scout Bee Activity');
grid on;

% Error correlation - FIXED
subplot(2,3,3);
try
    if ~isempty(StatisticsHistory{end}) && ...
       isfield(StatisticsHistory{end}, 'currentErrors') && ...
       isfield(StatisticsHistory{end}, 'voltageErrors')
        
        finalCurrentErrors = StatisticsHistory{end}.currentErrors;
        finalVoltageErrors = StatisticsHistory{end}.voltageErrors;
        finalAllCosts = StatisticsHistory{end}.allCosts;
        
        scatter(finalCurrentErrors, finalVoltageErrors, 50, finalAllCosts, 'filled');
        colorbar;
    end
catch ME
    fprintf('Warning: Could not create error correlation plot: %s\n', ME.message);
end
xlabel('Current Error');
ylabel('Voltage Error');
title('Final Error Correlation');
grid on;

% Best cost improvement rate - FIXED
subplot(2,3,4);
try
    validBestCost = BestCost(BestCost > 0 & ~isnan(BestCost) & ~isinf(BestCost));
    if length(validBestCost) > 1
        logBestCost = log(validBestCost);
        improvementRate = -diff(logBestCost);
        plot(2:length(logBestCost), improvementRate, 'g-', 'LineWidth', 2);
    end
catch ME
    fprintf('Warning: Could not create improvement rate plot: %s\n', ME.message);
end
xlabel('Iteration');
ylabel('Log Cost Improvement Rate');
title('Logarithmic Improvement Rate');
grid on;

% Parameter correlation matrix - FIXED
subplot(2,3,5);
try
    if size(ParamHistory, 1) > 1 && size(ParamHistory, 2) > 1
        paramCorr = corrcoef(ParamHistory);
        imagesc(paramCorr);
        colorbar;
        if nParams <= length(paramNames)
            set(gca, 'XTick', 1:nParams, 'XTickLabel', paramNames(1:nParams));
            set(gca, 'YTick', 1:nParams, 'YTickLabel', paramNames(1:nParams));
        end
    end
catch ME
    fprintf('Warning: Could not create parameter correlation plot: %s\n', ME.message);
end
title('Parameter Correlation Matrix');

% Final parameter distribution - FIXED
subplot(2,3,6);
try
    finalParams = ParamHistory(end, :);
    bar(finalParams);
    xlabel('Parameter Index');
    ylabel('Final Value');
    title('Final Optimized Parameters');
    if nParams <= length(paramNames)
        set(gca, 'XTickLabel', paramNames(1:nParams));
    end
catch ME
    fprintf('Warning: Could not create final parameters plot: %s\n', ME.message);
end
grid on;

sgtitle('Statistical Analysis Summary', 'FontSize', 16, 'FontWeight', 'bold');
saveas(f3, fullfile(visualDir, ['statistical_summary_', timestamp, '.png']));
savefig(f3, fullfile(visualDir, ['statistical_summary_', timestamp, '.fig']));

%% Generate Excel Report - FIXED
fprintf('Creating Excel report...\n');

try
    excelFile = fullfile(resultsDir, ['optimization_report_', timestamp, '.xlsx']);
    
    % Summary sheet
    summaryData = {
        'Metric', 'Value';
        'Final Best Cost', BestCost(end);
        'Initial Best Cost', BestCost(1);
        'Improvement Ratio', convergenceStats.improvementRatio;
        'Convergence Iteration', convergenceStats.convergenceIteration;
        'Total Iterations', length(BestCost);
        'Final Diversity', Diversity(end);
        'Mean Final Cost', MeanCost(end);
        'Std Final Cost', StdCost(end);
    };
    
    writecell(summaryData, excelFile, 'Sheet', 'Summary');
    
    % Parameter evolution sheet
    paramData = [(1:length(BestCost))', BestCost, MeanCost, StdCost, Diversity, ParamHistory];
    paramHeaders = {'Iteration', 'BestCost', 'MeanCost', 'StdCost', 'Diversity', ...
        'Kp_I', 'Ki_I', 'Kp_V', 'Ki_V'};
    
    writecell([paramHeaders; num2cell(paramData)], excelFile, 'Sheet', 'Evolution');
    
    fprintf('Excel report created successfully!\n');
catch ME
    fprintf('Warning: Could not create Excel report: %s\n', ME.message);
end

fprintf('Reports generated successfully!\n');
fprintf('Files saved in:\n');
fprintf(' - Results: %s\n', resultsDir);
fprintf(' - Visualizations: %s\n', visualDir);
fprintf(' - Statistics: %s\n', statisticsDir);

% Close figures to free memory
close(f1); close(f2); close(f3);

end
