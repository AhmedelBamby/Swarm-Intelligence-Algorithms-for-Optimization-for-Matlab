function logging_SCA()
% ======================================================================
% ENHANCED SCA OPTIMIZATION WITH GRID SEARCH & DATA LOGGING
% Features:
%   - Comprehensive parameter grid search
%   - Automatic saving of agent positions (K1-K4) for each iteration
%   - New visualization showing all agents' convergence with best agent highlighted
%   - Results export to Excel with timestamps
%   - Simulink-compatible output format
%
% OUTPUTS:
%   - SCA_GridSearch_Results/ : Folder containing optimization results
%   - plot_results/ : Folder containing visualization plots
%   - agent_convergence/ : Folder containing agent convergence plots
%   - System_Simulation_Outputs/ : Folder containing gain values (K1-K4)
%
% USAGE:
%   1. Configure grid search parameters (a_values, bw_values, etc.)
%   2. Run logging_SCA()
%   3. Results are automatically saved in timestamped folders
% ======================================================================

%% Initialization
clear variables;
clc;

fprintf('\n=== SCA OPTIMIZATION WITH ADVANCED GRID SEARCH ===\n');
fprintf('Initialization timestamp: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

%% Directory Setup
resultsFolder = 'SCA_GridSearch_Results';
plotFolder = 'plot_results';
convergenceFolder = 'agent_convergence';
simOutputFolder = 'System_Simulation_Outputs';

% Create directories if they don't exist
dirs = {resultsFolder, plotFolder, convergenceFolder, simOutputFolder};
for i = 1:length(dirs)
    if ~exist(dirs{i}, 'dir')
        mkdir(dirs{i});
        fprintf('Created directory: %s\n', dirs{i});
    end
end

% Results filename with timestamp
resultFilename = fullfile(resultsFolder, ...
    sprintf('SCA_GridSearch_%s.xlsx', datestr(now, 'yyyy-mm-dd_HH-MM-SS')));
fprintf('Results will be saved to: %s\n', resultFilename);

%% Experiment Configuration
Function_name = 'F1';  % Benchmark function
fprintf('\nLoading benchmark function: %s\n', Function_name);

% Get function details
[lb, ub, dim, fobj] = Get_Functions_details(Function_name);  
fprintf('Function loaded successfully. Dimension: %d\n', dim);
fprintf('Parameter bounds:\n  Lower: %s\n  Upper: %s\n', mat2str(lb), mat2str(ub));

experimentNotes = 'Grid search for SCA params and hyperparameters';
fprintf('\nExperiment Notes: %s\n', experimentNotes);

%% Grid Search Configuration
% Parameter ranges to test (modify these for your experiments)
a_values = [2];          % SCA parameter a
bw_values = [0.05];      % Bandwidth values
PAR_values = [0.7];      % Pitch adjustment rate
iteration_values = [250];  % Iteration counts to test
agent_values = [150];      % Population sizes to test

% Display configuration
fprintf('\n=== GRID SEARCH CONFIGURATION ===\n');
fprintf('Parameter Space Dimensions:\n');
fprintf('  a_values: %d values (%s)\n', length(a_values), mat2str(a_values));
fprintf('  bw_values: %d values (%s)\n', length(bw_values), mat2str(bw_values));
fprintf('  PAR_values: %d values (%s)\n', length(PAR_values), mat2str(PAR_values));
fprintf('  iteration_values: %d values (%s)\n', length(iteration_values), mat2str(iteration_values));
fprintf('  agent_values: %d values (%s)\n', length(agent_values), mat2str(agent_values));

totalExperiments = length(a_values)*length(bw_values)*length(PAR_values)*...
    length(iteration_values)*length(agent_values);
fprintf('\nTotal experiments to run: %d\n', totalExperiments);

%% Prepare Results Storage
max_iter = max(iteration_values);

% Create headers for convergence curve data
conv_curve_headers = arrayfun(@(x) sprintf('Iter_%d', x), 1:max_iter, 'UniformOutput', false);

% Define table structure for results
varNames = [{'Iterations','Agents','a','bw','PAR','BestScore','ExecutionTime'}, ...
            arrayfun(@(x) sprintf('BestPosition_%d', x), 1:dim, 'UniformOutput', false), ...
            conv_curve_headers];
varTypes = [repmat({'double'}, 1, 7+dim), repmat({'double'}, 1, max_iter)];

% Initialize results table
resultsTable = table('Size', [totalExperiments, length(varTypes)], ...
                    'VariableTypes', varTypes, ...
                    'VariableNames', varNames);
resultsTable.AgentHistoryFile = repmat({''}, totalExperiments, 1);

%% Grid Search Execution
experimentCount = 0;
startTime = tic;

for iter_val = iteration_values
    for agent_val = agent_values
        for a = a_values
            for bw = bw_values
                for PAR = PAR_values
                    experimentCount = experimentCount + 1;
                    fprintf('\n=== Experiment %d/%d ===\n', experimentCount, totalExperiments);
                    fprintf('  Agents: %d, Iterations: %d\n', agent_val, iter_val);
                    fprintf('  a: %.2f, bw: %.3f, PAR: %.2f\n', a, bw, PAR);
                    
                    % Run SCA with current parameters
                    [Best_score, Best_pos, SCA_cg_curve, agent_history] = SCA(...
                        agent_val, iter_val, lb, ub, dim, fobj, a, bw, PAR);
                    
                    %% Save Agent History and Gain Values
                    % Save full agent history for visualization
                    historyFilename = fullfile(resultsFolder, ...
                        sprintf('agent_history_exp%d_%s.mat', experimentCount, ...
                        datestr(now, 'HHMMSS')));
                    save(historyFilename, 'agent_history', 'SCA_cg_curve', 'lb', 'ub', 'Best_pos');
                    resultsTable.AgentHistoryFile{experimentCount} = historyFilename;
                    
                    % Save gain values (K1-K4) for Simulink
                    saveGainValues(agent_history, simOutputFolder, experimentCount, iter_val);
                    
                    %% Create Agent Convergence Plot
                    plotAgentConvergence(agent_history, SCA_cg_curve, Best_pos, ...
                        convergenceFolder, experimentCount, agent_val, iter_val, a, bw, PAR);
                    
                    %% Store Results
                    % Basic experiment info
                    resultsTable.Iterations(experimentCount) = iter_val;
                    resultsTable.Agents(experimentCount) = agent_val;
                    resultsTable.a(experimentCount) = a;
                    resultsTable.bw(experimentCount) = bw;
                    resultsTable.PAR(experimentCount) = PAR;
                    resultsTable.BestScore(experimentCount) = Best_score;
                    resultsTable.ExecutionTime(experimentCount) = toc(startTime)/experimentCount;
                    
                    % Best position coordinates
                    for pos_idx = 1:dim
                        resultsTable.(sprintf('BestPosition_%d', pos_idx))(experimentCount) = ...
                            Best_pos(pos_idx);
                    end
                    
                    % Convergence curve (pad with NaNs if shorter than max_iter)
                    curve_length = length(SCA_cg_curve);
                    if curve_length < max_iter
                        SCA_cg_curve(end+1:max_iter) = NaN;
                    end
                    resultsTable{experimentCount, end-max_iter+1:end} = SCA_cg_curve;
                end
            end
        end
    end
end

%% Post-processing
[bestScore, bestIdx] = min(resultsTable.BestScore);
bestConfig = resultsTable(bestIdx,:);

fprintf('\nBest configuration found:\n');
disp(bestConfig(:,1:7));

%% Visualization
if exist('help_plot_sca', 'file') == 2
    try
        % Load best agent history
        load(bestConfig.AgentHistoryFile{1}, 'agent_history', 'SCA_cg_curve', 'lb', 'ub');
        
        % Plot best configuration
        fprintf('\nGenerating visualization for best configuration...\n');
        help_plot_sca(agent_history, SCA_cg_curve, lb, ub, ...
            'FunctionName', Function_name, ...
            'SaveFolder', plotFolder, ...
            'Prefix', 'Best_Configuration', ...
            'ExperimentID', sprintf('Exp%d', bestIdx));
        
        % Run final optimization with best parameters
        fprintf('\nRunning final optimization with best parameters...\n');
        [Final_score, Final_pos, Final_curve, Final_history] = SCA(...
            bestConfig.Agents, bestConfig.Iterations, lb, ub, dim, fobj, ...
            bestConfig.a, bestConfig.bw, bestConfig.PAR);
        
        % Plot final optimization
        help_plot_sca(Final_history, Final_curve, lb, ub, ...
            'FunctionName', Function_name, ...
            'SaveFolder', plotFolder, ...
            'Prefix', 'Final_Optimization');
    catch ME
        warning(ME.identifier , 'Visualization failed: %s', ME.message);
    end
else
    warning('help_plot_sca function not found - skipping visualizations');
end

%% Final Results Export
% Save agent history from final run
finalHistoryFile = fullfile(resultsFolder, 'final_agent_history.mat');
save(finalHistoryFile, 'Final_history', 'Final_curve', 'lb', 'ub');

% Create results structure
finalResults = struct(...
    'Date', datestr(now), ...
    'Function', Function_name, ...
    'BestScore', Final_score, ...
    'BestPosition', Final_pos, ...
    'Parameters', table2struct(bestConfig), ...
    'Notes', experimentNotes, ...
    'TotalRuntime', toc(startTime));

% Save to Excel
writetable(resultsTable, resultFilename, 'Sheet', 'GridSearchResults');
writetable(struct2table(finalResults, 'AsArray', true), resultFilename, 'Sheet', 'FinalResults');

%% Final Summary
fprintf('\n=== EXPERIMENT COMPLETE ===\n');
fprintf('Total runtime: %.2f seconds\n', toc(startTime));
fprintf('Best score achieved: %.6f\n', Final_score);
fprintf('Best position:\n');
disp(Final_pos);
fprintf('Results saved to: %s\n', resultFilename);
fprintf('Plots saved to: %s\n', plotFolder);
fprintf('Agent convergence plots saved to: %s\n', convergenceFolder);
fprintf('Gain values saved to: %s\n', simOutputFolder);

%% Nested Helper Functions
    function saveGainValues(agent_history, folder, exp_num, iter_num)
        % SAVEGAINVALUES Stores K1-K4 values for each agent and iteration
        % Inputs:
        %   agent_history - 3D array of agent positions (N x dim x iterations)
        %   folder - Output directory
        %   exp_num - Experiment number
        %   iter_num - Number of iterations
        
        % Create output filename
        filename = fullfile(folder, ...
            sprintf('Exp%d_Iter%d_Gains.xlsx', exp_num, iter_num));
        
        % Prepare data table
        data = table();
        
        % For each iteration
        for t = 1:size(agent_history, 3)
            % Get all agent positions at this iteration
            current_positions = squeeze(agent_history(:,:,t));
            
            % Add to table
            for agent = 1:size(current_positions, 1)
                data.(sprintf('Iter%d_Agent%d_K1', t, agent)) = current_positions(agent, 1);
                data.(sprintf('Iter%d_Agent%d_K2', t, agent)) = current_positions(agent, 2);
                data.(sprintf('Iter%d_Agent%d_K3', t, agent)) = current_positions(agent, 3);
                data.(sprintf('Iter%d_Agent%d_K4', t, agent)) = current_positions(agent, 4);
            end
        end
        
        % Save to Excel
        writetable(data, filename);
        fprintf('Saved gain values to: %s\n', filename);
    end

    function plotAgentConvergence(agent_history, SCA_cg_curve, Best_pos, folder, exp_num, N, max_iter, a, bw, PAR)
        % PLOTAGENTCONVERGENCE Creates convergence plot for all agents
        % Inputs:
        %   agent_history - 3D array of all agent positions
        %   SCA_cg_curve - Best fitness convergence curve
        %   Best_pos - Best agent's final position
        %   folder - Output directory
        %   exp_num - Experiment number
        %   N - Number of agents
        %   max_iter - Number of iterations
        %   a, bw, PAR - Algorithm parameters
        
        % Create figure
        fig = figure('Visible', 'off', 'Position', [100 100 800 600]);
        
        % Calculate fitness for all agents at all iterations
        all_fitness = zeros(N, max_iter);
        for iter = 1:max_iter
            for agent = 1:N
                all_fitness(agent, iter) = fobj(squeeze(agent_history(agent,:,iter)));
            end
        end
        
        % Plot all agents' convergence
        plot(1:max_iter, all_fitness', 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5);
        hold on;
        
        % Find and plot best agent's convergence
        [~, best_agent_idx] = min(all_fitness(:,end));
        plot(1:max_iter, all_fitness(best_agent_idx,:), 'b', 'LineWidth', 2);
        
        % Plot best solution (red circle)
        best_fitness = min(all_fitness(:,end));
        scatter(max_iter, best_fitness, 100, 'r', 'filled');
        
        % Add annotations
        title(sprintf('Agent Convergence (Exp %d)\nN=%d, Iter=%d, a=%.2f, bw=%.3f, PAR=%.2f', ...
            exp_num, N, max_iter, a, bw, PAR));
        xlabel('Iteration');
        ylabel('Fitness Value');
        grid on;
        
        legend_str = arrayfun(@(x) sprintf('Agent %d', x), 1:N, 'UniformOutput', false);
        legend_str{end+1} = 'Best Agent';
        legend_str{end+1} = 'Best Solution';
        legend(legend_str, 'Location', 'best');
        
        % Save figure
        filename = fullfile(folder, sprintf('Exp%d_AgentConvergence.png', exp_num));
        saveas(fig, filename);
        close(fig);
        fprintf('Saved agent convergence plot to: %s\n', filename);
    end
fprintf('\n=== SCA OPTIMIZATION WITH ADVANCED GRID SEARCH ===\n');
fprintf('Initialization timestamp: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
end