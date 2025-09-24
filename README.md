# Swarm Intelligence Algorithms for Optimization in MATLAB

[![MATLAB](https://img.shields.io/badge/MATLAB-R2019b+-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Core Components](#core-components)
- [Configuration](#configuration)
- [Usage Examples](#usage-examples)
- [Output and Results](#output-and-results)
- [Documentation](#documentation)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

## Overview

This project implements an **Enhanced Parallel Artificial Bee Colony (ABC) Algorithm** for optimization problems in MATLAB. The implementation is specifically designed for controller parameter optimization with advanced features including:

- **Parallel processing** for improved performance
- **Checkpoint-based reporting** system for robust data management
- **Real-time visualization** and monitoring
- **Comprehensive statistical analysis**
- **Memory-efficient handling** of large datasets
- **Excel-based logging** for experiment tracking

The primary application focuses on optimizing **PI controller parameters** for power electronics systems, specifically for current and voltage control loops.

## Features

### 🚀 Core Algorithm Features
- **Artificial Bee Colony (ABC)** optimization algorithm implementation
- **Parallel processing** support using MATLAB Parallel Computing Toolbox
- **Dynamic population management** with employed, onlooker, and scout bees
- **Adaptive parameter control** for enhanced convergence

### 📊 Advanced Reporting & Analytics
- **Checkpoint-based system** for robust data persistence
- **Real-time visualization** with multiple plot types
- **Comprehensive statistical analysis** with enhanced metrics
- **Excel-based experiment logging** with timestamps
- **Automated report generation** with publication-quality figures

### 🔧 System Management
- **Memory management** with SSD-aware caching
- **Progress tracking** with ETA calculation
- **Error handling** and recovery mechanisms
- **Configurable parameters** through centralized configuration

### 📈 Visualization & Monitoring
- **Real-time convergence plots**
- **Population diversity tracking**
- **Parameter trajectory visualization**
- **3D agent position mapping**
- **Error correlation analysis**

## Requirements

### MATLAB Version
- **MATLAB R2019b or later** (recommended R2021a+)

### Required Toolboxes
- **Parallel Computing Toolbox** (for parallel processing)
- **Statistics and Machine Learning Toolbox** (for statistical analysis)
- **Optimization Toolbox** (for optimization functions)

### Optional Toolboxes
- **Simulink** (if using with control system models)
- **Control System Toolbox** (for advanced control analysis)

### System Requirements
- **RAM:** Minimum 8GB (16GB+ recommended for large populations)
- **Storage:** At least 2GB free space for results and checkpoints
- **CPU:** Multi-core processor (4+ cores recommended for parallel execution)

## Installation

### Method 1: Direct Download
1. Clone or download this repository:
   ```bash
   git clone https://github.com/AhmedelBamby/Swarm-Intelligence-Algorithms-for-Optimization-for-Matlab.git
   ```

2. Add the project folder to MATLAB path:
   ```matlab
   addpath('path/to/Swarm-Intelligence-Algorithms-for-Optimization-for-Matlab');
   savepath;
   ```

### Method 2: MATLAB Integration
1. Open MATLAB
2. Navigate to the project directory
3. Run the following command to add all necessary paths:
   ```matlab
   setup_project();  % Will be created in setup documentation
   ```

## Quick Start

### Basic Usage
```matlab
% Run the enhanced ABC optimization with default settings
enhanced_abc_parallel();
```

### With Custom Configuration
```matlab
% Modify configuration first
config = abcConfig();
config.algorithm.MaxIt = 100;        % Maximum iterations
config.algorithm.nPop = 50;          % Population size
config.parallel.enabled = true;      % Enable parallel processing

% Save modified config (optional)
save('my_config.mat', 'config');

% Run optimization
enhanced_abc_parallel();
```

### Load and Analyze Results
```matlab
% Load latest checkpoint and generate reports
loadLatestCheckpointAndReport();

% Generate comprehensive final reports
generateFinalReports();
```

## Project Structure

```
📦 Swarm-Intelligence-Algorithms-for-Optimization-for-Matlab/
├── 📄 README.md                          # This file
├── 📄 LICENSE                            # GPL v3 License
│
├── 🔧 Core Algorithm Files
│   ├── enhanced_abc_parallel.m           # Main ABC optimization algorithm
│   ├── Get_Functions_details.m           # Objective function definitions
│   ├── abcConfig.m                       # Configuration management
│   └── RouletteWheelSelection.m          # Selection mechanism
│
├── 📊 Management & Reporting
│   ├── checkpointManager.m               # Checkpoint system management
│   ├── loadLatestCheckpointAndReport.m   # Checkpoint loading & reporting
│   ├── generateFinalReports.m           # Comprehensive report generation
│   └── SaveAndPlotResults.m             # Results visualization
│
├── 📈 Visualization & Analysis
│   ├── realTimeVisualizer.m             # Real-time visualization
│   ├── enhancedStatistics.m             # Statistical analysis
│   └── progressTracker.m                # Progress monitoring
│
├── 💾 Data Management
│   ├── memoryManager.m                   # Memory & cache management
│   └── logExperimentResultsExcel.m      # Excel logging system
│
└── 📁 Output Directories (auto-created)
    ├── ABC_Optimization_Results/          # Main results directory
    │   ├── Checkpoints/                  # Checkpoint files
    │   ├── Results/                      # Text reports & summaries
    │   ├── Visualizations/               # Generated figures
    │   └── Statistics/                   # Statistical analysis files
    ├── Important Plots/                  # Legacy plot storage
    └── Important Excels/                 # Excel log files
```

## Core Components

### 1. Enhanced ABC Algorithm (`enhanced_abc_parallel.m`)
The main optimization engine implementing the ABC algorithm with:
- **Three bee phases:** Employed, Onlooker, and Scout bees
- **Parallel evaluation** of candidate solutions
- **Dynamic trial counter management**
- **Automatic checkpointing** and recovery

### 2. Configuration System (`abcConfig.m`)
Centralized configuration management:
```matlab
config = abcConfig();
% Algorithm parameters
config.algorithm.MaxIt = 200;           % Maximum iterations
config.algorithm.nPop = 100;            % Population size
config.algorithm.nOnlooker = 50;        % Number of onlooker bees
config.algorithm.L = 120;               % Abandonment limit
config.algorithm.a = 1.5;               % Acceleration coefficient

% Memory management
config.memory.maxMemoryMB = 10240;      % Memory limit (MB)
config.memory.checkpointInterval = 2;   % Checkpoint frequency
config.memory.cleanupInterval = 5;      // Memory cleanup frequency

% Parallel processing
config.parallel.enabled = true;         % Enable/disable parallel processing
config.parallel.numWorkers = 4;         % Number of workers
```

### 3. Checkpoint System (`checkpointManager.m`)
Robust data persistence with:
- **Automatic saving** at specified intervals
- **Recovery capabilities** from interruptions
- **Report generation** from checkpoints
- **Storage management** with cleanup

### 4. Objective Function (`Get_Functions_details.m`)
Currently implements optimization for PI controller parameters:
- **F1 function:** Current and voltage controller optimization
- **Parameter bounds:** Configurable limits for each parameter
- **Simulation integration:** Direct interface with control system models

## Configuration

### Algorithm Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `MaxIt` | 200 | Maximum number of iterations |
| `nPop` | 100 | Population size (number of bees) |
| `nOnlooker` | 50 | Number of onlooker bees |
| `L` | 120 | Abandonment limit for scout bees |
| `a` | 1.5 | Acceleration coefficient |

### Memory Management

| Parameter | Default | Description |
|-----------|---------|-------------|
| `maxMemoryMB` | 10240 | Maximum memory usage (MB) |
| `checkpointInterval` | 2 | Save checkpoint every N iterations |
| `cleanupInterval` | 5 | Memory cleanup frequency |

### Optimization Problem (F1)

| Parameter | Bounds | Description |
|-----------|---------|-------------|
| `Kp_I` | [0.01, 4.5] | Proportional gain for current controller |
| `Ki_I` | [0.1, 500] | Integral gain for current controller |
| `Kp_V` | [0.01, 10] | Proportional gain for voltage controller |
| `Ki_V` | [0.01, 700] | Integral gain for voltage controller |

## Usage Examples

### Example 1: Basic Optimization Run
```matlab
% Clear workspace and run optimization
clear; clc; close all;

% Run with default settings
enhanced_abc_parallel();

% The algorithm will:
% 1. Initialize population of 100 bees
% 2. Run for 200 iterations
% 3. Save checkpoints every 2 iterations
% 4. Generate final comprehensive report
```

### Example 2: Custom Configuration
```matlab
% Create custom configuration
config = abcConfig();

% Modify for quick test run
config.algorithm.MaxIt = 50;          % Shorter run
config.algorithm.nPop = 30;           % Smaller population
config.memory.checkpointInterval = 10; % Less frequent checkpoints

% Save custom configuration
configFile = 'quick_test_config.mat';
save(configFile, 'config');

% Load configuration in the algorithm (manual modification needed)
% Then run: enhanced_abc_parallel();
```

### Example 3: Analysis of Existing Results
```matlab
% Load and analyze latest checkpoint
loadLatestCheckpointAndReport();

% Generate additional visualizations
data = load('ABC_Optimization_Results/Checkpoints/checkpoint_0200.mat');

% Custom analysis
bestParams = data.ParamHistory(end, :);
fprintf('Best parameters found:\n');
fprintf('  Kp_I: %.4f\n', bestParams(1));
fprintf('  Ki_I: %.4f\n', bestParams(2));
fprintf('  Kp_V: %.4f\n', bestParams(3));
fprintf('  Ki_V: %.4f\n', bestParams(4));

% Plot parameter evolution
figure;
plot(data.ParamHistory);
legend({'Kp_I', 'Ki_I', 'Kp_V', 'Ki_V'});
title('Parameter Evolution');
xlabel('Iteration');
ylabel('Parameter Value');
```

### Example 4: Batch Processing
```matlab
% Run multiple optimization experiments
numExperiments = 5;
results = cell(numExperiments, 1);

for i = 1:numExperiments
    fprintf('Running experiment %d/%d...\n', i, numExperiments);
    
    % Run optimization
    enhanced_abc_parallel();
    
    % Store results
    latestCheckpoint = dir('ABC_Optimization_Results/Checkpoints/checkpoint_*.mat');
    [~, idx] = max([latestCheckpoint.datenum]);
    results{i} = load(fullfile('ABC_Optimization_Results/Checkpoints', latestCheckpoint(idx).name));
    
    % Cleanup for next run
    clear all; clc;
end

% Analyze batch results
bestCosts = cellfun(@(x) x.BestSol.Cost, results);
fprintf('Best cost across experiments: %.6e\n', min(bestCosts));
```

## Output and Results

### Generated Files and Directories

The algorithm automatically creates the following structure:

```
ABC_Optimization_Results_YYYY_MM_DD_HHMMSS/
├── Checkpoints/
│   ├── checkpoint_0002.mat              # Checkpoint files
│   ├── checkpoint_0004.mat
│   └── ...
├── Results/
│   ├── summary_iter_0200_timestamp.txt  # Text summaries
│   ├── final_report_timestamp.txt
│   └── ...
├── Visualizations/
│   ├── convergence_iter_0200.png        # Generated figures
│   ├── diversity_iter_0200.png
│   ├── parameters_iter_0200.png
│   └── ...
└── Statistics/
    ├── statistics_timestamp.mat         # Statistical analysis
    └── detailed_stats_timestamp.txt
```

### Report Types

1. **Text Summaries**: Detailed optimization progress reports
2. **Statistical Analysis**: Comprehensive statistical metrics
3. **Visualizations**: High-quality figures and plots
4. **Excel Logs**: Experiment tracking with timestamps
5. **MATLAB Data Files**: Raw data for further analysis

### Key Metrics Tracked

- **Convergence**: Best cost evolution over iterations
- **Population Diversity**: Measure of solution spread
- **Parameter Trajectories**: Evolution of each optimized parameter
- **Error Analysis**: Current and voltage control errors
- **Performance Statistics**: Runtime, memory usage, iteration timing

## Documentation

### Available Documentation Files

1. **README.md** (this file) - Project overview and quick start
2. **API_DOCUMENTATION.md** - Detailed function and class documentation
3. **USER_GUIDE.md** - Comprehensive user manual with examples
4. **DEVELOPER_GUIDE.md** - Architecture and algorithm details
5. **CONFIGURATION_GUIDE.md** - Complete parameter reference
6. **TROUBLESHOOTING.md** - Common issues and solutions

### Inline Documentation

All MATLAB functions include comprehensive help documentation:
```matlab
help enhanced_abc_parallel    % View function documentation
doc checkpointManager        % View class documentation
```

## Troubleshooting

### Common Issues

#### 1. Parallel Pool Issues
**Problem**: Parallel pool fails to start
**Solutions**:
```matlab
% Check parallel computing toolbox
ver parallel

% Start pool manually
parpool(4);  % Use 4 workers

% Or disable parallel processing
config = abcConfig();
config.parallel.enabled = false;
```

#### 2. Memory Issues
**Problem**: Out of memory errors
**Solutions**:
```matlab
% Reduce population size
config = abcConfig();
config.algorithm.nPop = 50;    % Smaller population
config.memory.maxMemoryMB = 4096;  % Reduce memory limit

% Enable more frequent cleanup
config.memory.cleanupInterval = 2;
```

#### 3. Checkpoint Loading Issues
**Problem**: Cannot load checkpoint files
**Solutions**:
```matlab
% Check checkpoint directory
ls ABC_Optimization_Results/Checkpoints/

% Manual loading
data = load('ABC_Optimization_Results/Checkpoints/checkpoint_0100.mat');

% Clear corrupted checkpoints
delete('ABC_Optimization_Results/Checkpoints/checkpoint_*.mat');
```

#### 4. Function Evaluation Errors
**Problem**: Objective function fails
**Solutions**:
- Verify Simulink model paths
- Check parameter bounds in `Get_Functions_details.m`
- Ensure all required variables are in workspace

### Performance Tips

1. **Use SSD storage** for checkpoint directories
2. **Optimize population size** vs. convergence requirements
3. **Monitor memory usage** during long runs
4. **Use appropriate checkpoint intervals** based on iteration time
5. **Enable parallel processing** for populations > 50

### Getting Help

1. **Check function documentation**: Use `help functionname`
2. **Review example files**: See usage examples above
3. **Check MATLAB console**: Look for warning/error messages
4. **Verify toolbox availability**: Use `ver` command

## Contributing

We welcome contributions to improve this project! Here's how you can help:

### Types of Contributions
- **Bug reports** and fixes
- **Performance improvements**
- **New optimization algorithms**
- **Enhanced visualization features**
- **Documentation improvements**
- **Additional test cases**

### Development Guidelines
1. **Follow MATLAB coding standards**
2. **Add comprehensive documentation** for new functions
3. **Include examples** for new features
4. **Test with different MATLAB versions** when possible
5. **Update documentation** as needed

### Submitting Changes
1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes with proper documentation
4. Test thoroughly
5. Submit a pull request with detailed description

## License

This project is licensed under the **GNU General Public License v3.0**.

### Key Points
- **Free to use, modify, and distribute**
- **Must maintain GPL license** for derivatives
- **No warranty provided**
- **Commercial use allowed** under GPL terms

See the [LICENSE](LICENSE) file for full details.

## Author

**Eng. Ahmed Hany ElBamby**

- **Email**: ahmedhanyelbamby1102003@gmail.com
- **Phone**: +201096562363 (for work only)

### Citation

If you use this code in your research or work, please cite:

```
ElBamby, A. H. (2024). Enhanced Parallel Artificial Bee Colony Algorithm 
for Controller Parameter Optimization. 
GitHub Repository: https://github.com/AhmedelBamby/Swarm-Intelligence-Algorithms-for-Optimization-for-Matlab
```

---

## Acknowledgments

- MATLAB community for optimization algorithm implementations
- Research community working on swarm intelligence algorithms
- Users who provided feedback and suggestions for improvements

---

**Last Updated**: December 2024  
**Version**: 1.0.0