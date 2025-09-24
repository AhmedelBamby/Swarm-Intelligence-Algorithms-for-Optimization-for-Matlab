function implement_optimized_parameters(best_params, sca_config, model_name, results_folder)
% IMPLEMENT_OPTIMIZED_PARAMETERS - Applies SCA-optimized parameters to system
%
% Inputs:
%   best_params    - [k1, k2, k3, k4] optimized values
%   sca_config     - Struct with SCA configuration:
%                    .Iterations, .Agents, .a, .bw, .PAR
%   model_name     - Name of Simulink model (e.g., 'afasm50b1')
%   results_folder - Where to save verification results

%% 1. Setup and Validation
fprintf('\n=== PARAMETER IMPLEMENTATION INITIATED ===\n');
fprintf('Timestamp: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

% Create results directory if needed
if ~exist(results_folder, 'dir')
    mkdir(results_folder);
    fprintf('Created results directory: %s\n', results_folder);
end

%% 2. Parameter Implementation
try
    % Assign to base workspace for Simulink
    assignin('base', 'k1', best_params(1));
    assignin('base', 'k2', best_params(2));
    assignin('base', 'k3', best_params(3));
    assignin('base', 'k4', best_params(4));
    
    fprintf('\nOPTIMIZED PARAMETERS LOADED:\n');
    fprintf('k1: %.6f\nk2: %.6f\nk3: %.6f\nk4: %.6f\n', best_params(1), best_params(2), best_params(3), best_params(4));
    
    fprintf('\nSCA CONFIGURATION:\n');
    fprintf('Iterations: %d\nAgents: %d\na: %.2f\nbw: %.3f\nPAR: %.2f\n', ...
            sca_config.Iterations, sca_config.Agents, sca_config.a, sca_config.bw, sca_config.PAR);
catch ME
    error('Parameter assignment failed: %s', ME.message);
end

%% 3. System Verification
try
    fprintf('\nRUNNING SYSTEM VERIFICATION...\n');
    simStart = tic;
    simOut = sim(model_name);
    simTime = toc(simStart);
    
    % Calculate performance metrics
    current_error = norm(simOut.dF1.Data);
    voltage_error = norm(simOut.dF2.Data);
    total_error = current_error + voltage_error;
    
    fprintf('\nVERIFICATION RESULTS:\n');
    fprintf('Simulation Time: %.2f seconds\n', simTime);
    fprintf('Current Error Norm: %.4f\n', current_error);
    fprintf('Voltage Error Norm: %.4f\n', voltage_error);
    fprintf('Total Objective: %.4f\n', total_error);
catch ME
    warning(ME.identifier,'Simulation failed: %s', ME.message);
    return;
end

%% 4. Visualization
try
    fprintf('\nGENERATING PERFORMANCE PLOTS...\n');
    
    % Create figure with two subplots
    fig = figure('Position', [100 100 1000 700], 'Name', 'Optimized System Performance');
    
    % Current Error Plot
    subplot(2,1,1);
    plot(simOut.dF1.Time, simOut.dF1.Data, 'b', 'LineWidth', 1.5);
    title(sprintf('Current Error (Optimized Parameters)\\nSCA Score: %.4f', total_error));
    xlabel('Time (s)');
    ylabel('Error Magnitude');
    grid on;
    
    % Voltage Error Plot
    subplot(2,1,2);
    plot(simOut.dF2.Time, simOut.dF2.Data, 'r', 'LineWidth', 1.5);
    title('Voltage Error');
    xlabel('Time (s)');
    ylabel('Error Magnitude');
    grid on;
    
    % Save figure
    plot_filename = fullfile(results_folder, 'optimized_performance.png');
    saveas(fig, plot_filename);
    fprintf('Performance plot saved to: %s\n', plot_filename);
catch ME
    warning(ME.identifier,'Visualization failed: %s', ME.message);
end

%% 5. Save Results
try
    % Create results structure
    results = struct(...
        'Parameters', struct(...
            'k1', best_params(1), ...
            'k2', best_params(2), ...
            'k3', best_params(3), ...
            'k4', best_params(4)), ...
        'SCA_Configuration', sca_config, ...
        'Performance', struct(...
            'CurrentError', current_error, ...
            'VoltageError', voltage_error, ...
            'TotalObjective', total_error), ...
        'SimulationOutput', simOut, ...
        'Timestamp', datestr(now));
    
    % Save to MAT file
    mat_filename = fullfile(results_folder, 'optimized_implementation.mat');
    save(mat_filename, 'results');
    fprintf('\nFull results saved to: %s\n', mat_filename);
    
    % Export to CSV for easy reading
    csv_filename = fullfile(results_folder, 'optimized_parameters.csv');
    csvwrite(csv_filename, best_params);
    fprintf('Parameters exported to CSV: %s\n', csv_filename);
catch ME
    warning(ME.identifier,'Results saving failed: %s', ME.message);
end

fprintf('\n=== IMPLEMENTATION COMPLETE ===\n');
end