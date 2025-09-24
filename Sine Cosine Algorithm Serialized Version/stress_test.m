% =========================================================================
% STRESS TEST SCRIPT (PARALLEL VERSION) FOR SIMULINK MODEL: Generic Model
% 
% Author       : Eng. Ahmed Hany ElBamby
% Date         : April 2025
%
% Enhancements:
% 1. Fixed progress reporting to show every 10 tests
% 2. Improved ETA time formatting
% 3. Added percentage completion
% 4. Added timestamp to progress reports
% =========================================================================

clc;
clear variables;
close all;

%% ======================== CONFIGURATION ================================
Kp_I_range = linspace(1.2575,1.2575);
Ki_I_range = linspace(1 , 4 );
Kp_v_range = linspace(110,110);
Ki_v_range = linspace(650,800,2);

totalTests = numel(Kp_I_range) * numel(Ki_I_range) * numel(Kp_v_range) * numel(Ki_v_range);
results = NaN(totalTests, 8);  % [Kp_I, Ki_I, Kp_v, Ki_v, CurrentErr, VoltageErr, TotalErr, SimTime]

fprintf('\n=== Starting Parallel Stress Test (%d combinations) ===\n', totalTests);
fprintf('Start Time: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

%% ======================== PARAMETER MATRIX =============================
paramSet = combvec(Kp_I_range, Ki_I_range, Kp_v_range, Ki_v_range)';
fprintf('Parameter matrix generated (%d combinations)\n', size(paramSet,1));

%% ======================== PARALLEL SETUP ===============================
delete(gcp('nocreate'));
numWorkers = min([4, feature('numcores')]);
parpool('local', numWorkers);
fprintf('Parallel pool started with %d workers\n', numWorkers);

%% ======================== STRESS TEST LOOP =============================
tStart = tic;
parfor i = 1:totalTests
    currentParams = paramSet(i,:);
    k1 = currentParams(1); k2 = currentParams(2);
    k3 = currentParams(3); k4 = currentParams(4);

    try
        simStart = tic;
        load_system('sc_pi');
        set_param('sc_pi', 'SimulationMode', 'normal');
        modelWorkspace = get_param('sc_pi', 'ModelWorkspace');
        modelWorkspace.assignin('k1', k1);
        modelWorkspace.assignin('k2', k2);
        modelWorkspace.assignin('k3', k3);
        modelWorkspace.assignin('k4', k4);

        simOut = sim('sc_pi', 'SaveOutput', 'on', 'ReturnWorkspaceOutputs', 'on');
        simTime = toc(simStart);

        dF1 = simOut.get('dF1');
        dF2 = simOut.get('dF2');

        currentErr = norm(dF1);
        voltageErr = norm(dF2);
    catch ME
        fprintf('⚠️ Error in test %d: %s\n', i, ME.message);
        currentErr = Inf;
        voltageErr = Inf;
        simTime = NaN;
    end

    totalErr = currentErr + voltageErr;
    results(i,:) = [k1, k2, k3, k4, currentErr, voltageErr, totalErr, simTime];

    % Progress reporting every 10 tests or on final test
    if mod(i, 10) == 0 || i == totalTests
        elapsed = toc(tStart);
        estRemaining = (elapsed / i) * (totalTests - i);
        
        % Format time strings
        elapsedStr = formatTime(elapsed);
        etaStr = formatTime(estRemaining);
        
        fprintf('[%s] Completed %d/%d tests (%.1f%%) | Elapsed: %s | ETA: %s\n', ...
                datestr(now, 'HH:MM:SS'), ...
                i, totalTests, (i/totalTests)*100, ...
                elapsedStr, etaStr);
    end

    close_system('afasm50b1', 0);
end

%% ======================== SAVE RESULTS =================================
if ~exist('stress_test_results', 'dir')
    mkdir('stress_test_results'); 
end

colNames = {'Kp_I','Ki_I','Kp_v','Ki_v','Current_Error','Voltage_Error','Total_Objective','SimTime'};
resultsTable = array2table(results, 'VariableNames', colNames);
writetable(resultsTable, fullfile('stress_test_results', 'raw_results.xlsx'));
sortedTable = sortrows(resultsTable, 'Total_Objective');
writetable(sortedTable, fullfile('stress_test_results', 'sorted_results.xlsx'));

%% ======================== VISUALIZATION ================================
createVisualizations(results, sortedTable, Kp_I_range, Ki_I_range, Kp_v_range, Ki_v_range);

%% ======================== FINAL VALIDATION =============================
fprintf('\n=== Best Parameters Found ===\n');
disp(sortedTable(1,1:7));
bestParams = table2array(sortedTable(1,1:4));

fprintf('\nRunning validation simulation...\n');
try
    assignin('base', 'k1', bestParams(1));
    assignin('base', 'k2', bestParams(2));
    assignin('base', 'k3', bestParams(3));
    assignin('base', 'k4', bestParams(4));

    simOut = sim('sc_pi', 'SimulationMode', 'normal', 'SaveOutput', 'on');
    save(fullfile('stress_test_results', 'best_simulation.mat'), 'simOut', 'bestParams');
    fprintf('✅ Final simulation completed. Results saved.\n');
catch ME
    fprintf('❌ Final validation failed: %s\n', ME.message);
end

delete(gcp('nocreate'));
fprintf('\n=== Stress Test Completed ===\n');
fprintf('Total Duration: %s\n', formatTime(toc(tStart)));
fprintf('End Time: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

%% Helper Functions
function timeStr = formatTime(seconds)
    % Convert seconds to formatted time string
    if seconds > 3600
        hours = floor(seconds / 3600);
        minutes = floor(mod(seconds, 3600) / 60);
        seconds = mod(seconds, 60);
        timeStr = sprintf('%dh %dm %.1fs', hours, minutes, seconds);
    elseif seconds > 60
        minutes = floor(seconds / 60);
        seconds = mod(seconds, 60);
        timeStr = sprintf('%dm %.1fs', minutes, seconds);
    else
        timeStr = sprintf('%.1fs', seconds);
    end
end

function createVisualizations(results, sortedTable, Kp_I_range, Ki_I_range, Kp_v_range, Ki_v_range)
    % Create all visualization figures
    
    % Main performance overview figure
    figure('Position', [100 100 1200 800], 'Name', 'Performance Overview');
    subplot(2,2,1);
    plot(sortedTable.Total_Objective, 'LineWidth', 1.5);
    title('Sorted Total Error'); xlabel('Test Index'); ylabel('Error'); grid on;

    subplot(2,2,2);
    scatter3(results(:,1), results(:,2), results(:,7), 50, results(:,7), 'filled');
    xlabel('Kp_I'); ylabel('Ki_I'); zlabel('Total Error'); title('3D Param Sweep'); grid on; colorbar;

    subplot(2,2,3);
    boxplot(results(:,7), 'orientation', 'horizontal'); title('Total Error Distribution'); xlabel('Total Error');

    subplot(2,2,4);
    validSims = results(:,8) < Inf;
    histogram(results(validSims,8), 20);
    title('Simulation Time Histogram'); xlabel('Time (s)');

    saveas(gcf, fullfile('stress_test_results', 'performance_overview.png'));
    savefig(gcf, fullfile('stress_test_results', 'performance_overview.fig'));

    % Parameter sensitivity figure
    figure('Position', [100 100 1400 600], 'Name', 'Parameter Sensitivity');
    
    subplot(1,3,1);
    heatData1 = NaN(length(Ki_I_range), length(Kp_I_range));
    for i = 1:length(Kp_I_range)
        for j = 1:length(Ki_I_range)
            mask = results(:,1) == Kp_I_range(i) & results(:,2) == Ki_I_range(j);
            heatData1(j,i) = mean(results(mask,7), 'omitnan');
        end
    end
    imagesc(Kp_I_range, Ki_I_range, heatData1); set(gca,'YDir','normal');
    title('Kp_I vs Ki_I'); xlabel('Kp_I'); ylabel('Ki_I'); colorbar;

    subplot(1,3,2);
    heatData2 = NaN(length(Ki_v_range), length(Kp_v_range));
    for i = 1:length(Kp_v_range)
        for j = 1:length(Ki_v_range)
            mask = results(:,3) == Kp_v_range(i) & results(:,4) == Ki_v_range(j);
            heatData2(j,i) = mean(results(mask,7), 'omitnan');
        end
    end
    imagesc(Kp_v_range, Ki_v_range, heatData2); set(gca,'YDir','normal');
    title('Kp_v vs Ki_v'); xlabel('Kp_v'); ylabel('Ki_v'); colorbar;

    subplot(1,3,3);
    topN = min(100, height(sortedTable));
    scatter(1:topN, sortedTable.Total_Objective(1:topN), 30, 'filled');
    title('Top 100 Configs'); xlabel('Index'); ylabel('Total Error'); grid on;

    saveas(gcf, fullfile('stress_test_results', 'parameter_sensitivity.png'));
    savefig(gcf, fullfile('stress_test_results', 'parameter_sensitivity.fig'));
end