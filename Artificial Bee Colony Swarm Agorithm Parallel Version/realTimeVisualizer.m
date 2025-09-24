classdef realTimeVisualizer < handle
    properties
        figHandle
        axHandles
        updateInterval = 5
    end
    
    methods
        function obj = realTimeVisualizer(updateInterval)
            if nargin > 0
                obj.updateInterval = updateInterval;
            end
            obj.setupFigures();
        end
        
        function setupFigures(obj)
            obj.figHandle = figure('Position', [100, 100, 1200, 800]);
            
            % Create subplots
            subplot(2,3,1); obj.axHandles.convergence = gca;
            title('Convergence'); xlabel('Iteration'); ylabel('Cost');
            
            subplot(2,3,2); obj.axHandles.diversity = gca;
            title('Diversity'); xlabel('Iteration'); ylabel('Diversity');
            
            subplot(2,3,3); obj.axHandles.agents3d = gca;
            title('Agent Positions'); xlabel('Kp_I'); ylabel('Ki_I'); zlabel('Kp_V');
            
            subplot(2,3,4); obj.axHandles.errorCorr = gca;
            title('Error Correlation'); xlabel('Current Error'); ylabel('Voltage Error');
            
            subplot(2,3,5); obj.axHandles.paramEvol = gca;
            title('Parameter Evolution'); xlabel('Iteration'); ylabel('Value');
            
            subplot(2,3,6); obj.axHandles.stats = gca;
            title('Statistics'); xlabel('Metric'); ylabel('Value');
        end
        
        function update(obj, iteration, data)
            if mod(iteration, obj.updateInterval) == 0
                obj.updateConvergence(data.BestCost, data.MeanCost);
                obj.updateDiversity(data.Diversity);
                obj.updateAgentPositions(data.Population);
                obj.updateErrorCorrelation(data.Errors);
                obj.updateParameterEvolution(data.ParamHistory);
                drawnow;
            end
        end
        
        function updateConvergence(obj, bestCost, meanCost)
            axes(obj.axHandles.convergence);
            cla;
            semilogy(bestCost, 'b-', 'LineWidth', 2);
            hold on;
            plot(meanCost, 'g--', 'LineWidth', 1.5);
            legend('Best', 'Mean', 'Location', 'best');
            grid on;
        end
        
        function updateDiversity(obj, diversity)
            axes(obj.axHandles.diversity);
            cla;
            plot(diversity, 'm-', 'LineWidth', 2);
            grid on;
        end
        
        function updateAgentPositions(obj, population)
            axes(obj.axHandles.agents3d);
            cla;
            positions = reshape([population.Position], 4, length(population))';
            costs = [population.Cost];
            scatter3(positions(:,1), positions(:,2), positions(:,3), 50, costs, 'filled');
            colorbar;
            grid on;
        end
        
        function updateErrorCorrelation(obj, errors)
            axes(obj.axHandles.errorCorr);
            cla;
            scatter(errors.current, errors.voltage, 30, errors.total, 'filled');
            colorbar;
            grid on;
        end
        
        function updateParameterEvolution(obj, paramHistory)
            axes(obj.axHandles.paramEvol);
            cla;
            hold on;
            colors = lines(size(paramHistory, 2));
            for i = 1:size(paramHistory, 2)
                plot(paramHistory(:, i), 'Color', colors(i,:), 'LineWidth', 1.5);
            end
            legend({'Kp_I', 'Ki_I', 'Kp_V', 'Ki_V'}, 'Location', 'best');
            grid on;
        end
    end
end
