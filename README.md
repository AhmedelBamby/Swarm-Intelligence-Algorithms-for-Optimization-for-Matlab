# Swarm Intelligence Algorithms for Optimization in MATLAB

[![MATLAB](https://img.shields.io/badge/MATLAB-R2020a%2B-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Version](https://img.shields.io/badge/Version-2.0-green.svg)]()

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [System Architecture](#system-architecture)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Detailed Usage](#detailed-usage)
- [Configuration](#configuration)
- [Optimization Functions](#optimization-functions)
- [Results and Visualization](#results-and-visualization)
- [Performance Features](#performance-features)
- [File Structure](#file-structure)
- [Examples](#examples)
- [Advanced Features](#advanced-features)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## 🔬 Overview

This project implements an **Enhanced Parallel Artificial Bee Colony (ABC) Algorithm** for solving complex optimization problems in MATLAB. The system is specifically designed for **controller parameter optimization** with robust checkpoint-based reporting, real-time visualization, and comprehensive statistical analysis.

### 🎯 Primary Application
The algorithm optimizes controller parameters for dual-loop control systems:
- **Current Controller Parameters**: Kp_I (Proportional gain), Ki_I (Integral gain)
- **Voltage Controller Parameters**: Kp_V (Proportional gain), Ki_V (Integral gain)

### 🏆 Key Achievements
- **Parallel Processing**: Utilizes MATLAB's Parallel Computing Toolbox for enhanced performance
- **Checkpoint System**: Robust resume-from-checkpoint functionality for long optimization runs
- **Real-time Monitoring**: Live visualization and progress tracking
- **Comprehensive Reporting**: Automated generation of Excel reports, statistical analysis, and visualizations

## ✨ Key Features

### 🚀 Enhanced ABC Algorithm
- **Parallel Implementation**: Multi-core processing for employed, onlooker, and scout bee phases
- **Adaptive Parameters**: Dynamic adjustment of algorithm parameters during optimization
- **Memory Management**: Intelligent SSD-aware caching system for large datasets
- **Convergence Acceleration**: Advanced selection mechanisms and population diversity maintenance

### 📊 Advanced Checkpoint System
- **Automatic Saving**: Periodic checkpoint creation with configurable intervals
- **Resume Capability**: Seamless continuation from any saved checkpoint
- **Data Integrity**: Comprehensive validation and error recovery mechanisms
- **Report Generation**: Automatic creation of reports, statistics, and visualizations at each checkpoint

### 📈 Real-time Visualization
- **Live Monitoring**: Real-time plots of convergence, diversity, and parameter evolution
- **3D Agent Positioning**: Visualization of bee positions in parameter space
- **Error Analysis**: Current and voltage error correlation plots
- **Statistical Dashboard**: Real-time statistics and performance metrics

### 📋 Comprehensive Reporting
- **Excel Integration**: Automated Excel report generation with multiple worksheets
- **Statistical Analysis**: Detailed statistical metrics including convergence rates, parameter statistics, and distribution analysis
- **Visual Reports**: High-quality plots and figures in multiple formats (PNG, FIG, PDF)
- **Time-stamped Archives**: Organized storage of all results with timestamps

## 🏗️ System Architecture

```
Enhanced ABC Algorithm
├── Core Algorithm (enhanced_abc_parallel.m)
│   ├── Parallel Employed Bees Phase
│   ├── Parallel Onlooker Bees Phase
│   └── Parallel Scout Bees Phase
├── Management System
│   ├── Checkpoint Manager (checkpointManager.m)
│   ├── Memory Manager (memoryManager.m)
│   └── Progress Tracker
├── Visualization System
│   ├── Real-time Visualizer (realTimeVisualizer.m)
│   └── Results Plotter (SaveAndPlotResults.m)
├── Analysis System
│   ├── Enhanced Statistics (enhancedStatistics.m)
│   ├── Report Generator (generateFinalReports.m)
│   └── Excel Logger (logExperimentResultsExcel.m)
└── Configuration System
    ├── Algorithm Config (abcConfig.m)
    └── Function Definitions (Get_Functions_details.m)
```

## 🛠️ Installation

### Prerequisites
- **MATLAB R2020a or later**
- **Parallel Computing Toolbox** (recommended for full functionality)
- **Statistics and Machine Learning Toolbox** (for advanced statistical analysis)
- **Simulink** (for the objective function simulation model)

### Setup Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/AhmedelBamby/Swarm-Intelligence-Algorithms-for-Optimization-for-Matlab.git
   cd Swarm-Intelligence-Algorithms-for-Optimization-for-Matlab
   ```

2. **MATLAB Path Configuration**
   ```matlab
   % Add project directory to MATLAB path
   addpath(genpath(pwd));
   
   % Verify Parallel Computing Toolbox
   ver('parallel')
   
   % Check available workers
   feature('numcores')
   ```

3. **Simulink Model Setup**
   - Ensure your Simulink model `h.slx` is in the current directory
   - The model should have output variables `dF1` (current error) and `dF2` (voltage error)
   - Configure workspace variables `k1`, `k2`, `k3`, `k4` as model parameters

4. **Directory Verification**
   ```matlab
   % The following directories will be created automatically:
   % - ABC_Optimization_Results/
   % - Important Plots/
   % - Important Excels/
   ```

## 🚀 Quick Start

### Basic Usage
```matlab
% 1. Simple optimization run
enhanced_abc_parallel();
```

### With Custom Configuration
```matlab
% 2. Modify configuration first
config = abcConfig();
config.algorithm.MaxIt = 100;           % Reduce iterations for testing
config.algorithm.nPop = 50;             % Smaller population
config.memory.checkpointInterval = 5;   % More frequent checkpoints
save('custom_config.mat', 'config');

% Then run optimization
enhanced_abc_parallel();
```

### Resume from Checkpoint
```matlab
% 3. Resume from saved checkpoint
% The algorithm will automatically detect existing checkpoints
% and prompt for resume option
enhanced_abc_parallel();
% When prompted, enter 1 to resume from the latest checkpoint
```

## 📚 Detailed Usage

### Configuration Parameters

#### Algorithm Parameters
```matlab
config.algorithm.MaxIt = 200;       % Maximum iterations
config.algorithm.nPop = 100;        % Population size (number of bees)
config.algorithm.nOnlooker = 50;    % Number of onlooker bees
config.algorithm.L = 120;           % Trial limit for scout phase
config.algorithm.a = 1.5;           % Acceleration coefficient
```

#### Memory Management
```matlab
config.memory.maxMemoryMB = 10240;     % Maximum RAM usage (MB)
config.memory.checkpointInterval = 2;  % Save checkpoint every N iterations
config.memory.cleanupInterval = 5;     % Memory cleanup interval
```

#### Visualization Settings
```matlab
config.visualization.updateInterval = 1;   % Update plots every N iterations
config.visualization.saveInterval = 10;    % Save plots every N iterations
config.visualization.realTime = true;      % Enable real-time visualization
```

#### Parallel Processing
```matlab
config.parallel.enabled = true;                    % Enable parallel processing
config.parallel.numWorkers = feature('numcores');  % Number of parallel workers
```

### Advanced Usage Examples

#### 1. High-Performance Optimization
```matlab
% Configure for maximum performance
config = abcConfig();
config.algorithm.MaxIt = 500;
config.algorithm.nPop = 200;
config.parallel.numWorkers = 8;
config.memory.maxMemoryMB = 16384;  % 16GB RAM
config.memory.checkpointInterval = 10;

% Save configuration
save('high_performance_config.mat', 'config');

% Run optimization
enhanced_abc_parallel();
```

#### 2. Long-Duration Optimization with Frequent Checkpoints
```matlab
% Configure for reliability
config = abcConfig();
config.algorithm.MaxIt = 1000;
config.memory.checkpointInterval = 1;  % Save every iteration
config.visualization.updateInterval = 5;
config.visualization.saveInterval = 20;

enhanced_abc_parallel();
```

#### 3. Memory-Constrained Environment
```matlab
% Configure for limited memory
config = abcConfig();
config.algorithm.nPop = 30;          % Smaller population
config.memory.maxMemoryMB = 2048;    % 2GB limit
config.memory.cleanupInterval = 2;   % Frequent cleanup
config.visualization.realTime = false; % Disable real-time plots

enhanced_abc_parallel();
```

## ⚙️ Configuration

### abcConfig.m Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `MaxIt` | integer | 200 | Maximum number of iterations |
| `nPop` | integer | 100 | Population size (employed + onlooker bees) |
| `nOnlooker` | integer | 50 | Number of onlooker bees |
| `L` | integer | 120 | Trial limit before converting to scout |
| `a` | double | 1.5 | Acceleration coefficient for position update |
| `maxMemoryMB` | integer | 10240 | Maximum RAM usage in MB |
| `checkpointInterval` | integer | 2 | Checkpoint save frequency |
| `cleanupInterval` | integer | 5 | Memory cleanup frequency |
| `updateInterval` | integer | 1 | Visualization update frequency |
| `saveInterval` | integer | 10 | Plot save frequency |
| `numWorkers` | integer | auto | Number of parallel workers |

### Parameter Bounds

The optimization bounds are defined in `Get_Functions_details.m`:

| Parameter | Description | Lower Bound | Upper Bound |
|-----------|-------------|-------------|-------------|
| `Kp_I` | Current controller proportional gain | 0.01 | 4.5 |
| `Ki_I` | Current controller integral gain | 0.1 | 500 |
| `Kp_V` | Voltage controller proportional gain | 0.01 | 10 |
| `Ki_V` | Voltage controller integral gain | 0.01 | 700 |

## 🎯 Optimization Functions

### F1 Objective Function

The primary objective function (`F1`) minimizes the combined control error:

```matlab
objective = norm(current_error) + norm(voltage_error)
```

**Key Components:**
- **Current Error (`dF1`)**: Deviation from desired current reference
- **Voltage Error (`dF2`)**: Deviation from desired voltage reference
- **Combined Metric**: Sum of both error norms for multi-objective optimization

**Simulation Integration:**
- Uses Simulink model `h.slx` for controller simulation
- Assigns optimized parameters `k1`, `k2`, `k3`, `k4` to workspace
- Evaluates controller performance under specified conditions

## 📊 Results and Visualization

### Automatic Output Generation

The system automatically generates comprehensive results in organized directories:

```
ABC_Optimization_Results_YYYY_MM_DD_HHMMSS/
├── Checkpoints/
│   ├── checkpoint_0002.mat
│   ├── checkpoint_0004.mat
│   └── ...
├── Results/
│   ├── optimization_report_YYYY_MM_DD_HHMMSS.xlsx
│   ├── summary_iter_XXXX_YYYY_MM_DD_HHMMSS.txt
│   └── checkpoint_report_iter_XXXX_YYYY_MM_DD_HHMMSS.xlsx
├── Visualizations/
│   ├── convergence_analysis_YYYY_MM_DD_HHMMSS.png
│   ├── parameter_evolution_YYYY_MM_DD_HHMMSS.png
│   ├── statistical_summary_YYYY_MM_DD_HHMMSS.png
│   └── agents_iter_XXX.png
└── Statistics/
    └── statistics_iter_XXXX_YYYY_MM_DD_HHMMSS.mat
```

### Visualization Types

#### 1. Convergence Analysis
- **Best Cost Evolution**: Logarithmic plot of best solution over iterations
- **Mean Cost Tracking**: Population average performance
- **Uncertainty Bands**: Standard deviation visualization
- **Improvement Rate**: Rate of convergence analysis

#### 2. Parameter Evolution
- **Trajectory Plots**: Evolution of each controller parameter
- **Parameter Correlation**: Relationship between parameters
- **Final Values**: Bar chart of optimized parameters

#### 3. Population Analysis
- **3D Agent Positioning**: Scatter plot of bee positions in parameter space
- **Diversity Metrics**: Population spread over iterations
- **Scout Activity**: Frequency of exploration vs exploitation

#### 4. Error Analysis
- **Current vs Voltage Error**: Correlation scatter plot
- **Error Distribution**: Histograms of error values
- **Performance Metrics**: Combined error evolution

### Excel Reports

#### Summary Sheet
- Final optimization results
- Improvement metrics
- Convergence statistics
- Best parameters found

#### Evolution Sheet
- Iteration-by-iteration data
- Cost evolution
- Parameter trajectories
- Diversity metrics

#### Statistics Sheet
- Detailed statistical analysis
- Distribution parameters
- Convergence rates
- Performance benchmarks

## 🚀 Performance Features

### Parallel Processing Architecture

The implementation leverages MATLAB's Parallel Computing Toolbox:

#### Employed Bees Phase (Parallel)
```matlab
parfor i = 1:nPop
    % Parallel position updates
    % Independent fitness evaluations
    % Concurrent parameter optimization
end
```

#### Onlooker Bees Phase (Parallel)
```matlab
parfor m = 1:nOnlooker
    % Parallel selection and search
    % Concurrent fitness evaluation
    % Independent position updates
end
```

#### Scout Bees Phase (Parallel)
```matlab
parfor s = 1:numScouts
    % Parallel random initialization
    % Concurrent fitness evaluation
    % Independent exploration
end
```

### Memory Management System

#### Intelligent Caching
- **RAM Priority**: Frequently accessed data in memory
- **SSD Overflow**: Large datasets automatically moved to disk
- **Automatic Cleanup**: Periodic memory optimization
- **Error Recovery**: Robust handling of memory constraints

#### Performance Monitoring
```matlab
% Memory status tracking
memManager = memoryManager('cache_dir', 2048);  % 2GB limit
status = memManager.getStatus();
fprintf('RAM Usage: %.1f%% (%.0f MB)\n', status.utilisationPercent, status.currentMemoryMB);
```

### Checkpoint System Performance

#### Fast Checkpoint Creation
- **Incremental Saves**: Only changed data stored
- **Compression**: Automatic data compression
- **Validation**: Integrity checking
- **Cleanup**: Automatic old checkpoint removal

#### Resume Optimization
- **Quick Load**: Fast checkpoint restoration
- **State Validation**: Ensures consistency
- **Error Handling**: Graceful failure recovery

## 📁 File Structure

### Core Algorithm Files
- **`enhanced_abc_parallel.m`** - Main optimization algorithm with parallel processing
- **`abcConfig.m`** - Configuration settings and parameters
- **`Get_Functions_details.m`** - Objective function definitions and bounds
- **`RouletteWheelSelection.m`** - Selection mechanism for onlooker bees

### Management System
- **`checkpointManager.m`** - Checkpoint creation, loading, and report generation
- **`memoryManager.m`** - Memory management and SSD caching system
- **`progressTracker.m`** - Progress monitoring and performance tracking

### Analysis and Reporting
- **`enhancedStatistics.m`** - Comprehensive statistical analysis functions
- **`generateFinalReports.m`** - Final report generation with visualizations
- **`logExperimentResultsExcel.m`** - Excel logging functionality
- **`SaveAndPlotResults.m`** - Results visualization and plotting

### Visualization System
- **`realTimeVisualizer.m`** - Real-time monitoring and visualization
- **Various plotting utilities** - Specialized visualization functions

### Support Files
- **`loadLatestCheckpointAndReport.m`** - Utility for checkpoint management
- **`LICENSE`** - GNU General Public License v3.0

## 💡 Examples

### Example 1: Basic Optimization
```matlab
%% Basic ABC Optimization Example
clear; clc; close all;

% Run optimization with default settings
enhanced_abc_parallel();

% Results will be automatically saved and displayed
```

### Example 2: Custom Configuration
```matlab
%% Custom Configuration Example
clear; clc; close all;

% Create custom configuration
config = abcConfig();
config.algorithm.MaxIt = 150;
config.algorithm.nPop = 80;
config.algorithm.nOnlooker = 40;
config.memory.checkpointInterval = 5;
config.visualization.updateInterval = 2;

% Save configuration
save('my_config.mat', 'config');

% Run optimization
enhanced_abc_parallel();
```

### Example 3: Load and Analyze Results
```matlab
%% Results Analysis Example
clear; clc; close all;

% Load the latest checkpoint
checkpointDir = 'ABC_Optimization_Results/Checkpoints';
files = dir(fullfile(checkpointDir, 'checkpoint_*.mat'));
[~, idx] = max([files.datenum]);
latestFile = fullfile(checkpointDir, files(idx).name);

% Load data
data = load(latestFile);

% Display results
fprintf('Optimization Results:\n');
fprintf('Best Cost: %.6e\n', data.BestSol.Cost);
fprintf('Parameters: [%.4f, %.4f, %.4f, %.4f]\n', data.BestSol.Position);
fprintf('Current Error: %.6f\n', data.BestSol.CurrentError);
fprintf('Voltage Error: %.6f\n', data.BestSol.VoltageError);

% Plot convergence
figure;
semilogy(data.BestCost(1:data.it), 'b-', 'LineWidth', 2);
xlabel('Iteration');
ylabel('Best Cost (log scale)');
title('Convergence Analysis');
grid on;
```

### Example 4: Performance Comparison
```matlab
%% Performance Comparison Example
clear; clc; close all;

% Configure different population sizes
populations = [30, 50, 100, 150];
results = cell(length(populations), 1);

for i = 1:length(populations)
    fprintf('Testing population size: %d\n', populations(i));
    
    % Configure
    config = abcConfig();
    config.algorithm.MaxIt = 50;  % Short run for comparison
    config.algorithm.nPop = populations(i);
    config.algorithm.nOnlooker = round(populations(i)/2);
    
    % Run optimization
    tic;
    enhanced_abc_parallel();
    execTime = toc;
    
    % Store results
    results{i}.population = populations(i);
    results{i}.execTime = execTime;
    
    fprintf('Completed in %.2f seconds\n\n', execTime);
end

% Display comparison
fprintf('Performance Comparison:\n');
for i = 1:length(results)
    fprintf('Population %d: %.2f seconds\n', results{i}.population, results{i}.execTime);
end
```

### Example 5: Parameter Sensitivity Analysis
```matlab
%% Parameter Sensitivity Analysis
clear; clc; close all;

% Test different acceleration coefficients
a_values = [0.5, 1.0, 1.5, 2.0, 2.5];
sensitivity_results = zeros(length(a_values), 1);

for i = 1:length(a_values)
    config = abcConfig();
    config.algorithm.MaxIt = 100;
    config.algorithm.a = a_values(i);
    
    fprintf('Testing acceleration coefficient: %.1f\n', a_values(i));
    
    % Run optimization
    enhanced_abc_parallel();
    
    % Load results (this would need to be adapted based on your results structure)
    % sensitivity_results(i) = final_best_cost;
end

% Plot sensitivity analysis
figure;
plot(a_values, sensitivity_results, 'bo-', 'LineWidth', 2);
xlabel('Acceleration Coefficient (a)');
ylabel('Final Best Cost');
title('Parameter Sensitivity Analysis');
grid on;
```

## 🔧 Advanced Features

### Custom Objective Functions

To add new objective functions, modify `Get_Functions_details.m`:

```matlab
case 'F2'  % New function
    fobj = @F2;
    lb = [0.1, 0.1, 0.1, 0.1];     % Lower bounds
    ub = [5.0, 1000, 15, 1000];    % Upper bounds
    dim = 4;                        % Dimension
    
    % Display parameter information
    fprintf('Function: F2 - Custom Optimization Problem\n');
    % ... parameter descriptions
```

Then implement the objective function:

```matlab
function o = F2(x)
    % Custom objective function implementation
    % x(1), x(2), x(3), x(4) are the parameters to optimize
    
    % Your custom optimization logic here
    error1 = calculateError1(x);
    error2 = calculateError2(x);
    
    o = error1 + error2;  % Combined objective
end
```

### Custom Checkpoint Actions

Extend the `checkpointManager` class for custom checkpoint behavior:

```matlab
classdef myCheckpointManager < checkpointManager
    methods
        function generateCustomReport(obj, data, iteration)
            % Custom report generation
            % Add your specialized analysis here
        end
    end
end
```

### Integration with External Simulators

For integration with external simulation tools:

```matlab
function o = externalSimulationObjective(x)
    % Write parameters to file
    writeParametersToFile(x, 'params.txt');
    
    % Call external simulator
    system('external_simulator.exe params.txt results.txt');
    
    % Read results
    results = readResultsFromFile('results.txt');
    
    % Calculate objective
    o = processResults(results);
end
```

## 🔍 Troubleshooting

### Common Issues and Solutions

#### 1. Parallel Processing Issues
**Problem**: `parpool` errors or parallel worker failures
```matlab
% Solution: Check and restart parallel pool
delete(gcp('nocreate'));  % Close existing pool
parpool('local', 4);      % Start new pool with 4 workers
```

#### 2. Memory Issues
**Problem**: Out of memory errors during optimization
```matlab
% Solution: Reduce memory usage
config = abcConfig();
config.algorithm.nPop = 50;           % Reduce population
config.memory.maxMemoryMB = 2048;     % Reduce memory limit
config.memory.cleanupInterval = 2;    % More frequent cleanup
```

#### 3. Simulink Model Issues
**Problem**: Simulink model not found or simulation errors
```matlab
% Solution: Verify model and parameters
if ~exist('h.slx', 'file')
    error('Simulink model h.slx not found in current directory');
end

% Check model parameters
open('h.slx');  % Open model to verify configuration
```

#### 4. Checkpoint Loading Failures
**Problem**: Cannot resume from checkpoint
```matlab
% Solution: Verify checkpoint integrity
checkpointFile = 'ABC_Optimization_Results/Checkpoints/checkpoint_0010.mat';
try
    data = load(checkpointFile);
    disp('Checkpoint loaded successfully');
catch ME
    fprintf('Checkpoint error: %s\n', ME.message);
    % Try earlier checkpoint or restart optimization
end
```

#### 5. Visualization Issues
**Problem**: Plots not updating or display errors
```matlab
% Solution: Check graphics settings
set(0, 'DefaultFigureVisible', 'on');  % Ensure figures are visible
drawnow;                               % Force graphics update

% Disable real-time visualization if problematic
config = abcConfig();
config.visualization.realTime = false;
```

### Performance Optimization Tips

#### 1. Optimal Population Size
- **Small problems (dim ≤ 5)**: 20-50 bees
- **Medium problems (dim 5-20)**: 50-100 bees  
- **Large problems (dim > 20)**: 100-200 bees

#### 2. Memory Management
- Monitor memory usage with `memoryManager.getStatus()`
- Use checkpoints for long runs (>500 iterations)
- Clean up workspace variables periodically

#### 3. Parallel Processing
- Use worker count ≤ number of physical cores
- For small populations, parallel processing may not be beneficial
- Consider communication overhead vs computation time

#### 4. Checkpoint Strategy
- More frequent checkpoints for unstable systems
- Less frequent checkpoints for fast-running optimizations
- Balance between safety and performance

### Error Codes and Messages

| Error Code | Message | Solution |
|------------|---------|----------|
| ABC001 | Simulink model not found | Ensure `h.slx` is in current directory |
| ABC002 | Invalid parameter bounds | Check bounds in `Get_Functions_details.m` |
| ABC003 | Parallel pool initialization failed | Restart MATLAB or check Parallel Computing Toolbox |
| ABC004 | Checkpoint corruption | Use earlier checkpoint or restart |
| ABC005 | Insufficient memory | Reduce population size or increase memory limit |

## 🤝 Contributing

We welcome contributions to improve the Enhanced ABC Algorithm! Here's how you can contribute:

### Types of Contributions
- **Bug fixes** and error corrections
- **Performance improvements** and optimizations
- **New features** and algorithm enhancements
- **Documentation** improvements
- **Test cases** and examples
- **Visualization** enhancements

### Development Setup
1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Test thoroughly**
5. **Submit a pull request**

### Coding Standards
- Follow MATLAB coding conventions
- Add comprehensive comments
- Include error handling
- Update documentation for new features
- Add examples for new functionality

### Testing Guidelines
- Test with different population sizes
- Verify parallel processing functionality  
- Check memory management under various conditions
- Validate checkpoint save/load functionality
- Test visualization components

### Reporting Issues
When reporting bugs, please include:
- MATLAB version and toolboxes
- Operating system
- Error messages (full stack trace)
- Steps to reproduce
- Expected vs actual behavior

## 📄 License

This project is licensed under the **GNU General Public License v3.0** - see the [LICENSE](LICENSE) file for complete details.

### License Summary
- ✅ **Commercial use** - You may use this software commercially
- ✅ **Distribution** - You may distribute the software  
- ✅ **Modification** - You may modify the software
- ✅ **Patent use** - This license provides an express grant of patent rights
- ✅ **Private use** - You may use and modify the software without distributing it

### Requirements
- **License and copyright notice** - Include the license and copyright notice with the software
- **State changes** - Document changes made to the software
- **Disclose source** - Source code must be made available when distributing
- **Same license** - Modifications must be released under the same license

## 📧 Contact

**Author**: Ahmed Hany ElBamby  
**Email**: ahmedhanyelbamby1102003@gmail.com  
**Phone**: +201096562363 (for work only)

### Project Links
- **Repository**: [GitHub Repository](https://github.com/AhmedelBamby/Swarm-Intelligence-Algorithms-for-Optimization-for-Matlab)
- **Issues**: [Report Issues](https://github.com/AhmedelBamby/Swarm-Intelligence-Algorithms-for-Optimization-for-Matlab/issues)
- **Discussions**: [Project Discussions](https://github.com/AhmedelBamby/Swarm-Intelligence-Algorithms-for-Optimization-for-Matlab/discussions)

### Getting Help
- Check the [Troubleshooting](#troubleshooting) section first
- Search [existing issues](https://github.com/AhmedelBamby/Swarm-Intelligence-Algorithms-for-Optimization-for-Matlab/issues)
- Create a [new issue](https://github.com/AhmedelBamby/Swarm-Intelligence-Algorithms-for-Optimization-for-Matlab/issues/new) with detailed information
- Contact the author for collaboration opportunities

---

## 📚 References and Citations

If you use this software in your research, please cite:

```bibtex
@software{bamby2024enhanced_abc,
  title = {Enhanced Parallel Artificial Bee Colony Algorithm for Controller Optimization},
  author = {Ahmed Hany ElBamby},
  year = {2024},
  url = {https://github.com/AhmedelBamby/Swarm-Intelligence-Algorithms-for-Optimization-for-Matlab},
  license = {GPL-3.0}
}
```

### Related Publications
- Karaboga, D. (2005). *An idea based on honey bee swarm for numerical optimization*
- Karaboga, D., & Basturk, B. (2007). *A powerful and efficient algorithm for numerical function optimization: artificial bee colony (ABC) algorithm*
- Akay, B., & Karaboga, D. (2012). *A modified artificial bee colony algorithm for real-parameter optimization*

---

<div align="center">

**⭐ Star this repository if you find it helpful!**

**🐛 Report bugs** | **💡 Request features** | **🤝 Contribute**

Made with ❤️ by Ahmed Hany ElBamby

</div>