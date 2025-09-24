# User Guide - Swarm Intelligence Algorithms for Optimization

This comprehensive guide provides step-by-step instructions for using the Enhanced Parallel Artificial Bee Colony (ABC) optimization system.

## Table of Contents

- [Getting Started](#getting-started)
- [Basic Usage](#basic-usage)
- [Advanced Configuration](#advanced-configuration)
- [Working with Results](#working-with-results)
- [Customization Guide](#customization-guide)
- [Performance Optimization](#performance-optimization)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)
- [Example Workflows](#example-workflows)

## Getting Started

### Prerequisites Check

Before starting, verify you have the required components:

```matlab
% Check MATLAB version
version
% Should be R2019b or later

% Check required toolboxes
ver parallel          % Parallel Computing Toolbox
ver stats            % Statistics and Machine Learning Toolbox
ver optim            % Optimization Toolbox (optional but recommended)

% Check system resources
[~,systemview] = memory;
fprintf('Available memory: %.2f GB\n', systemview.PhysicalMemory.Available/1024^3);
```

### Initial Setup

1. **Add project to MATLAB path:**
   ```matlab
   % Navigate to project directory first
   cd('path/to/Swarm-Intelligence-Algorithms-for-Optimization-for-Matlab');
   
   % Add to path
   addpath(pwd);
   savepath;  % Save for future sessions
   ```

2. **Test basic functionality:**
   ```matlab
   % Test configuration loading
   config = abcConfig();
   fprintf('Configuration loaded successfully\n');
   
   % Test objective function
   [lb, ub, dim, fobj] = Get_Functions_details('F1');
   fprintf('Objective function F1 loaded: %d dimensions\n', dim);
   ```

3. **Prepare workspace:**
   ```matlab
   % Clear workspace for clean start
   clear; clc; close all;
   
   % Set up parallel pool (optional)
   if isempty(gcp('nocreate'))
       parpool();  % Use default settings
   end
   ```

## Basic Usage

### Quick Start - Default Settings

The simplest way to run optimization:

```matlab
% Clear workspace
clear; clc; close all;

% Run optimization with default parameters
enhanced_abc_parallel();

% The system will:
% 1. Initialize 100 bees
% 2. Run for 200 iterations  
% 3. Save checkpoints every 2 iterations
% 4. Generate comprehensive final report
% 5. Display progress in real-time
```

**Expected Output:**
```
Enhanced Parallel ABC Optimization with Checkpoint Reporting Started
==================================================================

=== Loading function details for: F1 ===
Function loaded successfully:
  Dimension: 4
  Parameter Bounds:
    Kp_I – Proportional gain for the current controller: [0.01, 4.50]
    Ki_I – Integral gain for the current controller: [0.10, 500.00]
    Kp_v – Proportional gain for the voltage controller: [0.01, 10.00]
    Ki_v – Integral gain for the voltage controller: [0.01, 700.00]

Initializing population with 100 bees...
Starting main optimization loop...
Progress: [Iter/Total] | Best Cost | Mean Cost | Std Cost | Diversity
----------------------------------------------------------------------
[  1/200] (0.5%) | 8.765432e-01 | 1.234567e+00 | 2.345678e-01 | 0.987654
...
```

### Understanding the Output

During optimization, you'll see:

1. **Progress Information:**
   - Current iteration / Total iterations
   - Progress percentage
   - Best cost found so far
   - Mean population cost
   - Population diversity

2. **Checkpoint Messages:**
   ```
   Saving checkpoint with reports...
   Checkpoint 0002 saved with reports generated
   ```

3. **Final Results:**
   ```
   ==========================================
   Optimization completed in 145.23 seconds
   Best solution found:
    Cost: 1.234567e-02
    Parameters: [1.2500, 75.5000, 2.8000, 150.0000]
    Current Error: 0.005678
    Voltage Error: 0.006789
   ```

### Analyzing Basic Results

After optimization completes, check the generated files:

```matlab
% List generated directories
ls ABC_Optimization_Results_*/

% Load latest checkpoint for analysis
loadLatestCheckpointAndReport();

% View specific results
data = load('ABC_Optimization_Results_*/Checkpoints/checkpoint_0200.mat');
bestParams = data.ParamHistory(end, :);

fprintf('Optimal controller parameters:\n');
fprintf('  Kp_I (Current Proportional): %.4f\n', bestParams(1));
fprintf('  Ki_I (Current Integral):     %.4f\n', bestParams(2));
fprintf('  Kp_V (Voltage Proportional): %.4f\n', bestParams(3));  
fprintf('  Ki_V (Voltage Integral):     %.4f\n', bestParams(4));
```

## Advanced Configuration

### Modifying Algorithm Parameters

Create custom configurations for different scenarios:

#### Quick Test Configuration
```matlab
function config = quickTestConfig()
    config = abcConfig();
    
    % Reduce problem size for testing
    config.algorithm.MaxIt = 50;          % Fewer iterations
    config.algorithm.nPop = 30;           % Smaller population
    config.algorithm.nOnlooker = 15;      % Fewer onlookers
    
    % More frequent checkpoints for monitoring
    config.memory.checkpointInterval = 5;
    
    % Disable real-time visualization for speed
    config.visualization.realTime = false;
end
```

#### High-Performance Configuration
```matlab
function config = performanceConfig()
    config = abcConfig();
    
    % Increase problem size for better solutions
    config.algorithm.MaxIt = 500;         % More iterations
    config.algorithm.nPop = 200;          % Larger population
    config.algorithm.nOnlooker = 100;     % More onlookers
    config.algorithm.L = 200;             % Higher abandonment limit
    
    % Optimize for performance
    config.parallel.enabled = true;
    config.parallel.numWorkers = feature('numcores');
    
    % Reduce checkpoint frequency
    config.memory.checkpointInterval = 10;
    config.memory.maxMemoryMB = 16384;    % 16GB memory limit
end
```

#### Memory-Constrained Configuration
```matlab
function config = lowMemoryConfig()
    config = abcConfig();
    
    % Reduce memory usage
    config.algorithm.nPop = 50;           % Smaller population
    config.memory.maxMemoryMB = 2048;     % 2GB limit
    config.memory.checkpointInterval = 1; % Frequent checkpoints
    config.memory.cleanupInterval = 2;    % Frequent cleanup
    
    % Disable resource-intensive features
    config.visualization.realTime = false;
    config.statistics.detailed = false;
end
```

### Using Custom Configurations

Currently, the system requires manual modification to use custom configurations. Here's how:

1. **Create your configuration function** (save as `myConfig.m`):
   ```matlab
   function config = myConfig()
       config = abcConfig();
       % Your modifications here
       config.algorithm.MaxIt = 100;
       config.algorithm.nPop = 60;
   end
   ```

2. **Modify `enhanced_abc_parallel.m`** to use your configuration:
   ```matlab
   % In enhanced_abc_parallel.m, replace:
   config = abcConfig();
   % With:
   config = myConfig();
   ```

3. **Run the modified version:**
   ```matlab
   enhanced_abc_parallel();
   ```

### Parameter Tuning Guidelines

#### Population Size (`nPop`)
- **Small (20-50)**: Fast convergence, may get stuck in local optima
- **Medium (50-100)**: Good balance for most problems  
- **Large (100-200+)**: Better exploration, slower convergence

#### Maximum Iterations (`MaxIt`)
- **Monitor convergence**: If best cost still improving, increase iterations
- **Rule of thumb**: 10-20 iterations per parameter for complex problems
- **Example**: 4 parameters → 40-80 iterations minimum

#### Abandonment Limit (`L`)
- **Low values (50-100)**: More exploration, less exploitation
- **High values (100-200)**: More exploitation, less exploration
- **Adaptive rule**: L ≈ 0.5 × nPop × dim

## Working with Results

### Understanding Output Structure

```
ABC_Optimization_Results_2024_12_24_143022/
├── Checkpoints/                    # Optimization state saves
│   ├── checkpoint_0002.mat        # Every N iterations
│   ├── checkpoint_0004.mat
│   └── checkpoint_0200.mat        # Final state
├── Results/                       # Text reports and summaries
│   ├── summary_iter_0200_*.txt   # Progress summaries
│   ├── final_report_*.txt        # Comprehensive final report
│   └── checkpoint_summary_*.txt   # Checkpoint analysis
├── Visualizations/                # Generated figures
│   ├── convergence_iter_0200.png # Best cost evolution
│   ├── diversity_iter_0200.png   # Population diversity
│   ├── parameters_iter_0200.png  # Parameter trajectories
│   └── agents_iter_*.png         # Agent positions
└── Statistics/                    # Statistical analysis
    ├── statistics_*.mat          # Raw statistics data
    └── detailed_stats_*.txt      # Human-readable analysis
```

### Loading and Analyzing Results

#### Load Specific Checkpoint
```matlab
% Load checkpoint from iteration 100
checkpointFile = 'ABC_Optimization_Results_*/Checkpoints/checkpoint_0100.mat';
data = load(checkpointFile);

% Extract key information
bestCost = data.BestCost(1:data.it);
paramHistory = data.ParamHistory(1:data.it, :);
currentIteration = data.it;

% Analyze convergence
figure;
semilogy(bestCost);
title(sprintf('Convergence Analysis (up to iteration %d)', currentIteration));
xlabel('Iteration');
ylabel('Best Cost (log scale)');
grid on;
```

#### Compare Multiple Runs
```matlab
% Load results from multiple runs
runs = dir('ABC_Optimization_Results_*/Checkpoints/checkpoint_*200.mat');
numRuns = length(runs);
allBestCosts = cell(numRuns, 1);

for i = 1:numRuns
    data = load(fullfile(runs(i).folder, runs(i).name));
    allBestCosts{i} = data.BestCost;
end

% Plot comparison
figure;
hold on;
colors = lines(numRuns);
for i = 1:numRuns
    semilogy(allBestCosts{i}, 'Color', colors(i,:), 'LineWidth', 1.5);
end
legend(arrayfun(@(x) sprintf('Run %d', x), 1:numRuns, 'UniformOutput', false));
title('Multi-Run Comparison');
xlabel('Iteration');
ylabel('Best Cost (log scale)');
grid on;
```

#### Statistical Analysis of Results
```matlab
% Analyze parameter convergence
data = load('ABC_Optimization_Results_*/Checkpoints/checkpoint_0200.mat');
paramNames = {'Kp_I', 'Ki_I', 'Kp_V', 'Ki_V'};

for i = 1:size(data.ParamHistory, 2)
    paramData = data.ParamHistory(:, i);
    stats = enhancedStatistics(paramData, paramNames{i});
    
    fprintf('\n=== %s Analysis ===\n', paramNames{i});
    fprintf('Final value: %.4f\n', paramData(end));
    fprintf('Mean ± Std: %.4f ± %.4f\n', stats.mean, stats.std);
    fprintf('Range: [%.4f, %.4f]\n', stats.min, stats.max);
    fprintf('Coefficient of variation: %.4f\n', stats.cv);
end
```

### Exporting Results

#### Export to Excel
```matlab
% Load final results
data = load('ABC_Optimization_Results_*/Checkpoints/checkpoint_0200.mat');

% Prepare data for export
exportData = {
    'Metric', 'Value';
    'Best Cost', data.BestSol.Cost;
    'Current Error', data.BestSol.CurrentError;
    'Voltage Error', data.BestSol.VoltageError;
    'Kp_I', data.BestSol.Position(1);
    'Ki_I', data.BestSol.Position(2);
    'Kp_V', data.BestSol.Position(3);
    'Ki_V', data.BestSol.Position(4);
};

% Write to Excel
timestamp = datestr(now, 'yyyy_mm_dd_HHMMSS');
filename = sprintf('optimization_results_%s.xlsx', timestamp);
writecell(exportData, filename);
fprintf('Results exported to: %s\n', filename);
```

#### Export Figures for Publication
```matlab
% Load and recreate key figures with publication quality
data = load('ABC_Optimization_Results_*/Checkpoints/checkpoint_0200.mat');

% High-quality convergence plot
figure('Position', [100, 100, 800, 600]);
semilogy(data.BestCost, 'b-', 'LineWidth', 2);
xlabel('Iteration', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Best Cost (log scale)', 'FontSize', 14, 'FontWeight', 'bold');
title('ABC Algorithm Convergence', 'FontSize', 16, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 12);

% Save in multiple formats
saveas(gcf, 'convergence_plot.png', 'png');
saveas(gcf, 'convergence_plot.eps', 'epsc');
saveas(gcf, 'convergence_plot.pdf', 'pdf');
```

## Customization Guide

### Adding New Objective Functions

To add a new optimization problem:

1. **Modify `Get_Functions_details.m`:**
   ```matlab
   function [lb, ub, dim, fobj] = Get_Functions_details(F)
       % ... existing code ...
       
       switch F
           case 'F1'
               % ... existing F1 code ...
               
           case 'F2'  % Your new function
               fobj = @F2;
               lb = [lower_bounds];      % Define your bounds
               ub = [upper_bounds];
               dim = length(lb);
               
               fprintf('Function F2 loaded successfully:\n');
               fprintf('  Dimension: %d\n', dim);
               % Add parameter descriptions
               
           otherwise
               error('Unknown function specified: %s', F);
       end
       
       % ... existing code ...
   end
   
   % Add your objective function
   function o = F2(x)
       % Your objective function implementation
       % Example: Rosenbrock function
       o = sum(100*(x(2:end) - x(1:end-1).^2).^2 + (1 - x(1:end-1)).^2);
   end
   ```

2. **Update the main algorithm:**
   ```matlab
   % In enhanced_abc_parallel.m, change:
   Fname = 'F1';
   % To:
   Fname = 'F2';  % Use your new function
   ```

### Custom Initialization Strategies

Modify population initialization for better starting points:

```matlab
% In enhanced_abc_parallel.m, replace random initialization with custom logic
for i = 1:nPop
    % Custom initialization instead of random
    if strcmp(Fname, 'F1')  % Controller optimization
        % Initialize around known good values
        pop(i).Position(1) = 1.0 + 0.5*randn;  % Kp_I around 1.0
        pop(i).Position(2) = 50 + 25*randn;    % Ki_I around 50
        pop(i).Position(3) = 2.0 + 1.0*randn;  % Kp_V around 2.0  
        pop(i).Position(4) = 100 + 50*randn;   % Ki_V around 100
        
        % Ensure bounds
        pop(i).Position = max(pop(i).Position, VarMin);
        pop(i).Position = min(pop(i).Position, VarMax);
    else
        % Default random initialization
        pop(i).Position = VarMin + rand(VarSize).*(VarMax-VarMin);
    end
    
    % Evaluate cost
    pop(i).Cost = CostFunction(pop(i).Position);
end
```

### Custom Termination Criteria

Add multiple stopping conditions:

```matlab
% Add these variables before the main loop
targetCost = 1e-6;           % Target cost threshold
stallGenerations = 20;       % Stall detection
stallCounter = 0;
minImprovement = 1e-8;       % Minimum improvement threshold

% Modify the main loop condition
for it = startIter:MaxIt
    % ... existing optimization code ...
    
    % Check termination criteria
    terminateEarly = false;
    
    % 1. Target cost reached
    if BestSol.Cost <= targetCost
        fprintf('Target cost %.2e reached at iteration %d\n', targetCost, it);
        terminateEarly = true;
    end
    
    % 2. Stall detection (no improvement for N generations)
    if it > 1
        improvement = BestCost(it-1) - BestCost(it);
        if improvement < minImprovement
            stallCounter = stallCounter + 1;
        else
            stallCounter = 0;
        end
        
        if stallCounter >= stallGenerations
            fprintf('No significant improvement for %d generations\n', stallGenerations);
            terminateEarly = true;
        end
    end
    
    % 3. Break if termination criteria met
    if terminateEarly
        % Update final iteration count
        MaxIt = it;
        BestCost = BestCost(1:it);
        MeanCost = MeanCost(1:it);
        % ... update other arrays ...
        break;
    end
    
    % ... rest of optimization loop ...
end
```

## Performance Optimization

### Hardware Optimization

#### Memory Management
```matlab
% Monitor memory usage during optimization
memoryMonitor = @() fprintf('Memory usage: %.2f GB\n', ...
    getfield(memory, 'MemUsedMATLAB')/1024^3);

% Call periodically in main loop
if mod(it, 10) == 0
    memoryMonitor();
end
```

#### Parallel Processing Optimization
```matlab
% Optimize parallel pool settings
delete(gcp('nocreate'));  % Close existing pool

% Create optimized pool
numWorkers = min(feature('numcores'), 8);  % Limit to 8 workers
parpool('local', numWorkers, 'IdleTimeout', Inf);

% Set parallel preferences
ps = parallel.Settings;
ps.Pool.AutoCreate = false;  % Manual control
```

#### SSD Optimization
```matlab
% Use SSD for checkpoint storage when available
if ispc
    ssdPaths = {'D:', 'E:', 'F:'};  % Common SSD drive letters
else
    ssdPaths = {'/tmp', '/var/tmp'};  % Unix/Linux temp directories
end

bestPath = pwd;  % Default to current directory
for i = 1:length(ssdPaths)
    if exist(ssdPaths{i}, 'dir')
        testFile = fullfile(ssdPaths{i}, 'write_test.tmp');
        try
            tic;
            save(testFile, 'config');  % Test write speed
            writeTime = toc;
            delete(testFile);
            
            if writeTime < 0.1  % Fast write indicates SSD
                bestPath = ssdPaths{i};
                break;
            end
        catch
            continue;
        end
    end
end

% Update base directory to use fast storage
config.files.baseDir = fullfile(bestPath, 'ABC_Optimization_Results');
```

### Algorithm Optimization

#### Adaptive Parameters
```matlab
% Implement adaptive acceleration coefficient
a_max = 2.0;  % Maximum acceleration
a_min = 0.5;  % Minimum acceleration

% Linear decrease with iterations
a_current = a_max - (a_max - a_min) * (it - 1) / (MaxIt - 1);

% Use in employed bee phase
phi = a_current * rand(VarSize) * 2 - 1;
```

#### Elitism Strategy
```matlab
% Preserve best solutions across generations
eliteSize = max(1, round(0.1 * nPop));  % Top 10% as elite

% Sort population by cost
[~, sortedIndices] = sort([pop.Cost]);
eliteIndices = sortedIndices(1:eliteSize);

% Ensure elite solutions are not abandoned
for i = 1:length(eliteIndices)
    C(eliteIndices(i)) = min(C(eliteIndices(i)), L - 1);
end
```

## Best Practices

### Experimental Design

#### 1. Multiple Independent Runs
```matlab
% Run multiple experiments for statistical significance
numRuns = 10;
results = cell(numRuns, 1);

for run = 1:numRuns
    fprintf('Starting run %d/%d...\n', run, numRuns);
    
    % Set random seed for reproducibility
    rng(run);
    
    % Run optimization
    enhanced_abc_parallel();
    
    % Store results
    latestCheckpoint = dir('ABC_Optimization_Results_*/Checkpoints/checkpoint_*200.mat');
    [~, idx] = max([latestCheckpoint.datenum]);
    results{run} = load(fullfile(latestCheckpoint(idx).folder, latestCheckpoint(idx).name));
end

% Analyze results across runs
finalCosts = cellfun(@(x) x.BestSol.Cost, results);
meanFinalCost = mean(finalCosts);
stdFinalCost = std(finalCosts);
bestRun = find(finalCosts == min(finalCosts), 1);

fprintf('\n=== Multi-Run Analysis ===\n');
fprintf('Mean final cost: %.6e ± %.6e\n', meanFinalCost, stdFinalCost);
fprintf('Best run: %d with cost %.6e\n', bestRun, finalCosts(bestRun));
```

#### 2. Parameter Sensitivity Analysis
```matlab
% Test different population sizes
populationSizes = [30, 50, 100, 150, 200];
results = cell(length(populationSizes), 1);

for i = 1:length(populationSizes)
    % Modify configuration
    config = abcConfig();
    config.algorithm.nPop = populationSizes(i);
    config.algorithm.nOnlooker = round(populationSizes(i) / 2);
    
    % Save configuration and run
    % (Requires manual modification of enhanced_abc_parallel.m)
    fprintf('Testing population size: %d\n', populationSizes(i));
    % enhanced_abc_parallel();
    
    % Store results...
end
```

### Quality Control

#### 1. Convergence Validation
```matlab
% Check if optimization has converged
data = load('ABC_Optimization_Results_*/Checkpoints/checkpoint_0200.mat');

% Calculate improvement rate over last 20% of iterations
lastPortion = round(0.8 * length(data.BestCost)):length(data.BestCost);
if length(lastPortion) > 1
    improvementRate = mean(diff(data.BestCost(lastPortion)));
    
    if abs(improvementRate) < 1e-8
        fprintf('✓ Optimization appears to have converged\n');
    else
        fprintf('⚠ Optimization may need more iterations\n');
        fprintf('   Current improvement rate: %.2e per iteration\n', improvementRate);
    end
end
```

#### 2. Solution Validation
```matlab
% Validate final solution makes physical sense
bestParams = data.BestSol.Position;
paramNames = {'Kp_I', 'Ki_I', 'Kp_V', 'Ki_V'};

fprintf('\n=== Solution Validation ===\n');
for i = 1:length(bestParams)
    fprintf('%s: %.4f', paramNames{i}, bestParams(i));
    
    % Check for reasonable controller values
    if i <= 2  % Current controller
        if bestParams(i) < 0.1 || bestParams(i) > 100
            fprintf(' ⚠ (unusual value)');
        end
    else  % Voltage controller  
        if bestParams(i) < 0.1 || bestParams(i) > 200
            fprintf(' ⚠ (unusual value)');
        end
    end
    fprintf('\n');
end
```

### Documentation and Reporting

#### 1. Automated Report Generation
```matlab
% Create comprehensive experiment report
function generateExperimentReport(resultDir)
    % Load latest results
    checkpointFiles = dir(fullfile(resultDir, 'Checkpoints', '*.mat'));
    [~, idx] = max([checkpointFiles.datenum]);
    data = load(fullfile(checkpointFiles(idx).folder, checkpointFiles(idx).name));
    
    % Generate report
    reportFile = fullfile(resultDir, 'Results', 'experiment_report.txt');
    fid = fopen(reportFile, 'w');
    
    fprintf(fid, 'ABC OPTIMIZATION EXPERIMENT REPORT\n');
    fprintf(fid, '=====================================\n\n');
    fprintf(fid, 'Generated: %s\n', datestr(now));
    fprintf(fid, 'Experiment completed: %d iterations\n', data.it);
    
    % Results summary
    fprintf(fid, '\nOPTIMIZATION RESULTS:\n');
    fprintf(fid, '-------------------\n');
    fprintf(fid, 'Best cost achieved: %.6e\n', data.BestSol.Cost);
    fprintf(fid, 'Current control error: %.6e\n', data.BestSol.CurrentError);
    fprintf(fid, 'Voltage control error: %.6e\n', data.BestSol.VoltageError);
    
    % Parameters
    fprintf(fid, '\nOPTIMAL PARAMETERS:\n');
    fprintf(fid, '------------------\n');
    fprintf(fid, 'Kp_I: %.6f\n', data.BestSol.Position(1));
    fprintf(fid, 'Ki_I: %.6f\n', data.BestSol.Position(2));
    fprintf(fid, 'Kp_V: %.6f\n', data.BestSol.Position(3));
    fprintf(fid, 'Ki_V: %.6f\n', data.BestSol.Position(4));
    
    fclose(fid);
    fprintf('Report saved to: %s\n', reportFile);
end
```

## Example Workflows

### Workflow 1: Quick Parameter Tuning

For rapid prototyping and parameter testing:

```matlab
%% Quick Parameter Tuning Workflow
clear; clc; close all;

% 1. Set up quick test configuration
config = abcConfig();
config.algorithm.MaxIt = 30;          % Quick test
config.algorithm.nPop = 20;           % Small population
config.memory.checkpointInterval = 10; % Less frequent saves

% 2. Run optimization
fprintf('Starting quick parameter tuning...\n');
enhanced_abc_parallel();

% 3. Quick analysis
loadLatestCheckpointAndReport();

% 4. Extract key results
resultDir = dir('ABC_Optimization_Results_*');
data = load(fullfile(resultDir(end).name, 'Checkpoints', 'checkpoint_0030.mat'));

fprintf('\n=== Quick Results ===\n');
fprintf('Best cost: %.6e\n', data.BestSol.Cost);
fprintf('Parameters: [%.3f, %.3f, %.3f, %.3f]\n', data.BestSol.Position);
```

### Workflow 2: Production Optimization

For final controller design:

```matlab
%% Production Optimization Workflow
clear; clc; close all;

% 1. Set up production configuration
config = abcConfig();
config.algorithm.MaxIt = 200;         % Full iterations
config.algorithm.nPop = 100;          % Large population
config.parallel.enabled = true;       % Enable parallel processing

% 2. Run multiple independent trials
numTrials = 5;
allResults = cell(numTrials, 1);

for trial = 1:numTrials
    fprintf('\n=== Production Trial %d/%d ===\n', trial, numTrials);
    
    % Set reproducible random seed
    rng(trial * 1000);
    
    % Run optimization
    enhanced_abc_parallel();
    
    % Store results
    resultDir = dir('ABC_Optimization_Results_*');
    checkpointFile = fullfile(resultDir(end).name, 'Checkpoints', 'checkpoint_0200.mat');
    allResults{trial} = load(checkpointFile);
    
    % Clean up for next trial
    pause(1);  % Ensure different timestamps
end

% 3. Analyze all trials
finalCosts = cellfun(@(x) x.BestSol.Cost, allResults);
[bestCost, bestTrial] = min(finalCosts);
bestSolution = allResults{bestTrial}.BestSol;

% 4. Generate comprehensive report
fprintf('\n=== PRODUCTION RESULTS SUMMARY ===\n');
fprintf('Number of trials: %d\n', numTrials);
fprintf('Best cost: %.6e (Trial %d)\n', bestCost, bestTrial);
fprintf('Mean cost: %.6e ± %.6e\n', mean(finalCosts), std(finalCosts));
fprintf('\nFinal controller parameters:\n');
fprintf('  Kp_I: %.6f\n', bestSolution.Position(1));
fprintf('  Ki_I: %.6f\n', bestSolution.Position(2));
fprintf('  Kp_V: %.6f\n', bestSolution.Position(3));
fprintf('  Ki_V: %.6f\n', bestSolution.Position(4));

% 5. Export results
timestamp = datestr(now, 'yyyy_mm_dd_HHMMSS');
exportData = [
    {'Trial', 'Best Cost', 'Kp_I', 'Ki_I', 'Kp_V', 'Ki_V'};
    num2cell([(1:numTrials)', finalCosts, ...
             cell2mat(cellfun(@(x) x.BestSol.Position, allResults, 'UniformOutput', false))])
];
writecell(exportData, sprintf('production_results_%s.xlsx', timestamp));
```

### Workflow 3: Comparative Study

For comparing different algorithm configurations:

```matlab
%% Comparative Study Workflow
clear; clc; close all;

% Define test configurations
configs = {
    struct('name', 'Small_Pop', 'MaxIt', 100, 'nPop', 30, 'L', 60),
    struct('name', 'Medium_Pop', 'MaxIt', 100, 'nPop', 60, 'L', 120),
    struct('name', 'Large_Pop', 'MaxIt', 100, 'nPop', 100, 'L', 200)
};

% Run comparative tests
results = struct();
for i = 1:length(configs)
    cfg = configs{i};
    fprintf('\n=== Testing Configuration: %s ===\n', cfg.name);
    
    % Note: This requires manual modification of enhanced_abc_parallel.m
    % to use the custom configuration
    
    % Store configuration info
    results.(cfg.name) = cfg;
    
    % Run optimization (manually modify config first)
    % enhanced_abc_parallel();
    
    % Analyze results
    % ... load and store results ...
end

% Generate comparison report
fprintf('\n=== COMPARATIVE STUDY RESULTS ===\n');
% ... comparison analysis code ...
```

This user guide provides comprehensive coverage of the system's capabilities. For additional help, refer to:
- **API Documentation** for detailed function references
- **Configuration Guide** for complete parameter listings  
- **Troubleshooting Guide** for common issues and solutions

---

**Last Updated**: December 2024  
**Version**: 1.0.0