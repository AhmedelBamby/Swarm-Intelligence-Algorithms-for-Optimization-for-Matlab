function SaveAndPlotResults(BestCost, MeanCost, Diversity, C, ParamHistory, varargin)
% =====================================================================
% ENHANCED SAVE AND PLOT RESULTS
% =====================================================================
% This function visualizes and saves optimization results from ABC algorithm.
%
% Inputs (required):
%   - BestCost     : Best cost values per iteration (vector)
%   - MeanCost     : Mean cost values per iteration (vector)
%   - Diversity    : Population diversity metric per iteration (vector)
%   - C            : Trial counters for each bee (vector)
%   - ParamHistory : Parameter trajectories (matrix: iterations x params)
%
% Optional Inputs (varargin):
%   - allCurrentErrors : Current errors for all solutions (vector)
%   - allVoltageErrors : Voltage errors for all solutions (vector)
%   - allTotalErrors   : Total errors for all solutions (vector)
%
% Outputs:
%   - Saves figures in timestamped 'Important Plots/{figs,plots}' directories
%   - Displays all generated figures
% =====================================================================

%% ========================
% Enhanced Directory Setup
% ========================
timestamp = datestr(now, 'yyyy_mm_dd_HHMMSS');
baseDir = 'Important Plots';
figDir = fullfile(baseDir, ['figs_', timestamp]);
pngDir = fullfile(baseDir, ['plots_', timestamp]);

if ~exist(figDir, 'dir')
    mkdir(figDir);
end
if ~exist(pngDir, 'dir')
    mkdir(pngDir);
end

fprintf('Results will be saved in:\n  FIG: %s\n  PNG: %s\n\n', figDir, pngDir);

%% ========================
% Original Plots (Maintained for Backward Compatibility)
% ========================
% Plot 1: Best Cost Convergence
f1 = figure('Name', 'Best Cost Convergence', 'NumberTitle', 'off');
semilogy(BestCost, 'b', 'LineWidth', 2);
xlabel('Iteration', 'FontWeight', 'bold');
ylabel('Best Cost (log scale)', 'FontWeight', 'bold');
title('Best Cost vs. Iterations', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
saveFigures(f1, 'BestCost', figDir, pngDir);

% Plot 2: Mean Cost Evolution
f2 = figure('Name', 'Mean Cost Evolution', 'NumberTitle', 'off');
plot(MeanCost, 'g', 'LineWidth', 2);
xlabel('Iteration', 'FontWeight', 'bold');
ylabel('Mean Cost', 'FontWeight', 'bold');
title('Mean Cost vs. Iterations', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
saveFigures(f2, 'MeanCost', figDir, pngDir);

% Plot 3: Population Diversity
f3 = figure('Name', 'Population Diversity', 'NumberTitle', 'off');
plot(Diversity, 'm', 'LineWidth', 2);
xlabel('Iteration', 'FontWeight', 'bold');
ylabel('Diversity (Euclidean Distance)', 'FontWeight', 'bold');
title('Population Diversity vs. Iterations', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
saveFigures(f3, 'Diversity', figDir, pngDir);

% Plot 4: Trial Counter Analysis
f4 = figure('Name', 'Trial Counter Distribution', 'NumberTitle', 'off');
histogram(C, 'FaceColor', 'c', 'BinMethod', 'integers');
xlabel('Number of Trials', 'FontWeight', 'bold');
ylabel('Bee Count', 'FontWeight', 'bold');
title('Histogram of Trial Counters', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
saveFigures(f4, 'TrialHistogram', figDir, pngDir);

% Plot 5: Final Fitness Distribution
f5 = figure('Name', 'Final Fitness Distribution', 'NumberTitle', 'off');
FinalCosts = exp(-BestCost / mean(BestCost));
histogram(FinalCosts, 20, 'FaceColor', 'y', 'EdgeColor', 'k');
xlabel('Fitness Value', 'FontWeight', 'bold');
ylabel('Frequency', 'FontWeight', 'bold');
title('Final Fitness Distribution', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
saveFigures(f5, 'FinalFitness', figDir, pngDir);

% Plot 6: Parameter Trajectories
f6 = figure('Name', 'Parameter Trajectories', 'NumberTitle', 'off');
hold on;
colors = lines(size(ParamHistory, 2));
for i = 1:size(ParamHistory, 2)
    plot(ParamHistory(:, i), 'Color', colors(i,:), 'LineWidth', 1.5);
end
hold off;
xlabel('Iteration', 'FontWeight', 'bold');
ylabel('Parameter Value', 'FontWeight', 'bold');
title('Parameter Trajectories', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
legend(arrayfun(@(x) sprintf('Param %d', x), 1:size(ParamHistory, 2), 'UniformOutput', false), ...
       'Location', 'bestoutside');
saveFigures(f6, 'ParamTrajectory', figDir, pngDir);

%% ========================
% New Error Analysis Plots (Conditional)
% ========================
if nargin >= 8 % Check if error data was provided
    allCurrentErrors = varargin{1};
    allVoltageErrors = varargin{2};
    allTotalErrors = varargin{3};
    
    % Plot 7: Current Error Distribution
    f7 = figure('Name', 'Current Error Distribution', 'NumberTitle', 'off');
    histogram(allCurrentErrors, 'FaceColor', 'r');
    xlabel('Current Error', 'FontWeight', 'bold');
    ylabel('Frequency', 'FontWeight', 'bold');
    title('Distribution of Current Errors', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
    saveFigures(f7, 'CurrentErrorDistribution', figDir, pngDir);
    
    % Plot 8: Voltage Error Distribution
    f8 = figure('Name', 'Voltage Error Distribution', 'NumberTitle', 'off');
    histogram(allVoltageErrors, 'FaceColor', 'b');
    xlabel('Voltage Error', 'FontWeight', 'bold');
    ylabel('Frequency', 'FontWeight', 'bold');
    title('Distribution of Voltage Errors', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
    saveFigures(f8, 'VoltageErrorDistribution', figDir, pngDir);
    
    % Plot 9: Error Correlation
    f9 = figure('Name', 'Error Correlation', 'NumberTitle', 'off');
    scatter(allCurrentErrors, allVoltageErrors, 10, allTotalErrors, 'filled');
    colorbar;
    xlabel('Current Error', 'FontWeight', 'bold');
    ylabel('Voltage Error', 'FontWeight', 'bold');
    title('Error Correlation (Color: Total Error)', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
    saveFigures(f9, 'ErrorCorrelation', figDir, pngDir);
end

%% ========================
% Display All Figures
% ========================
allFigs = findall(groot, 'Type', 'Figure');
for figHandle = allFigs'
    figure(figHandle);
end

fprintf('All plots saved to:\n%s\n%s\n', figDir, pngDir);

%% ========================
% Helper Function
% ========================
    function saveFigures(fig, name, figDir, pngDir)
        savefig(fig, fullfile(figDir, [name, '.fig']));
        saveas(fig, fullfile(pngDir, [name, '.png']), 'png');
    end
end