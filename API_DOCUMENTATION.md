# API Documentation

This document provides detailed documentation for all functions and classes in the Swarm Intelligence Algorithms project.

## Table of Contents

- [Core Algorithm Functions](#core-algorithm-functions)
- [Configuration Management](#configuration-management)
- [Checkpoint and Data Management](#checkpoint-and-data-management)
- [Visualization and Analysis](#visualization-and-analysis)
- [Utility Functions](#utility-functions)
- [Class Definitions](#class-definitions)
- [Function Reference](#function-reference)

## Core Algorithm Functions

### `enhanced_abc_parallel()`

**Main optimization function implementing the Enhanced Parallel Artificial Bee Colony Algorithm.**

#### Syntax
```matlab
enhanced_abc_parallel()
```

#### Description
Executes the complete ABC optimization process with parallel processing, checkpoint management, and comprehensive reporting. The function automatically manages:
- Population initialization
- Parallel evaluation of candidate solutions
- Three-phase ABC algorithm (Employed, Onlooker, Scout bees)
- Automatic checkpointing and recovery
- Final report generation

#### Parameters
No direct parameters. Configuration is handled through `abcConfig()`.

#### Key Features
- **Parallel Processing**: Utilizes MATLAB Parallel Computing Toolbox
- **Checkpoint Recovery**: Can resume from interrupted runs
- **Memory Management**: Efficient handling of large datasets
- **Real-time Visualization**: Optional live plotting during optimization
- **Comprehensive Logging**: Detailed progress and results tracking

#### Example
```matlab
% Run with default configuration
enhanced_abc_parallel();

% Output: Optimization results, checkpoints, and reports in 
%         ABC_Optimization_Results_YYYY_MM_DD_HHMMSS/ directory
```

#### Dependencies
- `abcConfig.m` - Configuration management
- `Get_Functions_details.m` - Objective function definition
- `checkpointManager.m` - Checkpoint system
- Parallel Computing Toolbox (optional)

---

### `Get_Functions_details(F)`

**Provides objective function definitions and parameter bounds for optimization problems.**

#### Syntax
```matlab
[lb, ub, dim, fobj] = Get_Functions_details(F)
```

#### Inputs
- `F` (string): Function identifier (currently supports 'F1')

#### Outputs
- `lb` (vector): Lower bounds for optimization parameters
- `ub` (vector): Upper bounds for optimization parameters  
- `dim` (integer): Problem dimension (number of parameters)
- `fobj` (function handle): Objective function handle

#### Supported Functions

##### F1 - PI Controller Parameter Optimization
Optimizes current and voltage controller parameters for power electronics systems.

**Parameters:**
1. `Kp_I` - Proportional gain for current controller [0.01, 4.5]
2. `Ki_I` - Integral gain for current controller [0.1, 500]
3. `Kp_V` - Proportional gain for voltage controller [0.01, 10]
4. `Ki_V` - Integral gain for voltage controller [0.01, 700]

**Objective:** Minimize combined current and voltage control errors

#### Example
```matlab
[lb, ub, dim, fobj] = Get_Functions_details('F1');
fprintf('Problem dimension: %d\n', dim);
fprintf('Parameter bounds:\n');
for i = 1:dim
    fprintf('  Parameter %d: [%.3f, %.3f]\n', i, lb(i), ub(i));
end

% Evaluate objective function
x = [1.0, 50.0, 2.0, 100.0];  % Example parameter values
cost = fobj(x);
```

---

## Configuration Management

### `abcConfig()`

**Centralized configuration management for the ABC algorithm.**

#### Syntax
```matlab
config = abcConfig()
```

#### Outputs
- `config` (struct): Complete configuration structure

#### Configuration Structure

```matlab
config = abcConfig();

% Algorithm Parameters
config.algorithm.MaxIt = 200;              % Maximum iterations
config.algorithm.nPop = 100;               % Population size
config.algorithm.nOnlooker = 50;           % Number of onlooker bees
config.algorithm.L = 120;                  % Abandonment limit
config.algorithm.a = 1.5;                  % Acceleration coefficient

% Memory Management
config.memory.maxMemoryMB = 10240;         % Maximum memory (MB)
config.memory.checkpointInterval = 2;      % Checkpoint frequency
config.memory.cleanupInterval = 5;         % Cleanup frequency

% Visualization Settings
config.visualization.updateInterval = 1;   % Update frequency
config.visualization.saveInterval = 10;    % Save frequency
config.visualization.realTime = true;      % Enable real-time plots

% File Management
config.files.baseDir = 'ABC_Optimization_Results';
config.files.timestamp = datestr(now, 'yyyy_mm_dd_HHMMSS');

% Parallel Processing
config.parallel.enabled = true;            % Enable parallel processing
config.parallel.numWorkers = feature('numcores'); % Number of workers

% Statistics
config.statistics.detailed = true;         % Detailed statistics
config.statistics.exportInterval = 2;      % Export frequency
```

#### Example
```matlab
% Get default configuration
config = abcConfig();

% Modify for quick test
config.algorithm.MaxIt = 50;
config.algorithm.nPop = 30;

% Use modified configuration
% (Note: Currently requires manual modification of enhanced_abc_parallel.m)
```

---

## Checkpoint and Data Management

### `checkpointManager`

**Class for managing optimization checkpoints and automatic report generation.**

#### Constructor

```matlab
obj = checkpointManager(baseDir)
```

#### Inputs
- `baseDir` (string): Base directory for storing checkpoints and reports

#### Properties
- `checkpointDir` - Directory for checkpoint files
- `maxCheckpoints` - Maximum number of checkpoints to keep (default: 10)
- `resultsDir` - Directory for text reports
- `visualDir` - Directory for visualizations
- `statisticsDir` - Directory for statistical analysis

#### Methods

##### `save(data, iteration)`
Saves checkpoint data with automatic report generation.

```matlab
checkpointMgr = checkpointManager('ABC_Results');
checkpointData = struct('pop', pop, 'BestCost', BestCost, ...);
checkpointMgr.save(checkpointData, 100);
```

##### `load(iteration)`
Loads checkpoint data from specified iteration.

```matlab
data = checkpointMgr.load(100);
```

##### `generateFinalReportFromLatestCheckpoint()`
Generates comprehensive final report from the most recent checkpoint.

```matlab
checkpointMgr.generateFinalReportFromLatestCheckpoint();
```

#### Example
```matlab
% Create checkpoint manager
mgr = checkpointManager('My_Results');

% Save data
data.BestCost = [1000, 500, 250, 125];
data.pop = population_data;
data.timestamp = datestr(now);
mgr.save(data, 4);

% Load data
loadedData = mgr.load(4);

% Generate final report
mgr.generateFinalReportFromLatestCheckpoint();
```

---

### `loadLatestCheckpointAndReport()`

**Loads the most recent checkpoint and generates comprehensive reports.**

#### Syntax
```matlab
loadLatestCheckpointAndReport()
```

#### Description
This function automatically:
1. Finds the latest checkpoint file
2. Loads the checkpoint data
3. Extracts optimization results
4. Generates high-quality individual figures
5. Creates statistical summaries
6. Saves all reports with timestamps

#### Generated Outputs
- **Figures**: Convergence plots, parameter evolution, diversity analysis
- **Statistics**: Comprehensive statistical analysis files
- **Reports**: Text-based summaries and analysis
- **Visualizations**: High-resolution plots for publication

#### Example
```matlab
% After running optimization
enhanced_abc_parallel();

% Generate reports from latest results
loadLatestCheckpointAndReport();

% Files are saved in:
% - ABC_Optimization_Results/Results/
% - ABC_Optimization_Results/Visualizations/
% - ABC_Optimization_Results/Statistics/
```

---

## Visualization and Analysis

### `realTimeVisualizer`

**Class providing real-time visualization during optimization.**

#### Constructor
```matlab
obj = realTimeVisualizer(updateInterval)
```

#### Inputs
- `updateInterval` (integer, optional): Update frequency (default: 5)

#### Methods

##### `update(iteration, data)`
Updates all visualization panels with current optimization data.

```matlab
visualizer = realTimeVisualizer(5);
data = struct('BestCost', BestCost, 'Diversity', Diversity, ...);
visualizer.update(iteration, data);
```

#### Visualization Panels
1. **Convergence Plot**: Best and mean cost evolution
2. **Diversity Plot**: Population diversity over time
3. **3D Agent Positions**: Current population distribution
4. **Error Correlation**: Relationship between different error types
5. **Parameter Evolution**: Trajectory of optimization parameters
6. **Statistics Panel**: Key metrics and statistics

---

### `enhancedStatistics(data, label)`

**Comprehensive statistical analysis function.**

#### Syntax
```matlab
stats = enhancedStatistics(data, label)
```

#### Inputs
- `data` (vector): Numerical data for analysis
- `label` (string, optional): Label for the dataset

#### Outputs
- `stats` (struct): Comprehensive statistics structure

#### Calculated Statistics

##### Basic Statistics
- Mean, median, mode
- Standard deviation, variance
- Min, max, range
- Count of valid data points

##### Distribution Properties
- Skewness and kurtosis
- Percentiles (25th, 75th, 90th, 95th, 99th)
- Interquartile range (IQR)
- Coefficient of variation

##### Robust Statistics
- Median absolute deviation (MAD)
- 20% trimmed mean
- 95% confidence intervals

##### Outlier Analysis
- Outlier detection using IQR method
- Count and percentage of outliers

##### Normality Tests
- Jarque-Bera test
- Kolmogorov-Smirnov test

##### Time Series Properties (if applicable)
- Trend analysis (slope and correlation)
- Autocorrelation at lag 1
- Volatility measures

#### Example
```matlab
% Analyze convergence data
BestCost = [1000, 800, 600, 400, 300, 250, 200];
stats = enhancedStatistics(BestCost, 'Best Cost Evolution');

% Access results
fprintf('Mean improvement per iteration: %.2f\n', ...
    stats.trend.slope(1));
fprintf('Coefficient of variation: %.4f\n', stats.cv);
fprintf('Number of outliers: %d\n', stats.outlier_count);
```

---

### `SaveAndPlotResults(BestCost, MeanCost, Diversity, C, ParamHistory, varargin)`

**Enhanced visualization and saving of optimization results.**

#### Syntax
```matlab
SaveAndPlotResults(BestCost, MeanCost, Diversity, C, ParamHistory)
SaveAndPlotResults(BestCost, MeanCost, Diversity, C, ParamHistory, ...
                  allCurrentErrors, allVoltageErrors, allTotalErrors)
```

#### Inputs

##### Required Parameters
- `BestCost` (vector): Best cost values per iteration
- `MeanCost` (vector): Mean cost values per iteration
- `Diversity` (vector): Population diversity metric per iteration
- `C` (vector): Trial counters for each bee
- `ParamHistory` (matrix): Parameter trajectories (iterations × parameters)

##### Optional Parameters (varargin)
- `allCurrentErrors` (vector): Current errors for all solutions
- `allVoltageErrors` (vector): Voltage errors for all solutions  
- `allTotalErrors` (vector): Total errors for all solutions

#### Generated Plots

##### Standard Plots (always generated)
1. **Best Cost Convergence**: Logarithmic plot of best cost evolution
2. **Mean Cost Evolution**: Linear plot of mean population cost
3. **Population Diversity**: Diversity metric over iterations
4. **Trial Counter Distribution**: Histogram of abandonment counters
5. **Final Fitness Distribution**: Distribution of final fitness values
6. **Parameter Trajectories**: Evolution of all optimization parameters

##### Error Analysis Plots (if error data provided)
7. **Current Error Distribution**: Histogram of current control errors
8. **Voltage Error Distribution**: Histogram of voltage control errors
9. **Error Correlation**: Scatter plot showing error relationships

#### Output Structure
```
Important Plots/
├── figs_YYYY_MM_DD_HHMMSS/     # MATLAB .fig files
│   ├── BestCost.fig
│   ├── MeanCost.fig
│   ├── Diversity.fig
│   └── ...
└── plots_YYYY_MM_DD_HHMMSS/    # PNG image files
    ├── BestCost.png
    ├── MeanCost.png
    ├── Diversity.png
    └── ...
```

#### Example
```matlab
% Basic usage
SaveAndPlotResults(BestCost, MeanCost, Diversity, C, ParamHistory);

% With error analysis
SaveAndPlotResults(BestCost, MeanCost, Diversity, C, ParamHistory, ...
                   currentErrors, voltageErrors, totalErrors);
```

---

## Utility Functions

### `RouletteWheelSelection(P)`

**Implements roulette wheel selection for onlooker bee phase.**

#### Syntax
```matlab
i = RouletteWheelSelection(P)
```

#### Inputs
- `P` (vector): Probability vector (must sum to 1)

#### Outputs
- `i` (integer): Selected index based on probability

#### Algorithm
Uses cumulative probability distribution for selection:
1. Generate random number r ∈ [0,1]
2. Find first index where cumulative probability ≥ r

#### Example
```matlab
% Create probability vector (fitness-based selection)
fitness = [0.8, 0.6, 0.4, 0.2];
P = fitness / sum(fitness);  % Normalize to probabilities

% Select index based on probability
selectedIndex = RouletteWheelSelection(P);
fprintf('Selected bee: %d\n', selectedIndex);
```

---

### `progressTracker(maxIter, displayInterval)`

**Real-time progress tracking with ETA calculation.**

#### Syntax
```matlab
tracker = progressTracker(maxIter, displayInterval)
```

#### Inputs
- `maxIter` (integer): Maximum number of iterations
- `displayInterval` (integer): Display update frequency

#### Outputs
- `tracker` (struct): Progress tracker object with update function

#### Usage
```matlab
% Create tracker
tracker = progressTracker(200, 10);

% Update progress (call within optimization loop)
for i = 1:200
    % ... optimization code ...
    
    % Update progress display
    tracker.update(i, bestCost(i), meanCost(i));
end
```

#### Display Format
```
[HH:MM:SS] Iter 50/200 (25.0%) | Best: 1.234567e-02 | Mean: 5.678901e-02 | ETA: 150.3s
```

---

### `logExperimentResultsExcel(k1, k2, k3, k4, currentError, voltageError, totalError, iterations, execTime)`

**Logs experiment results to timestamped Excel files.**

#### Syntax
```matlab
logExperimentResultsExcel(k1, k2, k3, k4, currentError, voltageError, ...
                         totalError, iterations, execTime)
```

#### Inputs
- `k1, k2, k3, k4` (double): Optimized controller parameters
- `currentError` (double): Current control loop error
- `voltageError` (double): Voltage control loop error  
- `totalError` (double): Combined objective function value
- `iterations` (integer): Number of optimization iterations
- `execTime` (double): Total execution time in seconds

#### Output
Creates Excel file in `Important Excels/` directory with format:
`Experiment_YYYY_MM_DD_HHMMSS.xlsx`

#### Excel Structure
| Column | Description |
|--------|-------------|
| DateTime | Experiment timestamp |
| Kp_I | Current controller proportional gain |
| Ki_I | Current controller integral gain |
| Kp_V | Voltage controller proportional gain |
| Ki_V | Voltage controller integral gain |
| Current Error | Current loop control error |
| Voltage Error | Voltage loop control error |
| Total Error | Combined objective function value |
| Iterations | Number of optimization iterations |
| Execution Time (s) | Total runtime |

#### Example
```matlab
% Log optimization results
logExperimentResultsExcel(1.25, 75.5, 2.8, 150.0, ...
                         0.0234, 0.0156, 0.0390, 200, 145.6);

% Output: Creates file Important Excels/Experiment_2024_12_24_143022.xlsx
```

---

## Class Definitions

### `memoryManager`

**SSD-aware cache management for large optimization datasets.**

#### Constructor
```matlab
obj = memoryManager(cacheDir, maxMemMB)
```

#### Inputs
- `cacheDir` (string, optional): Cache directory path
- `maxMemMB` (double, optional): Maximum memory limit in MB

#### Key Methods

##### `store(key, data, forceDisk)`
Stores data with automatic RAM/disk management.

```matlab
mgr = memoryManager('cache', 1024);  % 1GB memory limit
mgr.store('population_data', largeArray, false);
```

##### `load(key)`
Retrieves stored data from RAM or disk.

```matlab
data = mgr.load('population_data');
```

##### `cleanup()`
Clears RAM cache while preserving disk cache.

```matlab
mgr.cleanup();
```

##### `getStatus()`
Returns detailed memory usage information.

```matlab
status = mgr.getStatus();
fprintf('Memory usage: %.1f%%\n', status.utilisationPercent);
```

#### Features
- **Automatic overflow**: Moves data to disk when RAM limit exceeded
- **Transparent access**: Same interface for RAM and disk data
- **Size tracking**: Monitors memory usage automatically
- **Cleanup management**: Automatic cache cleanup on destruction

---

## Function Reference

### Quick Reference Table

| Function | Purpose | Input | Output |
|----------|---------|-------|--------|
| `enhanced_abc_parallel()` | Main optimization | None | Results files |
| `abcConfig()` | Configuration | None | Config struct |
| `Get_Functions_details(F)` | Objective function | Function ID | Bounds, function |
| `SaveAndPlotResults(...)` | Visualization | Results data | Plots, files |
| `loadLatestCheckpointAndReport()` | Report generation | None | Report files |
| `enhancedStatistics(data, label)` | Statistical analysis | Data vector | Statistics struct |
| `RouletteWheelSelection(P)` | Selection mechanism | Probabilities | Selected index |
| `progressTracker(maxIter, interval)` | Progress monitoring | Iteration info | Tracker object |
| `logExperimentResultsExcel(...)` | Excel logging | Results data | Excel file |

### Error Handling

Most functions include comprehensive error handling:

```matlab
try
    result = someFunction(parameters);
catch ME
    fprintf('Error in %s: %s\n', ME.stack(1).name, ME.message);
    % Graceful degradation or alternative behavior
end
```

### Performance Considerations

1. **Memory Usage**: Large populations may require SSD caching
2. **Parallel Processing**: Overhead vs. benefit depends on problem complexity
3. **Checkpoint Frequency**: Balance between safety and performance
4. **Visualization**: Real-time plotting can slow down optimization

---

## Version Information

- **API Version**: 1.0.0
- **MATLAB Compatibility**: R2019b+
- **Last Updated**: December 2024

For the most current API information, check function help documentation:
```matlab
help functionName
doc className
```