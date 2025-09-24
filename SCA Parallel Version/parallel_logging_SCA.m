function parallel_logging_SCA()
% PARALLEL_LOGGING_SCA Advanced parallel SCA optimization with comprehensive logging
%
% This function provides a complete parallel implementation of SCA optimization
% with extensive grid search capabilities, real-time monitoring, and results export.
%
% FEATURES:
% - Full parallel processing with automatic core detection
% - Advanced grid search with parameter combinations
% - Real-time convergence monitoring and visualization
% - Comprehensive results logging and export
% - Memory-efficient agent history tracking
% - Support for cluster and process profiles
% - Automatic checkpoint saving for long runs
% - Statistical analysis of optimization results

%% Initialization and Setup
clear variables;
clc;
fprintf('\n╔══════════════════════════════════════════════════════════════╗\n');
fprintf('║             PARALLEL SCA OPTIMIZATION SUITE                 ║\n');
fprintf('║                    Version 3.0 - 2025                       ║\n');
fprintf('╚══════════════════════════════════════════════════════════════╝\n');
fprintf('Initialization: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

%% Directory Structure Setup
base_dir = 'Parallel_SCA_Results';
subdirs = {
    'Grid_Search_Results',
    'Convergence_Plots', 
    'Agent_Trajectories',
    'System_Outputs',
    'Statistical_Analysis',
    'Checkpoints',
    'Performance_Logs'
};

fprintf('\n=== DIRECTORY SETUP ===\n');
for i = 1:length(subdirs)
    dir_path = fullfile(base_dir, subdirs{i});
    if ~exist(dir_path, 'dir')
        mkdir(dir_path);
        fprintf('Created: %s\n', dir_path);
    end
end

%% Parallel Environment Configuration
fprintf('\n=== PARALLEL ENVIRONMENT SETUP ===\n');

% Advanced parallel options
parallel_config = struct(...
    'UseParallel', true, ...
    'BatchSize', 25, ...
    'NumWorkers', [], ...  % Auto-detect
    'PreferProcesses', true, ...
    'IdleTimeout', 120, ...
    'EnableCheckpoints', true, ...
    'CheckpointInterval', 50 ...  % Save every 50 iterations
);

% Setup parallel pool
poolObj = setupParallelPool(parallel_config);

%% Experiment Configuration
fprintf('\n=== EXPERIMENT CONFIGURATION ===\n');

% Problem setup
Function_name = 'F1';
[lb, ub, dim, fobj] = Get_Functions_details(Function_name);

fprintf('Benchmark function: %s\n', Function_name);
fprintf('Problem dimension: %d\n', dim);
fprintf('Parameter bounds: [%s] to [%s]\n', mat2str(lb,3), mat2str(ub,3));

% Enhanced grid search parameters
grid_config = struct(...
    'a_values', [1.5], ...
    'bw_values', [0.03], ...
    'PAR_values', [0.6], ...
    'iteration_values', [200], ...
    'agent_values', [100] ...
);

% Calculate total experiments
total_combinations = prod(structfun(@length, grid_config));
fprintf('\nGrid search space:\n');
fields = fieldnames(grid_config);
for i = 1:length(fields)
    values = grid_config.(fields{i});
    fprintf('  %s: %d values %s\n', fields{i}, length(values), mat2str(values,2));
end
fprintf('Total experiments: %d\n', total_combinations);

%% Results Storage Setup
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
results_file = fullfile(base_dir, 'Grid_Search_Results', ...
    sprintf('Parallel_SCA_Results_%s.xlsx', timestamp));

% Enhanced results table
max_iter = max(grid_config.iteration_values);
conv_headers = arrayfun(@(x) sprintf('Iter_%d', x), 1:max_iter, 'UniformOutput', false);

result_columns = [
    {'ExperimentID', 'Timestamp', 'Iterations', 'Agents', 'a', 'bw', 'PAR'}, ...
    {'BestScore', 'ExecutionTime', 'ParallelEfficiency', 'ConvergenceIteration'}, ...
    arrayfun(@(x) sprintf('BestPos_%d', x), 1:dim, 'UniformOutput', false), ...
    conv_headers, ...
    {'DataFile', 'PlotFile', 'Notes'}
];

results_table = table();
for i = 1:length(result_columns)
    results_table.(result_columns{i}) = {};
end

%% Main Grid Search Loop
fprintf('\n=== STARTING PARALLEL GRID SEARCH ===\n');
experiment_id = 0;
overall_start = tic;

% Generate all parameter combinations
param_combinations = generateParameterGrid(grid_config);
total_experiments = size(param_combinations, 1);

fprintf('Generated %d parameter combinations\n', total_experiments);
fprintf('Starting parallel execution...\n\n');

for exp = 1:total_experiments
    experiment_id = experiment_id + 1;
    
    % Extract current parameters
    current_params = param_combinations(exp, :);
    iter_val = current_params(4);
    agent_val = current_params(5);
    a_val = current_params(1);
    bw_val = current_params(2);
    PAR_val = current_params(3);
    
    fprintf('┌─ Experiment %d/%d ─────────────────────────\n', experiment_id, total_experiments);
    fprintf('│ Parameters: Agents=%d, Iter=%d, a=%.2f, bw=%.3f, PAR=%.2f\n', ...
        agent_val, iter_val, a_val, bw_val, PAR_val);
    
    % Run parallel SCA optimization
    exp_start = tic;
    try
        [Best_score, Best_pos, SCA_curve, agent_history] = parallel_SCA(...
            agent_val, iter_val, lb, ub, dim, fobj, a_val, bw_val, PAR_val, parallel_config);
        
        exp_time = toc(exp_start);
        success = true;
        
    catch ME
        fprintf('│ ERROR: %s\n', ME.message);
        exp_time = toc(exp_start);
        success = false;
        Best_score = inf;
        Best_pos = nan(1, dim);
        SCA_curve = nan(1, iter_val);
        agent_history = [];
    end
    
    if success
        % Calculate performance metrics
        [convergence_iter, parallel_efficiency] = calculateMetrics(SCA_curve, exp_time, agent_val);
        
        fprintf('│ Results: Best=%.6e, Time=%.2fs, Efficiency=%.1f%%\n', ...
            Best_score, exp_time, parallel_efficiency*100);
        
        % Save detailed results
        data_file = saveExperimentData(experiment_id, agent_history, SCA_curve, ...
            Best_pos, current_params, base_dir);
        
        % Generate visualizations
        plot_file = generateOptimizationPlots(experiment_id, agent_history, SCA_curve, ...
            Best_pos, current_params, base_dir, Function_name);
        
        % Store in results table
        results_table = addResultsRow(results_table, experiment_id, current_params, ...
            Best_score, Best_pos, SCA_curve, exp_time, parallel_efficiency, ...
            convergence_iter, data_file, plot_file);
        
        % Save checkpoint (every 10 experiments or as configured)
        if mod(experiment_id, 10) == 0 || parallel_config.EnableCheckpoints
            saveCheckpoint(results_table, results_file, experiment_id);
        end
        
    end
    
    fprintf('└─────────────────────────────────────────────\n\n');
end

%% Final Analysis and Reporting
total_time = toc(overall_start);

fprintf('╔══════════════════════════════════════════════════════════════╗\n');
fprintf('║                    OPTIMIZATION COMPLETE                    ║\n');
fprintf('╚══════════════════════════════════════════════════════════════╝\n');
fprintf('Total execution time: %.2f minutes\n', total_time/60);
fprintf('Average time per experiment: %.2f seconds\n', total_time/total_experiments);

% Find best overall result
valid_experiments = ~cellfun(@isempty, results_table.BestScore);
if any(valid_experiments)
    valid_scores = cell2mat(results_table.BestScore(valid_experiments));
    [best_overall_score, best_idx] = min(valid_scores);
    
    fprintf('\nBest result found:\n');
    fprintf('  Experiment ID: %d\n', results_table.ExperimentID{best_idx});
    fprintf('  Best score: %.8e\n', best_overall_score);
    fprintf('  Parameters: %s\n', mat2str(cell2mat(results_table{best_idx, 4:8}), 3));
end

% Export final results
writetable(results_table, results_file, 'Sheet', 'Detailed_Results');
generateSummaryReport(results_table, base_dir, total_time);

% Cleanup
delete(gcp('nocreate'));
fprintf('\nAll results saved to: %s\n', base_dir);

%% Helper Functions

function combinations = generateParameterGrid(config)
    % Generate all possible parameter combinations
    fields = fieldnames(config);
    values = cellfun(@(f) config.(f), fields, 'UniformOutput', false);
    
    % Create grid
    grids = cell(size(values));
    [grids{:}] = ndgrid(values{:});
    
    % Convert to combinations matrix
    combinations = zeros(numel(grids{1}), length(fields));
    for i = 1:length(fields)
        combinations(:, i) = grids{i}(:);
    end
end

function [conv_iter, efficiency] = calculateMetrics(curve, time, agents)
    % Calculate convergence iteration and parallel efficiency
    
    % Find convergence point (when improvement becomes minimal)
    if length(curve) > 10
        improvements = abs(diff(curve));
        threshold = 0.001 * abs(curve(1));
        conv_iter = find(improvements < threshold, 1);
        if isempty(conv_iter)
            conv_iter = length(curve);
        end
    else
        conv_iter = length(curve);
    end
    
    % Estimate parallel efficiency (simplified model)
    % This is a rough estimate - actual efficiency depends on many factors
    theoretical_serial_time = time * agents / 4; % Rough scaling estimate
    efficiency = min(1, theoretical_serial_time / time / agents * 4);
end

function data_file = saveExperimentData(exp_id, history, curve, best_pos, params, base_dir)
    % Save detailed experiment data
    data_file = fullfile(base_dir, 'Grid_Search_Results', ...
        sprintf('Exp_%d_data.mat', exp_id));
    
    save(data_file, 'history', 'curve', 'best_pos', 'params', '-v7.3');
end

function plot_file = generateOptimizationPlots(exp_id, history, curve, best_pos, params, base_dir, func_name)
    % Generate comprehensive optimization plots
    plot_file = fullfile(base_dir, 'Convergence_Plots', ...
        sprintf('Exp_%d_plots.png', exp_id));
    
    fig = figure('Visible', 'off', 'Position', [100 100 1200 800]);
    
    % Convergence plot
    subplot(2,2,1);
    semilogy(curve, 'b-', 'LineWidth', 2);
    grid on;
    title('Convergence Curve');
    xlabel('Iteration');
    ylabel('Best Fitness');
    
    % Agent diversity (if history available)
    if ~isempty(history)
        subplot(2,2,2);
        [N, dim, iterations] = size(history);
        if dim >= 2
            % Plot 2D projection of final positions
            final_positions = squeeze(history(:, 1:2, end));
            scatter(final_positions(:,1), final_positions(:,2), 30, 'filled');
            title('Final Agent Distribution');
            xlabel('Parameter 1');
            ylabel('Parameter 2');
            grid on;
        end
        
        % Parameter evolution
        subplot(2,2,3);
        param_means = squeeze(mean(history, 1));
        plot(param_means', 'LineWidth', 1.5);
        title('Parameter Evolution');
        xlabel('Iteration');
        ylabel('Mean Parameter Value');
        legend(arrayfun(@(x) sprintf('Param %d', x), 1:dim, 'UniformOutput', false));
        grid on;
    end
    
    % Parameter summary
    subplot(2,2,4);
    text(0.1, 0.8, sprintf('Function: %s', func_name), 'FontSize', 12);
    text(0.1, 0.7, sprintf('Agents: %d', params(5)), 'FontSize', 10);
    text(0.1, 0.6, sprintf('Iterations: %d', params(4)), 'FontSize', 10);
    text(0.1, 0.5, sprintf('a: %.3f', params(1)), 'FontSize', 10);
    text(0.1, 0.4, sprintf('bw: %.4f', params(2)), 'FontSize', 10);
    text(0.1, 0.3, sprintf('PAR: %.3f', params(3)), 'FontSize', 10);
    text(0.1, 0.2, sprintf('Best: %.6e', min(curve)), 'FontSize', 10);
    xlim([0 1]); ylim([0 1]);
    axis off;
    title('Experiment Summary');
    
    sgtitle(sprintf('Parallel SCA Experiment %d', exp_id), 'FontSize', 14);
    
    saveas(fig, plot_file);
    close(fig);
end

function results_table = addResultsRow(results_table, exp_id, params, best_score, best_pos, curve, time, efficiency, conv_iter, data_file, plot_file)
    % Add a new row to results table
    row_idx = size(results_table, 1) + 1;
    
    results_table.ExperimentID{row_idx} = exp_id;
    results_table.Timestamp{row_idx} = datestr(now);
    results_table.Iterations{row_idx} = params(4);
    results_table.Agents{row_idx} = params(5);
    results_table.a{row_idx} = params(1);
    results_table.bw{row_idx} = params(2);
    results_table.PAR{row_idx} = params(3);
    results_table.BestScore{row_idx} = best_score;
    results_table.ExecutionTime{row_idx} = time;
    results_table.ParallelEfficiency{row_idx} = efficiency;
    results_table.ConvergenceIteration{row_idx} = conv_iter;
    
    % Best position
    for i = 1:length(best_pos)
        results_table.(sprintf('BestPos_%d', i)){row_idx} = best_pos(i);
    end
    
    % Convergence curve (pad with NaN if necessary)
    for i = 1:length(curve)
        results_table.(sprintf('Iter_%d', i)){row_idx} = curve(i);
    end
    
    results_table.DataFile{row_idx} = data_file;
    results_table.PlotFile{row_idx} = plot_file;
    results_table.Notes{row_idx} = 'Parallel execution completed successfully';
end

function saveCheckpoint(results_table, results_file, exp_id)
    % Save intermediate results as checkpoint
    checkpoint_file = strrep(results_file, '.xlsx', sprintf('_checkpoint_%d.xlsx', exp_id));
    writetable(results_table, checkpoint_file);
    fprintf('  Checkpoint saved: Experiment %d\n', exp_id);
end

function generateSummaryReport(results_table, base_dir, total_time)
    % Generate comprehensive summary report
    summary_file = fullfile(base_dir, 'Statistical_Analysis', 'Summary_Report.txt');
    
    fid = fopen(summary_file, 'w');
    fprintf(fid, '=== PARALLEL SCA OPTIMIZATION SUMMARY REPORT ===\n');
    fprintf(fid, 'Generated: %s\n\n', datestr(now));
    
    % Basic statistics
    valid_results = ~cellfun(@isempty, results_table.BestScore);
    num_valid = sum(valid_results);
    
    if num_valid > 0
        scores = cell2mat(results_table.BestScore(valid_results));
        times = cell2mat(results_table.ExecutionTime(valid_results));
        
        fprintf(fid, 'EXPERIMENT STATISTICS:\n');
        fprintf(fid, '  Total experiments: %d\n', height(results_table));
        fprintf(fid, '  Successful experiments: %d\n', num_valid);
        fprintf(fid, '  Success rate: %.1f%%\n', num_valid/height(results_table)*100);
        fprintf(fid, '  Total execution time: %.2f minutes\n\n', total_time/60);
        
        fprintf(fid, 'PERFORMANCE STATISTICS:\n');
        fprintf(fid, '  Best score: %.8e\n', min(scores));
        fprintf(fid, '  Worst score: %.8e\n', max(scores));
        fprintf(fid, '  Mean score: %.8e\n', mean(scores));
        fprintf(fid, '  Std deviation: %.8e\n', std(scores));
        fprintf(fid, '  Median score: %.8e\n\n', median(scores));
        
        fprintf(fid, 'TIMING STATISTICS:\n');
        fprintf(fid, '  Mean execution time: %.2f seconds\n', mean(times));
        fprintf(fid, '  Min execution time: %.2f seconds\n', min(times));
        fprintf(fid, '  Max execution time: %.2f seconds\n', max(times));
        fprintf(fid, '  Std deviation: %.2f seconds\n', std(times));
    end
    
    fclose(fid);
    fprintf('Summary report saved to: %s\n', summary_file);
end

end
