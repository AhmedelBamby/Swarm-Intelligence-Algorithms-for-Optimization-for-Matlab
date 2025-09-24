classdef checkpointManager < handle
    
    properties
        checkpointDir
        maxCheckpoints = 10
        currentCheckpoint = 0
        resultsDir
        visualDir
        statisticsDir
    end
    
    methods
        function obj = checkpointManager(baseDir)
            obj.checkpointDir = fullfile(baseDir, 'Checkpoints');
            obj.resultsDir = fullfile(baseDir, 'Results');
            obj.visualDir = fullfile(baseDir, 'Visualizations');
            obj.statisticsDir = fullfile(baseDir, 'Statistics');
            
            % Create all directories
            dirs = {obj.checkpointDir, obj.resultsDir, obj.visualDir, obj.statisticsDir};
            for i = 1:length(dirs)
                if ~exist(dirs{i}, 'dir')
                    mkdir(dirs{i});
                end
            end
        end
        
        function save(obj, data, iteration)
            obj.currentCheckpoint = obj.currentCheckpoint + 1;
            filename = fullfile(obj.checkpointDir, sprintf('checkpoint_%04d.mat', iteration));
            
            % Add timestamp to data
            data.timestamp = datestr(now, 'yyyy_mm_dd_HHMMSS');
            data.saveTime = now;
            
            save(filename, '-struct', 'data', '-v7.3');
            
            % Generate reports from checkpoint data
            obj.generateReportsFromCheckpoint(data, iteration);
            
            % Clean old checkpoints
            obj.cleanOldCheckpoints();
            
            fprintf('Checkpoint %04d saved with reports generated\n', iteration);
        end
        
        function data = load(obj, iteration)
            filename = fullfile(obj.checkpointDir, sprintf('checkpoint_%04d.mat', iteration));
            if exist(filename, 'file')
                data = load(filename);
            else
                data = [];
            end
        end
        
        function generateReportsFromCheckpoint(obj, data, iteration)
            % Generate reports, statistics, and visualizations from checkpoint data
            try
                timestamp = data.timestamp;
                
                % 1. Generate Statistics
                obj.generateStatisticsFromCheckpoint(data, iteration, timestamp);
                
                % 2. Generate Visualizations
                obj.generateVisualizationsFromCheckpoint(data, iteration, timestamp);
                
                % 3. Generate Excel Report
                obj.generateExcelFromCheckpoint(data, iteration, timestamp);
                
                % 4. Generate Summary Report
                obj.generateSummaryFromCheckpoint(data, iteration, timestamp);
                
            catch ME
                fprintf('Warning: Could not generate reports from checkpoint %04d: %s\n', iteration, ME.message);
            end
        end
        
        function generateStatisticsFromCheckpoint(obj, data, iteration, timestamp)
            % Extract data safely
            BestCost = data.BestCost(1:iteration);
            MeanCost = data.MeanCost(1:iteration);
            StdCost = data.StdCost(1:iteration);
            Diversity = data.Diversity(1:iteration);
            ParamHistory = data.ParamHistory(1:iteration, :);
            
            % Compute statistics
            stats = struct();
            stats.iteration = iteration;
            stats.finalBestCost = BestCost(end);
            stats.initialBestCost = BestCost(1);
            stats.improvementRatio = BestCost(1) / BestCost(end);
            stats.meanFinalCost = MeanCost(end);
            stats.stdFinalCost = StdCost(end);
            stats.finalDiversity = Diversity(end);
            stats.bestParameters = ParamHistory(end, :);
            
            % Calculate convergence rate
            validBestCost = BestCost(BestCost > 0 & ~isnan(BestCost));
            if length(validBestCost) > 1
                stats.meanConvergenceRate = mean(diff(log(validBestCost)));
            else
                stats.meanConvergenceRate = 0;
            end
            
            % Parameter statistics
            for i = 1:size(ParamHistory, 2)
                stats.paramStats(i).mean = mean(ParamHistory(:, i));
                stats.paramStats(i).std = std(ParamHistory(:, i));
                stats.paramStats(i).range = [min(ParamHistory(:, i)), max(ParamHistory(:, i))];
                stats.paramStats(i).final = ParamHistory(end, i);
            end
            
            % Save statistics
            statsFile = fullfile(obj.statisticsDir, sprintf('statistics_iter_%04d_%s.mat', iteration, timestamp));
            save(statsFile, 'stats');
        end
        
        function generateVisualizationsFromCheckpoint(obj, data, iteration, timestamp)
            % Extract data
            BestCost = data.BestCost(1:iteration);
            MeanCost = data.MeanCost(1:iteration);
            StdCost = data.StdCost(1:iteration);
            Diversity = data.Diversity(1:iteration);
            ParamHistory = data.ParamHistory(1:iteration, :);
            
            % Figure 1: Convergence Plot
            f1 = figure('Visible', 'off', 'Position', [100, 100, 1000, 600]);
            
            subplot(2,2,1);
            semilogy(BestCost, 'b-', 'LineWidth', 2);
            hold on;
            plot(MeanCost, 'g--', 'LineWidth', 1.5);
            xlabel('Iteration');
            ylabel('Cost (log scale)');
            title(sprintf('Convergence - Iteration %d', iteration));
            legend('Best Cost', 'Mean Cost', 'Location', 'best');
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
            if length(BestCost) > 1
                improvementRate = -diff(BestCost);
                improvementRate(improvementRate < 0) = 0;
                plot(2:length(BestCost), improvementRate, 'k-', 'LineWidth', 1.5);
            end
            xlabel('Iteration');
            ylabel('Improvement Rate');
            title('Best Cost Improvement Rate');
            grid on;
            
            sgtitle(sprintf('ABC Algorithm Progress - Iteration %d', iteration), 'FontSize', 16);
            
            % Save figure
            saveas(f1, fullfile(obj.visualDir, sprintf('convergence_iter_%04d_%s.png', iteration, timestamp)));
            savefig(f1, fullfile(obj.visualDir, sprintf('convergence_iter_%04d_%s.fig', iteration, timestamp)));
            close(f1);
            
            % Figure 2: Parameter Evolution
            f2 = figure('Visible', 'off', 'Position', [150, 150, 1000, 600]);
            paramNames = {'Kp_I', 'Ki_I', 'Kp_V', 'Ki_V'};
            
            for i = 1:min(size(ParamHistory, 2), 4)
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
            
            sgtitle(sprintf('Parameter Evolution - Iteration %d', iteration), 'FontSize', 16);
            
            % Save figure
            saveas(f2, fullfile(obj.visualDir, sprintf('parameters_iter_%04d_%s.png', iteration, timestamp)));
            savefig(f2, fullfile(obj.visualDir, sprintf('parameters_iter_%04d_%s.fig', iteration, timestamp)));
            close(f2);
        end
        
        function generateExcelFromCheckpoint(obj, data, iteration, timestamp)
            try
                BestCost = data.BestCost(1:iteration);
                MeanCost = data.MeanCost(1:iteration);
                StdCost = data.StdCost(1:iteration);
                Diversity = data.Diversity(1:iteration);
                ParamHistory = data.ParamHistory(1:iteration, :);
                
                excelFile = fullfile(obj.resultsDir, sprintf('checkpoint_report_iter_%04d_%s.xlsx', iteration, timestamp));
                
                % Summary sheet
                summaryData = {
                    'Metric', 'Value';
                    'Current Iteration', iteration;
                    'Current Best Cost', BestCost(end);
                    'Initial Best Cost', BestCost(1);
                    'Improvement Ratio', BestCost(1) / BestCost(end);
                    'Current Diversity', Diversity(end);
                    'Current Mean Cost', MeanCost(end);
                    'Current Std Cost', StdCost(end);
                    'Best Kp_I', ParamHistory(end, 1);
                    'Best Ki_I', ParamHistory(end, 2);
                    'Best Kp_V', ParamHistory(end, 3);
                    'Best Ki_V', ParamHistory(end, 4);
                };
                
                writecell(summaryData, excelFile, 'Sheet', 'Summary');
                
                % Evolution sheet
                paramData = [(1:iteration)', BestCost, MeanCost, StdCost, Diversity, ParamHistory];
                paramHeaders = {'Iteration', 'BestCost', 'MeanCost', 'StdCost', 'Diversity', ...
                    'Kp_I', 'Ki_I', 'Kp_V', 'Ki_V'};
                
                writecell([paramHeaders; num2cell(paramData)], excelFile, 'Sheet', 'Evolution');
                
            catch ME
                fprintf('Warning: Could not create Excel report for iteration %04d: %s\n', iteration, ME.message);
            end
        end
        
        function generateSummaryFromCheckpoint(obj, data, iteration, timestamp)
            try
                BestCost = data.BestCost(1:iteration);
                ParamHistory = data.ParamHistory(1:iteration, :);
                
                summaryFile = fullfile(obj.resultsDir, sprintf('summary_iter_%04d_%s.txt', iteration, timestamp));
                fid = fopen(summaryFile, 'w');
                
                fprintf(fid, 'ABC Optimization Progress Report\n');
                fprintf(fid, '================================\n');
                fprintf(fid, 'Generated: %s\n', datestr(now));
                fprintf(fid, 'Checkpoint Iteration: %d\n', iteration);
                fprintf(fid, 'Current Best Cost: %.6e\n', BestCost(end));
                fprintf(fid, 'Initial Best Cost: %.6e\n', BestCost(1));
                fprintf(fid, 'Improvement Factor: %.2fx\n', BestCost(1) / BestCost(end));
                fprintf(fid, '\nCurrent Best Parameters:\n');
                fprintf(fid, 'Kp_I: %.6f\n', ParamHistory(end, 1));
                fprintf(fid, 'Ki_I: %.6f\n', ParamHistory(end, 2));
                fprintf(fid, 'Kp_V: %.6f\n', ParamHistory(end, 3));
                fprintf(fid, 'Ki_V: %.6f\n', ParamHistory(end, 4));
                
                if isfield(data, 'BestSol')
                    fprintf(fid, '\nCurrent Error Metrics:\n');
                    fprintf(fid, 'Current Error: %.6f\n', data.BestSol.CurrentError);
                    fprintf(fid, 'Voltage Error: %.6f\n', data.BestSol.VoltageError);
                    fprintf(fid, 'Total Error: %.6f\n', data.BestSol.Cost);
                end
                
                fclose(fid);
                
            catch ME
                fprintf('Warning: Could not create summary report for iteration %04d: %s\n', iteration, ME.message);
            end
        end
        
        function cleanOldCheckpoints(obj)
            files = dir(fullfile(obj.checkpointDir, 'checkpoint_*.mat'));
            if length(files) > obj.maxCheckpoints
                [~, idx] = sort([files.datenum]);
                for i = 1:(length(files) - obj.maxCheckpoints)
                    delete(fullfile(obj.checkpointDir, files(idx(i)).name));
                end
            end
        end
        
        function generateFinalReportFromLatestCheckpoint(obj)
            % Generate comprehensive final report from the latest checkpoint
            checkpointPattern = fullfile(obj.checkpointDir, 'checkpoint_*.mat');
            existingCheckpoints = dir(checkpointPattern);
            
            if ~isempty(existingCheckpoints)
                [~, idx] = max([existingCheckpoints.datenum]);
                latestCheckpoint = fullfile(obj.checkpointDir, existingCheckpoints(idx).name);
                
                fprintf('Generating final report from latest checkpoint: %s\n', existingCheckpoints(idx).name);
                data = load(latestCheckpoint);
                
                % Extract iteration number from filename
                [~, filename] = fileparts(existingCheckpoints(idx).name);
                iterStr = regexp(filename, '\d+', 'match');
                if ~isempty(iterStr)
                    iteration = str2double(iterStr{1});
                else
                    iteration = length(data.BestCost);
                end
                
                % Generate comprehensive final report
                obj.generateReportsFromCheckpoint(data, iteration);
                
                fprintf('Final report generated successfully!\n');
            else
                fprintf('No checkpoints found for final report generation.\n');
            end
        end
    end
end
