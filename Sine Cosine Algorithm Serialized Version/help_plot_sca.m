function varargout = help_plot_sca(all_agent_history, Convergence_curve, lb, ub, varargin)
% HELP_PLOT_SCA Enhanced visualization of SCA optimization results
%
% Enhanced Features:
% 1. Handles 1D, 2D, and 3+ dimensional problems
% 2. Creates both trajectory and convergence plots
% 3. Saves figures in multiple formats with timestamp
% 4. Returns file paths when requested
% 5. Detailed labeling with benchmark function names

    %% Input validation and parsing
    if nargin < 4
        error('Insufficient input arguments');
    end
    
    % Parse optional parameters
    p = inputParser;
    addParameter(p, 'SaveFolder', 'SCA_Plots', @ischar);
    addParameter(p, 'Prefix', 'SCA_Results', @ischar);
    addParameter(p, 'FunctionName', 'Unknown Function', @ischar);
    addParameter(p, 'ExperimentID', '', @ischar);
    addParameter(p, 'ShowPlots', true, @islogical);
    parse(p, varargin{:});
    
    saveFolder = p.Results.SaveFolder;
    filePrefix = p.Results.Prefix;
    funcName = p.Results.FunctionName;
    expID = p.Results.ExperimentID;
    showPlots = p.Results.ShowPlots;
    
    % Create output directory if needed
    if ~exist(saveFolder, 'dir')
        mkdir(saveFolder);
        fprintf('Created plot directory: %s\n', saveFolder);
    end
    
    %% Prepare filename with timestamp
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    if ~isempty(expID)
        filename = sprintf('%s_%s_%s', filePrefix, expID, timestamp);
    else
        filename = sprintf('%s_%s', filePrefix, timestamp);
    end
    fullPath = fullfile(saveFolder, filename);
    
    %% Extract problem dimensions
    [N, dim, max_iter] = size(all_agent_history);
    
    %% Create and configure figure
    fig = figure('Name', 'SCA Optimization Analysis', ...
        'Position', [100 100 1200 600], ...
        'Color', 'w', ...
        'NumberTitle', 'off', ...
        'Visible', iff(showPlots, 'on', 'off'));
    
    %% Plot 1: Agent Trajectories
    subplot(1,2,1);
    hold on;
    grid on;
    
    % Determine best agent (minimum fitness at last iteration)
    [~, best_idx] = min(squeeze(all_agent_history(:,1,end)));
    
    % Handle different dimensional cases
    if dim == 1
        % 1D Case - Plot as lines over iterations
        x_data = 1:max_iter;
        for i = 1:N
            plot(x_data, squeeze(all_agent_history(i,1,:)), ...
                'Color', iff(i==best_idx, [1 0 0], [0.7 0.7 0.7]), ...
                'LineWidth', iff(i==best_idx, 2, 0.5));
        end
        xlabel('Iteration');
        ylabel('Parameter Value');
        title('1D Parameter Evolution');
        
    elseif dim == 2
        % 2D Case
        x_path = squeeze(all_agent_history(:,1,:));
        y_path = squeeze(all_agent_history(:,2,:));
        
        % Plot all agents
        plot(x_path', y_path', 'Color', [0.7 0.7 0.7 0.3], 'LineWidth', 0.5);
        
        % Highlight best agent
        plot(x_path(best_idx,:), y_path(best_idx,:), 'r', 'LineWidth', 2);
        
        % Mark start and end points
        scatter(x_path(:,1), y_path(:,1), 40, 'g', 'filled');
        scatter(x_path(:,end), y_path(:,end), 40, 'b', 'filled');
        scatter(x_path(best_idx,1), y_path(best_idx,1), 60, 'g', 'filled', 'MarkerEdgeColor', 'k');
        scatter(x_path(best_idx,end), y_path(best_idx,end), 60, 'r', 'filled', 'MarkerEdgeColor', 'k');
        
        xlim([lb(1) ub(1)]); ylim([lb(2) ub(2)]);
        xlabel('X (Dim1)'); ylabel('Y (Dim2)');
        title('2D Agent Trajectories');
        
    else
        % 3D+ Case (plot first 3 dimensions)
        view(3);
        x_path = squeeze(all_agent_history(:,1,:));
        y_path = squeeze(all_agent_history(:,2,:));
        z_path = squeeze(all_agent_history(:,3,:));
        
        % Plot all agents
        plot3(x_path', y_path', z_path', 'Color', [0.7 0.7 0.7 0.3], 'LineWidth', 0.5);
        
        % Highlight best agent
        plot3(x_path(best_idx,:), y_path(best_idx,:), z_path(best_idx,:), 'r', 'LineWidth', 2);
        
        % Mark start and end points
        scatter3(x_path(:,1), y_path(:,1), z_path(:,1), 40, 'g', 'filled');
        scatter3(x_path(:,end), y_path(:,end), z_path(:,end), 40, 'b', 'filled');
        scatter3(x_path(best_idx,1), y_path(best_idx,1), z_path(best_idx,1), 60, 'g', 'filled', 'MarkerEdgeColor', 'k');
        scatter3(x_path(best_idx,end), y_path(best_idx,end), z_path(best_idx,end), 60, 'r', 'filled', 'MarkerEdgeColor', 'k');
        
        xlim([lb(1) ub(1)]); ylim([lb(2) ub(2)]); zlim([lb(3) ub(3)]);
        xlabel('X (Dim1)'); ylabel('Y (Dim2)'); zlabel('Z (Dim3)');
        title('3D Agent Trajectories (First 3 Dimensions)');
    end
    
    legend({'All agents', 'Start points', 'End points', 'Best agent'}, 'Location', 'best');
    
    %% Plot 2: Convergence Curve
    subplot(1,2,2);
    hold on;
    grid on;
    box on;
    
    % Plot convergence curve
    plot(Convergence_curve, 'b-', 'LineWidth', 2);
    
    % Mark best solution
    [best_fitness, best_iter] = min(Convergence_curve);
    scatter(best_iter, best_fitness, 100, 'r', 'filled', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 1);
    
    % Annotate best solution
    text(best_iter, best_fitness, ...
        sprintf(' Best: %.2e\n Iter: %d', best_fitness, best_iter), ...
        'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', ...
        'BackgroundColor', 'w', 'EdgeColor', 'k', 'FontWeight', 'bold');
    
    xlabel('Iteration', 'FontWeight', 'bold');
    ylabel('Fitness Value', 'FontWeight', 'bold');
    title('Convergence Curve', 'FontWeight', 'bold');
    legend({'Fitness progression', 'Best solution'}, 'Location', 'best');
    
    %% Add overall title
    sgtitle(sprintf('SCA Analysis: %s\nAgents: %d, Iterations: %d, Dimensions: %d', ...
        funcName, N, max_iter, dim), ...
        'FontSize', 14, 'FontWeight', 'bold');
    
    %% Save outputs
    % Save figure in multiple formats
    saveas(fig, [fullPath '.fig']);
    saveas(fig, [fullPath '.png']);
    saveas(fig, [fullPath '.svg']);
    
    % Save data for future analysis
    save([fullPath '_data.mat'], 'all_agent_history', 'Convergence_curve', 'lb', 'ub');
    
    fprintf('SCA analysis saved to:\n');
    fprintf('  Figures: %s.{fig,png,svg}\n', fullPath);
    fprintf('  Data:    %s_data.mat\n', fullPath);
    
    %% Handle outputs
    if nargout > 0
        varargout{1} = [fullPath '.fig'];
        varargout{2} = [fullPath '.png'];
        varargout{3} = [fullPath '_data.mat'];
    end
    
    %% Cleanup
    if ~showPlots && ishandle(fig)
        close(fig);
    end
    
    %% Nested helper function
    function out = iff(condition, trueval, falseval)
        % Inline if-else helper
        if condition
            out = trueval;
        else
            out = falseval;
        end
    end
end