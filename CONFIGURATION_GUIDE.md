# Configuration Guide

This comprehensive guide explains all configuration parameters, their effects, and optimal settings for different use cases in the Enhanced Parallel Artificial Bee Colony (ABC) optimization system.

## Table of Contents

- [Configuration Overview](#configuration-overview)
- [Algorithm Parameters](#algorithm-parameters)
- [Memory Management](#memory-management)
- [Parallel Processing](#parallel-processing)
- [Visualization Settings](#visualization-settings)
- [File Management](#file-management)
- [Statistics Configuration](#statistics-configuration)
- [Performance Tuning](#performance-tuning)
- [Preset Configurations](#preset-configurations)
- [Custom Configuration](#custom-configuration)
- [Troubleshooting Configuration Issues](#troubleshooting-configuration-issues)

## Configuration Overview

The system uses a centralized configuration structure created by `abcConfig()`. All parameters are organized into logical groups for easy management.

### Default Configuration

```matlab
config = abcConfig();

% View complete configuration
disp(config);
```

### Configuration Structure

```
config (struct)
├── algorithm (struct)      - Core ABC algorithm parameters
├── memory (struct)         - Memory management settings  
├── visualization (struct)  - Real-time plotting options
├── files (struct)         - File I/O and directory settings
├── parallel (struct)      - Parallel processing configuration
└── statistics (struct)    - Statistical analysis options
```

## Algorithm Parameters

### Core ABC Algorithm Settings

#### `config.algorithm.MaxIt` (integer)
**Maximum Number of Iterations**

- **Default**: 200
- **Range**: 10 - 10000
- **Description**: Total number of optimization iterations to perform
- **Impact**: Higher values improve solution quality but increase runtime

```matlab
% Quick test
config.algorithm.MaxIt = 50;

% Standard optimization
config.algorithm.MaxIt = 200;

% High-quality optimization
config.algorithm.MaxIt = 500;

% Research-grade optimization
config.algorithm.MaxIt = 1000;
```

**Tuning Guidelines:**
- For 2-4 parameters: 50-100 iterations typically sufficient
- For controller tuning: 100-300 iterations recommended
- For research: 500-1000 iterations for publication-quality results

#### `config.algorithm.nPop` (integer)
**Population Size (Number of Bees)**

- **Default**: 100
- **Range**: 10 - 1000
- **Description**: Total number of candidate solutions in the population
- **Impact**: Larger populations provide better exploration but require more computation

```matlab
% Small population (fast, may get trapped)
config.algorithm.nPop = 30;

% Medium population (balanced)
config.algorithm.nPop = 100;

% Large population (thorough exploration)
config.algorithm.nPop = 200;

% Very large population (research applications)
config.algorithm.nPop = 500;
```

**Selection Guidelines:**
- **Problem dimension 2-5**: 20-50 bees
- **Problem dimension 5-10**: 50-100 bees  
- **Problem dimension 10+**: 100-200+ bees
- **Multi-modal problems**: Use larger populations (100-300)

#### `config.algorithm.nOnlooker` (integer)
**Number of Onlooker Bees**

- **Default**: 50
- **Range**: 5 - 500
- **Description**: Number of onlooker bees for exploitation phase
- **Typical Ratio**: 0.5 × nPop (50% of population)

```matlab
% Conservative exploitation
config.algorithm.nOnlooker = round(0.3 * config.algorithm.nPop);

% Balanced exploration/exploitation
config.algorithm.nOnlooker = round(0.5 * config.algorithm.nPop);

% Aggressive exploitation
config.algorithm.nOnlooker = round(0.7 * config.algorithm.nPop);
```

**Optimization Strategies:**
- **Exploration focus**: Lower onlooker ratio (0.3-0.4)
- **Exploitation focus**: Higher onlooker ratio (0.6-0.7)
- **Balanced approach**: Standard ratio (0.5)

#### `config.algorithm.L` (integer)
**Abandonment Limit**

- **Default**: 120
- **Range**: 10 - 1000  
- **Description**: Number of trials before a solution is abandoned
- **Impact**: Higher values increase exploitation, lower values increase exploration

```matlab
% High exploration (early abandonment)
config.algorithm.L = 50;

% Balanced approach
config.algorithm.L = 100;

% High exploitation (late abandonment)  
config.algorithm.L = 200;

% Adaptive formula
config.algorithm.L = config.algorithm.nPop + 50;
```

**Tuning Rules:**
- **Simple problems**: L = 50-100
- **Complex problems**: L = 100-200
- **Multi-modal problems**: L = 50-80 (more exploration)
- **Fine-tuning**: L = 150-300 (more exploitation)

#### `config.algorithm.a` (double)
**Acceleration Coefficient**

- **Default**: 1.5
- **Range**: 0.1 - 3.0
- **Description**: Controls step size in solution generation
- **Impact**: Higher values increase search diversity but may reduce convergence

```matlab
% Conservative search (small steps)
config.algorithm.a = 0.5;

% Standard search
config.algorithm.a = 1.5;

% Aggressive search (large steps)
config.algorithm.a = 2.5;

% Adaptive acceleration
config.algorithm.a = @(iter, maxIter) 2.5 - 2.0 * iter / maxIter;
```

**Application Guidelines:**
- **Local optimization**: a = 0.5-1.0
- **Global optimization**: a = 1.5-2.5  
- **Noisy problems**: a = 0.8-1.2
- **Smooth problems**: a = 1.5-2.5

## Memory Management

### Memory Configuration Settings

#### `config.memory.maxMemoryMB` (integer)
**Maximum Memory Usage in Megabytes**

- **Default**: 10240 (10 GB)
- **Range**: 512 - 102400 (0.5 GB - 100 GB)
- **Description**: RAM limit for optimization data storage
- **Behavior**: Excess data automatically moved to disk cache

```matlab
% Low memory systems
config.memory.maxMemoryMB = 2048;  % 2 GB

% Standard workstations
config.memory.maxMemoryMB = 8192;  % 8 GB

% High-performance systems
config.memory.maxMemoryMB = 32768; % 32 GB

% Automatic sizing (80% of available RAM)
memInfo = memory;
availableGB = memInfo.PhysicalMemory.Available / 1024^3;
config.memory.maxMemoryMB = round(0.8 * availableGB * 1024);
```

**Memory Estimation:**
- **Population data**: ~100 bytes × nPop × MaxIt
- **History arrays**: ~8 bytes × MaxIt × nVar  
- **Checkpoint data**: ~1-10 MB per checkpoint
- **Visualizations**: ~5-20 MB for plots

#### `config.memory.checkpointInterval` (integer)
**Checkpoint Save Frequency**

- **Default**: 2
- **Range**: 1 - 100
- **Description**: Save optimization state every N iterations
- **Trade-off**: Lower values provide better recovery but slower performance

```matlab
% Frequent checkpoints (maximum safety)
config.memory.checkpointInterval = 1;

% Balanced approach
config.memory.checkpointInterval = 5;

% Infrequent checkpoints (maximum performance)
config.memory.checkpointInterval = 20;

% Adaptive checkpointing
if config.algorithm.MaxIt <= 50
    config.memory.checkpointInterval = 5;
elseif config.algorithm.MaxIt <= 200
    config.memory.checkpointInterval = 10;
else
    config.memory.checkpointInterval = 25;
end
```

**Recommendations by Use Case:**
- **Development/testing**: Every 1-2 iterations
- **Production runs**: Every 5-10 iterations
- **Long experiments**: Every 20-50 iterations
- **Stable systems**: Every 10-20 iterations

#### `config.memory.cleanupInterval` (integer)
**Memory Cleanup Frequency**

- **Default**: 5
- **Range**: 1 - 50
- **Description**: Perform memory cleanup every N iterations
- **Purpose**: Prevents memory leaks and fragmentation

```matlab
% Aggressive cleanup (slower but more stable)
config.memory.cleanupInterval = 2;

% Standard cleanup
config.memory.cleanupInterval = 5;

% Minimal cleanup (faster but may accumulate memory)
config.memory.cleanupInterval = 20;
```

## Parallel Processing

### Parallel Configuration Options

#### `config.parallel.enabled` (logical)
**Enable/Disable Parallel Processing**

- **Default**: true
- **Description**: Controls whether parallel computing is used
- **Requirements**: Parallel Computing Toolbox

```matlab
% Enable parallel processing
config.parallel.enabled = true;

% Disable parallel processing
config.parallel.enabled = false;

% Conditional enabling
config.parallel.enabled = license('test', 'Distrib_Computing_Toolbox');
```

#### `config.parallel.numWorkers` (integer)
**Number of Parallel Workers**

- **Default**: `feature('numcores')` (all available CPU cores)
- **Range**: 1 - 512
- **Description**: Number of MATLAB parallel workers to use

```matlab
% Use all available cores
config.parallel.numWorkers = feature('numcores');

% Conservative approach (leave cores for system)
config.parallel.numWorkers = max(1, feature('numcores') - 2);

% Fixed number of workers
config.parallel.numWorkers = 4;

% Optimize based on population size
optimalWorkers = min(feature('numcores'), ceil(config.algorithm.nPop / 10));
config.parallel.numWorkers = optimalWorkers;
```

**Performance Guidelines:**
- **Small populations (< 50)**: 2-4 workers
- **Medium populations (50-150)**: 4-8 workers
- **Large populations (150+)**: 8+ workers
- **Memory-constrained**: Fewer workers to reduce memory overhead

#### Advanced Parallel Settings

```matlab
% Custom parallel pool configuration
config.parallel.poolConfig = struct(...
    'IdleTimeout', Inf, ...           % Keep pool alive indefinitely
    'AttachedFiles', {}, ...          % Additional files to distribute
    'AutoAddClientPath', true, ...    % Add client path automatically  
    'SpmdEnabled', true ...           % Enable SPMD functionality
);

% Cluster configuration (for HPC environments)
config.parallel.cluster = struct(...
    'Profile', 'local', ...           % Cluster profile
    'JobStorageLocation', tempdir, ...% Job storage directory
    'NumWorkersRange', [1, 64] ...    % Worker range
);
```

## Visualization Settings

### Real-time Visualization Options

#### `config.visualization.updateInterval` (integer)
**Visualization Update Frequency**

- **Default**: 1
- **Range**: 1 - 100
- **Description**: Update plots every N iterations
- **Impact**: Lower values provide smoother visualization but may slow optimization

```matlab
% Real-time updates (every iteration)
config.visualization.updateInterval = 1;

% Moderate updates
config.visualization.updateInterval = 5;

% Infrequent updates (performance focused)
config.visualization.updateInterval = 20;
```

#### `config.visualization.saveInterval` (integer)
**Plot Save Frequency**

- **Default**: 10
- **Range**: 1 - 1000
- **Description**: Save visualization plots every N iterations

```matlab
% Frequent saving
config.visualization.saveInterval = 5;

% Standard saving
config.visualization.saveInterval = 10;

% Minimal saving (final results only)
config.visualization.saveInterval = 1000;
```

#### `config.visualization.realTime` (logical)
**Enable Real-time Plotting**

- **Default**: true
- **Description**: Display live plots during optimization
- **Performance Impact**: Can slow down optimization significantly

```matlab
% Enable for monitoring
config.visualization.realTime = true;

% Disable for maximum performance
config.visualization.realTime = false;

% Conditional based on run length
config.visualization.realTime = config.algorithm.MaxIt <= 100;
```

### Advanced Visualization Settings

```matlab
% Custom plot configuration
config.visualization.plots = struct(...
    'convergence', true, ...          % Show convergence plot
    'diversity', true, ...            % Show diversity plot
    'parameters', true, ...           % Show parameter evolution
    'agents3d', false, ...            % Show 3D agent positions
    'errorAnalysis', true ...         % Show error analysis
);

% Figure properties
config.visualization.figureSettings = struct(...
    'Position', [100, 100, 1200, 800], ...  % Figure position and size
    'Color', 'white', ...                    % Background color
    'Renderer', 'painters', ...              % Rendering engine
    'PaperType', 'A4' ...                   % Paper size for saving
);
```

## File Management

### File I/O Configuration

#### `config.files.baseDir` (string)
**Base Directory for Results**

- **Default**: 'ABC_Optimization_Results'
- **Description**: Root directory for all output files
- **Auto-creation**: Directory created automatically if it doesn't exist

```matlab
% Default location (current directory)
config.files.baseDir = 'ABC_Optimization_Results';

% Custom location
config.files.baseDir = '/path/to/results';

% Timestamped directory
timestamp = datestr(now, 'yyyy_mm_dd_HHMMSS');
config.files.baseDir = sprintf('ABC_Results_%s', timestamp);

% Network storage (if accessible)
config.files.baseDir = '\\networkdrive\experiments\ABC';

% Fast storage (SSD)
if ispc
    config.files.baseDir = 'D:\ABC_Results';  % Assuming D: is SSD
else
    config.files.baseDir = '/tmp/ABC_Results';
end
```

#### `config.files.timestamp` (string)
**Timestamp Format**

- **Default**: `datestr(now, 'yyyy_mm_dd_HHMMSS')`
- **Description**: Format for timestamp strings in filenames

```matlab
% Standard format
config.files.timestamp = datestr(now, 'yyyy_mm_dd_HHMMSS');

% ISO format
config.files.timestamp = datestr(now, 'yyyy-mm-ddTHH:MM:SS');

% Custom format
config.files.timestamp = datestr(now, 'yyyymmdd_HHMMSS');

% Include milliseconds for uniqueness
config.files.timestamp = [datestr(now, 'yyyy_mm_dd_HHMMSS'), '_', ...
                         num2str(round(rand()*1000))];
```

### Advanced File Settings

```matlab
% File compression settings
config.files.compression = struct(...
    'enabled', true, ...              % Enable file compression
    'level', 6, ...                   % Compression level (1-9)
    'method', 'gzip' ...             % Compression method
);

% Backup configuration
config.files.backup = struct(...
    'enabled', true, ...              % Enable automatic backups
    'interval', 10, ...               % Backup every N checkpoints
    'maxBackups', 5, ...              % Maximum backup files to keep
    'location', 'backup/' ...         % Backup subdirectory
);

% Export formats
config.files.exportFormats = struct(...
    'matlab', true, ...               % .mat files
    'excel', true, ...                % .xlsx files
    'csv', false, ...                 % .csv files
    'json', false ...                 % .json files
);
```

## Statistics Configuration

### Statistical Analysis Settings

#### `config.statistics.detailed` (logical)
**Enable Detailed Statistical Analysis**

- **Default**: true
- **Description**: Compute comprehensive statistics
- **Impact**: More detailed analysis but higher computational cost

```matlab
% Full statistical analysis
config.statistics.detailed = true;

% Basic statistics only
config.statistics.detailed = false;

% Conditional based on population size
config.statistics.detailed = config.algorithm.nPop >= 50;
```

#### `config.statistics.exportInterval` (integer)
**Statistics Export Frequency**

- **Default**: 2
- **Range**: 1 - 100
- **Description**: Export statistical analysis every N iterations

```matlab
% Frequent exports
config.statistics.exportInterval = 1;

% Standard exports
config.statistics.exportInterval = 5;

% Final export only
config.statistics.exportInterval = config.algorithm.MaxIt;
```

### Custom Statistics Configuration

```matlab
% Statistics to compute
config.statistics.metrics = struct(...
    'convergenceAnalysis', true, ...   % Convergence rate analysis
    'diversityMetrics', true, ...      % Population diversity measures
    'parameterStatistics', true, ...   % Parameter evolution statistics
    'performanceMetrics', true, ...    % Algorithm performance metrics
    'errorAnalysis', true ...          % Objective function error analysis
);

% Statistical tests
config.statistics.tests = struct(...
    'normalityTests', true, ...        % Test for normal distribution
    'convergenceTests', true, ...      % Test for convergence
    'stabilityTests', false ...        % Test for solution stability
);
```

## Performance Tuning

### Optimizing for Different Scenarios

#### High-Performance Computing Configuration

```matlab
function config = hpcConfig()
    config = abcConfig();
    
    % Algorithm settings for HPC
    config.algorithm.MaxIt = 1000;
    config.algorithm.nPop = 500;
    config.algorithm.nOnlooker = 250;
    
    % Memory settings for HPC
    config.memory.maxMemoryMB = 102400;  % 100 GB
    config.memory.checkpointInterval = 50;
    config.memory.cleanupInterval = 20;
    
    % Parallel settings for HPC
    config.parallel.enabled = true;
    config.parallel.numWorkers = 64;
    
    % Disable resource-intensive visualization
    config.visualization.realTime = false;
    config.visualization.updateInterval = 100;
    
    % Optimize file I/O
    config.files.baseDir = '/scratch/ABC_Results';  % Fast scratch storage
    config.statistics.exportInterval = 100;
end
```

#### Low-Resource Configuration

```matlab
function config = lowResourceConfig()
    config = abcConfig();
    
    % Reduced algorithm parameters
    config.algorithm.MaxIt = 100;
    config.algorithm.nPop = 30;
    config.algorithm.nOnlooker = 15;
    
    % Conservative memory usage
    config.memory.maxMemoryMB = 1024;   % 1 GB
    config.memory.checkpointInterval = 2;
    config.memory.cleanupInterval = 2;
    
    % Minimal parallel processing
    config.parallel.enabled = false;
    
    % Disable visualization
    config.visualization.realTime = false;
    config.visualization.saveInterval = 1000;
    
    % Minimal statistics
    config.statistics.detailed = false;
    config.statistics.exportInterval = 50;
end
```

#### Development/Debug Configuration

```matlab
function config = debugConfig()
    config = abcConfig();
    
    % Quick iterations for testing
    config.algorithm.MaxIt = 20;
    config.algorithm.nPop = 10;
    
    % Frequent checkpoints for debugging
    config.memory.checkpointInterval = 1;
    config.memory.cleanupInterval = 1;
    
    % Disable parallel processing for easier debugging
    config.parallel.enabled = false;
    
    % Enable all visualization for monitoring
    config.visualization.realTime = true;
    config.visualization.updateInterval = 1;
    
    % Detailed statistics for analysis
    config.statistics.detailed = true;
    config.statistics.exportInterval = 1;
end
```

## Preset Configurations

### Quick Test Configuration

```matlab
function config = quickTestConfig()
%% Quick test configuration for rapid prototyping
    config = abcConfig();
    
    % Fast execution
    config.algorithm.MaxIt = 30;
    config.algorithm.nPop = 20;
    config.algorithm.nOnlooker = 10;
    config.algorithm.L = 40;
    
    % Minimal resource usage
    config.memory.maxMemoryMB = 1024;
    config.memory.checkpointInterval = 10;
    
    % Basic visualization
    config.visualization.realTime = true;
    config.visualization.updateInterval = 5;
    
    % Disable parallel processing for simplicity
    config.parallel.enabled = false;
end
```

### Production Configuration

```matlab
function config = productionConfig()
%% Production configuration for reliable results
    config = abcConfig();
    
    % Standard optimization parameters
    config.algorithm.MaxIt = 200;
    config.algorithm.nPop = 100;
    config.algorithm.nOnlooker = 50;
    config.algorithm.L = 150;
    
    % Robust memory management
    config.memory.maxMemoryMB = 8192;
    config.memory.checkpointInterval = 10;
    config.memory.cleanupInterval = 5;
    
    % Enable parallel processing
    config.parallel.enabled = true;
    config.parallel.numWorkers = min(8, feature('numcores'));
    
    % Balanced visualization
    config.visualization.realTime = false;
    config.visualization.saveInterval = 20;
    
    % Comprehensive statistics
    config.statistics.detailed = true;
    config.statistics.exportInterval = 10;
end
```

### Research Configuration

```matlab
function config = researchConfig()
%% Research configuration for publication-quality results
    config = abcConfig();
    
    % Extensive optimization
    config.algorithm.MaxIt = 500;
    config.algorithm.nPop = 200;
    config.algorithm.nOnlooker = 100;
    config.algorithm.L = 300;
    config.algorithm.a = 1.2;  % Conservative exploration
    
    % High memory allocation
    config.memory.maxMemoryMB = 16384;
    config.memory.checkpointInterval = 25;
    
    % Maximum parallel utilization
    config.parallel.enabled = true;
    config.parallel.numWorkers = feature('numcores');
    
    % Comprehensive analysis
    config.statistics.detailed = true;
    config.statistics.exportInterval = 25;
    
    % High-quality visualizations
    config.visualization.saveInterval = 50;
    
    % Timestamped results directory
    config.files.baseDir = sprintf('Research_Results_%s', ...
                                  datestr(now, 'yyyy_mm_dd_HHMMSS'));
end
```

## Custom Configuration

### Creating Custom Configurations

#### Step 1: Start with Base Configuration

```matlab
function config = myCustomConfig()
    % Start with default configuration
    config = abcConfig();
    
    % Modify specific parameters
    config.algorithm.MaxIt = 150;
    config.algorithm.nPop = 75;
    
    % Add custom fields if needed
    config.custom = struct();
    config.custom.experimentName = 'MyExperiment';
    config.custom.author = 'Your Name';
    config.custom.description = 'Custom configuration for specific problem';
end
```

#### Step 2: Problem-Specific Tuning

```matlab
function config = controllerTuningConfig(problemComplexity)
    config = abcConfig();
    
    switch lower(problemComplexity)
        case 'simple'
            config.algorithm.MaxIt = 100;
            config.algorithm.nPop = 50;
            config.algorithm.L = 75;
            
        case 'medium'
            config.algorithm.MaxIt = 200;
            config.algorithm.nPop = 100;
            config.algorithm.L = 150;
            
        case 'complex'
            config.algorithm.MaxIt = 400;
            config.algorithm.nPop = 200;
            config.algorithm.L = 300;
    end
    
    % Controller-specific settings
    config.algorithm.a = 1.2;  % Conservative for stability
    config.statistics.detailed = true;
    config.visualization.realTime = true;
end
```

#### Step 3: Environment-Specific Configuration

```matlab
function config = environmentSpecificConfig()
    config = abcConfig();
    
    % Detect system capabilities
    memInfo = memory;
    totalMemoryGB = memInfo.PhysicalMemory.Total / 1024^3;
    numCores = feature('numcores');
    
    % Adaptive memory configuration
    if totalMemoryGB < 8
        config.memory.maxMemoryMB = 2048;
        config.algorithm.nPop = 50;
    elseif totalMemoryGB < 16
        config.memory.maxMemoryMB = 4096;
        config.algorithm.nPop = 100;
    else
        config.memory.maxMemoryMB = 8192;
        config.algorithm.nPop = 200;
    end
    
    % Adaptive parallel configuration
    if numCores <= 2
        config.parallel.enabled = false;
    elseif numCores <= 4
        config.parallel.numWorkers = 2;
    else
        config.parallel.numWorkers = min(8, numCores);
    end
    
    % Storage optimization
    if ispc
        % Try to use SSD on Windows
        possibleSSDPaths = {'D:', 'E:', 'F:'};
        for path = possibleSSDPaths
            if exist(path{1}, 'dir')
                config.files.baseDir = fullfile(path{1}, 'ABC_Results');
                break;
            end
        end
    else
        % Use /tmp on Unix systems
        config.files.baseDir = '/tmp/ABC_Results';
    end
end
```

### Configuration Validation

```matlab
function validateConfiguration(config)
    % Validate algorithm parameters
    assert(config.algorithm.MaxIt > 0, 'MaxIt must be positive');
    assert(config.algorithm.nPop > 0, 'nPop must be positive');
    assert(config.algorithm.nOnlooker <= config.algorithm.nPop, ...
           'nOnlooker cannot exceed nPop');
    assert(config.algorithm.L > 0, 'L must be positive');
    assert(config.algorithm.a > 0, 'a must be positive');
    
    % Validate memory parameters
    assert(config.memory.maxMemoryMB > 0, 'maxMemoryMB must be positive');
    assert(config.memory.checkpointInterval > 0, ...
           'checkpointInterval must be positive');
    
    % Validate parallel parameters
    if config.parallel.enabled
        assert(config.parallel.numWorkers > 0, ...
               'numWorkers must be positive when parallel enabled');
        assert(license('test', 'Distrib_Computing_Toolbox'), ...
               'Parallel Computing Toolbox required');
    end
    
    % Validate file parameters
    assert(ischar(config.files.baseDir), 'baseDir must be a string');
    
    fprintf('Configuration validation passed ✓\n');
end
```

## Troubleshooting Configuration Issues

### Common Configuration Problems

#### Problem 1: Out of Memory Errors

**Symptoms:**
- MATLAB crashes with out of memory error
- System becomes unresponsive
- Warning messages about memory usage

**Solutions:**
```matlab
% Reduce memory usage
config.memory.maxMemoryMB = 2048;           % Reduce memory limit
config.algorithm.nPop = 50;                 % Smaller population
config.memory.checkpointInterval = 2;       % More frequent checkpoints
config.memory.cleanupInterval = 2;          % More frequent cleanup

% Disable memory-intensive features
config.visualization.realTime = false;      % Disable real-time plots
config.statistics.detailed = false;         % Reduce statistical analysis
```

#### Problem 2: Parallel Processing Issues

**Symptoms:**
- Parallel pool fails to start
- Workers crash during execution
- Poor parallel performance

**Solutions:**
```matlab
% Fix parallel pool issues
delete(gcp('nocreate'));                    % Close existing pool
config.parallel.numWorkers = 2;             % Reduce worker count
config.parallel.enabled = false;            % Disable if persistent issues

% Alternative: Manual pool management
if license('test', 'Distrib_Computing_Toolbox')
    try
        parpool('local', 4);
        config.parallel.enabled = true;
    catch
        config.parallel.enabled = false;
        warning('Could not start parallel pool, using serial execution');
    end
end
```

#### Problem 3: Slow Convergence

**Symptoms:**
- Algorithm takes too many iterations to converge
- Best cost doesn't improve after many iterations
- Population loses diversity quickly

**Solutions:**
```matlab
% Increase exploration
config.algorithm.nPop = 150;                % Larger population
config.algorithm.L = 75;                    % Earlier abandonment
config.algorithm.a = 2.0;                   % Larger step size

% Reduce exploitation
config.algorithm.nOnlooker = round(0.3 * config.algorithm.nPop);

% Adaptive parameters
config.algorithm.a = @(iter, maxIter) 2.5 - 1.5 * iter / maxIter;
```

#### Problem 4: File I/O Issues

**Symptoms:**
- Cannot save checkpoints
- Permission errors
- Disk space issues

**Solutions:**
```matlab
% Fix file access issues
config.files.baseDir = tempdir();           % Use temporary directory
config.memory.checkpointInterval = 20;      % Reduce checkpoint frequency

% Check disk space before running
[status, result] = system('df -h .');        % Unix/Linux
% [status, result] = system('dir /-c');     % Windows

% Create directory if it doesn't exist
if ~exist(config.files.baseDir, 'dir')
    mkdir(config.files.baseDir);
end
```

### Configuration Testing

```matlab
function testConfiguration(config)
    fprintf('Testing configuration...\n');
    
    % Test 1: Basic parameter validation
    try
        validateConfiguration(config);
        fprintf('✓ Parameter validation passed\n');
    catch ME
        fprintf('✗ Parameter validation failed: %s\n', ME.message);
        return;
    end
    
    % Test 2: Memory allocation test
    try
        testArray = zeros(1000, 1000);  % 8MB test array
        clear testArray;
        fprintf('✓ Memory allocation test passed\n');
    catch
        fprintf('✗ Memory allocation test failed\n');
    end
    
    % Test 3: Parallel processing test
    if config.parallel.enabled
        try
            parfor i = 1:config.parallel.numWorkers
                dummy = rand(100, 100);
            end
            fprintf('✓ Parallel processing test passed\n');
        catch ME
            fprintf('✗ Parallel processing test failed: %s\n', ME.message);
        end
    end
    
    % Test 4: File I/O test
    try
        testFile = fullfile(config.files.baseDir, 'test.mat');
        save(testFile, 'config');
        delete(testFile);
        fprintf('✓ File I/O test passed\n');
    catch ME
        fprintf('✗ File I/O test failed: %s\n', ME.message);
    end
    
    fprintf('Configuration testing completed\n');
end
```

### Configuration Best Practices

1. **Always validate configurations** before running long optimizations
2. **Start with conservative settings** and increase gradually
3. **Monitor system resources** during optimization
4. **Use environment-specific configurations** for different machines
5. **Save successful configurations** for future use
6. **Document custom configurations** with comments
7. **Test configurations** with short runs before production use

---

This configuration guide provides comprehensive coverage of all system parameters. For additional help with specific configuration issues, refer to the troubleshooting section or contact support.

**Last Updated**: December 2024  
**Version**: 1.0.0