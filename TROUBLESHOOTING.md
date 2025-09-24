# Troubleshooting Guide

This comprehensive troubleshooting guide helps diagnose and resolve common issues with the Enhanced Parallel Artificial Bee Colony (ABC) optimization system.

## Table of Contents

- [Quick Diagnostic Checklist](#quick-diagnostic-checklist)
- [Installation and Setup Issues](#installation-and-setup-issues)
- [Algorithm Execution Problems](#algorithm-execution-problems)
- [Parallel Processing Issues](#parallel-processing-issues)
- [Memory and Performance Problems](#memory-and-performance-problems)
- [File I/O and Checkpoint Issues](#file-io-and-checkpoint-issues)
- [Visualization Problems](#visualization-problems)
- [Convergence and Solution Quality Issues](#convergence-and-solution-quality-issues)
- [Error Messages and Solutions](#error-messages-and-solutions)
- [System-Specific Issues](#system-specific-issues)
- [Performance Optimization](#performance-optimization)
- [Getting Additional Help](#getting-additional-help)

## Quick Diagnostic Checklist

Before diving into detailed troubleshooting, run this quick diagnostic:

```matlab
function runQuickDiagnostic()
%% Quick Diagnostic for ABC Optimization System
    fprintf('=== ABC OPTIMIZATION SYSTEM DIAGNOSTIC ===\n\n');
    
    % 1. MATLAB Version Check
    fprintf('1. MATLAB Version:\n');
    version_info = version('-release');
    fprintf('   Current: %s\n', version_info);
    if str2double(version_info(1:4)) >= 2019
        fprintf('   Status: ✓ Compatible\n');
    else
        fprintf('   Status: ⚠ May have compatibility issues (R2019b+ recommended)\n');
    end
    
    % 2. Toolbox Check
    fprintf('\n2. Required Toolboxes:\n');
    toolboxes = {'Distrib_Computing_Toolbox', 'Statistics_Toolbox', 'Optimization_Toolbox'};
    toolbox_names = {'Parallel Computing', 'Statistics and Machine Learning', 'Optimization'};
    
    for i = 1:length(toolboxes)
        if license('test', toolboxes{i})
            fprintf('   %s: ✓ Available\n', toolbox_names{i});
        else
            fprintf('   %s: ✗ Not available\n', toolbox_names{i});
        end
    end
    
    % 3. Memory Check
    fprintf('\n3. System Memory:\n');
    try
        mem_info = memory;
        total_gb = mem_info.PhysicalMemory.Total / 1024^3;
        available_gb = mem_info.PhysicalMemory.Available / 1024^3;
        fprintf('   Total: %.1f GB\n', total_gb);
        fprintf('   Available: %.1f GB\n', available_gb);
        if available_gb >= 4
            fprintf('   Status: ✓ Sufficient memory\n');
        elseif available_gb >= 2
            fprintf('   Status: ⚠ Limited memory (consider small population sizes)\n');
        else
            fprintf('   Status: ✗ Insufficient memory\n');
        end
    catch
        fprintf('   Status: ⚠ Cannot determine memory status\n');
    end
    
    % 4. File System Check
    fprintf('\n4. File System Access:\n');
    try
        test_dir = 'ABC_Test_Directory';
        mkdir(test_dir);
        test_file = fullfile(test_dir, 'test.mat');
        save(test_file, 'version_info');
        delete(test_file);
        rmdir(test_dir);
        fprintf('   Status: ✓ File system access OK\n');
    catch ME
        fprintf('   Status: ✗ File system access issue: %s\n', ME.message);
    end
    
    % 5. Parallel Pool Check
    fprintf('\n5. Parallel Processing:\n');
    try
        if license('test', 'Distrib_Computing_Toolbox')
            current_pool = gcp('nocreate');
            if isempty(current_pool)
                fprintf('   Pool Status: No active pool\n');
            else
                fprintf('   Pool Status: ✓ Active pool with %d workers\n', current_pool.NumWorkers);
            end
            
            % Test parallel for loop
            tic;
            parfor i = 1:4
                dummy = rand(100, 100) * rand(100, 100);
            end
            parallel_time = toc;
            fprintf('   Performance Test: ✓ Completed in %.3f seconds\n', parallel_time);
        else
            fprintf('   Status: ✗ Parallel Computing Toolbox not available\n');
        end
    catch ME
        fprintf('   Status: ⚠ Parallel processing issue: %s\n', ME.message);
    end
    
    % 6. Core Functions Check
    fprintf('\n6. Core Functions:\n');
    functions_to_check = {'abcConfig', 'Get_Functions_details', 'enhanced_abc_parallel'};
    
    for func = functions_to_check
        if exist(func{1}, 'file')
            fprintf('   %s: ✓ Found\n', func{1});
        else
            fprintf('   %s: ✗ Missing (check MATLAB path)\n', func{1});
        end
    end
    
    fprintf('\n=== DIAGNOSTIC COMPLETE ===\n');
    fprintf('If issues are detected, refer to specific sections below.\n\n');
end

% Run the diagnostic
runQuickDiagnostic();
```

## Installation and Setup Issues

### Issue 1: Functions Not Found

**Error Messages:**
- `Undefined function or variable 'enhanced_abc_parallel'`
- `Undefined function 'abcConfig'`

**Cause:** MATLAB cannot find the project files in its path.

**Solutions:**

```matlab
% Solution 1: Add current directory to path
addpath(pwd);
savepath;  % Make permanent

% Solution 2: Navigate to project directory first
cd('path/to/your/project/directory');
addpath(pwd);

% Solution 3: Add all subdirectories
addpath(genpath(pwd));

% Solution 4: Check current path
path  % Display current MATLAB path
which enhanced_abc_parallel  % Check if function is found
```

### Issue 2: Missing Toolboxes

**Error Messages:**
- `License checkout failed`
- `Undefined function 'parfor'`

**Cause:** Required MATLAB toolboxes are not installed or licensed.

**Solutions:**

```matlab
% Check toolbox availability
license('test', 'Distrib_Computing_Toolbox')
license('test', 'Statistics_Toolbox')

% Alternative approach without parallel computing
config = abcConfig();
config.parallel.enabled = false;  % Disable parallel processing

% Check installed toolboxes
ver  % List all installed toolboxes
```

### Issue 3: Version Compatibility

**Error Messages:**
- `Unexpected MATLAB expression`
- Function-specific syntax errors

**Cause:** Using incompatible MATLAB version (older than R2019b).

**Solutions:**

```matlab
% Check MATLAB version
version('-release')

% For older MATLAB versions, modify code:
% Replace: arguments block with traditional input validation
% Replace: string arrays with cell arrays
% Replace: newer plotting functions with older equivalents

% Example modification for older versions:
% Instead of: arguments block
% Use:
if nargin < 1, error('Not enough input arguments'); end
if ~isnumeric(input), error('Input must be numeric'); end
```

## Algorithm Execution Problems

### Issue 1: Algorithm Doesn't Start

**Symptoms:**
- No output after calling `enhanced_abc_parallel()`
- MATLAB appears frozen

**Diagnostic Steps:**

```matlab
% Step 1: Check if function exists
which enhanced_abc_parallel

% Step 2: Test with minimal configuration
config = abcConfig();
config.algorithm.MaxIt = 5;
config.algorithm.nPop = 10;
config.parallel.enabled = false;
config.visualization.realTime = false;

% Step 3: Enable debug mode
dbstop if error  % Stop at errors
dbstop if warning  % Stop at warnings
```

**Common Causes and Solutions:**

1. **Infinite loop in objective function:**
```matlab
% Add timeout to objective function evaluation
function cost = evaluateWithTimeout(func, params, timeout)
    if nargin < 3, timeout = 30; end  % 30 second default
    
    timer_obj = timer('StartDelay', timeout, ...
                     'TimerFcn', @(~,~) error('Function evaluation timeout'));
    start(timer_obj);
    
    try
        cost = func(params);
        stop(timer_obj);
        delete(timer_obj);
    catch ME
        stop(timer_obj);
        delete(timer_obj);
        rethrow(ME);
    end
end
```

2. **Path issues with objective function:**
```matlab
% Test objective function directly
[lb, ub, dim, fobj] = Get_Functions_details('F1');
test_params = (lb + ub) / 2;  % Middle of bounds
try
    test_cost = fobj(test_params);
    fprintf('Objective function test: cost = %f\n', test_cost);
catch ME
    fprintf('Objective function error: %s\n', ME.message);
end
```

### Issue 2: Algorithm Stops Prematurely

**Symptoms:**
- Optimization stops before MaxIt iterations
- No error messages
- Incomplete results

**Diagnostic Code:**

```matlab
% Add termination logging
function enhanced_abc_parallel_debug()
    % ... (existing setup code) ...
    
    for it = 1:MaxIt
        fprintf('Starting iteration %d...\n', it);
        
        try
            % ... (existing iteration code) ...
            fprintf('Iteration %d completed successfully\n', it);
        catch ME
            fprintf('Error in iteration %d: %s\n', it, ME.message);
            fprintf('Stack trace:\n');
            for i = 1:length(ME.stack)
                fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
            end
            break;
        end
    end
end
```

**Common Solutions:**

1. **Memory issues:**
```matlab
% Monitor memory usage
for it = 1:MaxIt
    % ... optimization code ...
    
    if mod(it, 10) == 0
        mem_info = memory;
        used_gb = mem_info.MemUsedMATLAB / 1024^3;
        fprintf('Memory used: %.2f GB\n', used_gb);
        
        if used_gb > 6  % Threshold
            pack;  % Optimize memory
        end
    end
end
```

2. **Checkpoint corruption:**
```matlab
% Verify checkpoint integrity before loading
function isValid = verifyCheckpoint(filename)
    try
        data = load(filename);
        required_fields = {'BestCost', 'population', 'iteration'};
        isValid = all(isfield(data, required_fields));
    catch
        isValid = false;
    end
end
```

## Parallel Processing Issues

### Issue 1: Parallel Pool Won't Start

**Error Messages:**
- `Failed to initialize the interactive session`
- `Unable to start parallel pool`

**Solutions:**

```matlab
% Solution 1: Reset parallel preferences
ps = parallel.Settings;
delete(ps);

% Solution 2: Manual pool management
delete(gcp('nocreate'));  % Delete existing pool
pause(2);  % Wait for cleanup
parpool('local', 4);  % Start with specific number of workers

% Solution 3: Disable parallel processing
config = abcConfig();
config.parallel.enabled = false;

% Solution 4: Check for conflicts
% Close other programs using MATLAB parallel computing
% Restart MATLAB if necessary
```

### Issue 2: Workers Crash During Execution

**Symptoms:**
- `Worker has been lost` messages
- Parallel jobs fail intermittently

**Diagnostic Code:**

```matlab
% Test worker stability
function testWorkerStability()
    try
        parpool(4);
        
        % Test 1: Simple computation
        parfor i = 1:4
            result(i) = sum(rand(1000, 1000));
        end
        fprintf('✓ Simple computation test passed\n');
        
        % Test 2: Memory intensive
        parfor i = 1:4
            temp = rand(2000, 2000);
            result(i) = mean(temp(:));
        end
        fprintf('✓ Memory intensive test passed\n');
        
        % Test 3: Function calls
        parfor i = 1:4
            result(i) = testFunction(rand(100, 4));
        end
        fprintf('✓ Function call test passed\n');
        
    catch ME
        fprintf('✗ Worker test failed: %s\n', ME.message);
    end
end

function result = testFunction(data)
    result = sum(data(:));
end
```

**Solutions:**

```matlab
% Solution 1: Reduce worker count
config.parallel.numWorkers = 2;

% Solution 2: Add error handling to parallel sections
parfor i = 1:nPop
    try
        newCost = CostFunction(newPos);
    catch ME
        newCost = Inf;  % Handle failures gracefully
        warning('Cost function failed for solution %d: %s', i, ME.message);
    end
end

% Solution 3: Increase worker memory
% MATLAB Preferences > Parallel Computing > Local cluster
% Set Memory per Worker to higher value
```

### Issue 3: Poor Parallel Performance

**Symptoms:**
- Parallel execution slower than serial
- High CPU usage but slow progress

**Performance Analysis:**

```matlab
function analyzeParallelPerformance()
    nTests = 100;
    
    % Serial timing
    tic;
    for i = 1:nTests
        result_serial(i) = testFunction(rand(100, 4));
    end
    serial_time = toc;
    
    % Parallel timing
    tic;
    parfor i = 1:nTests
        result_parallel(i) = testFunction(rand(100, 4));
    end
    parallel_time = toc;
    
    speedup = serial_time / parallel_time;
    fprintf('Serial time: %.3f seconds\n', serial_time);
    fprintf('Parallel time: %.3f seconds\n', parallel_time);
    fprintf('Speedup: %.2fx\n', speedup);
    
    if speedup < 1.5
        fprintf('⚠ Poor parallel performance detected\n');
        fprintf('Consider:\n');
        fprintf('  - Reducing worker count\n');
        fprintf('  - Increasing problem size\n');
        fprintf('  - Disabling parallel processing\n');
    end
end
```

## Memory and Performance Problems

### Issue 1: Out of Memory Errors

**Error Messages:**
- `Out of memory`
- `Requested array exceeds maximum array size`

**Solutions:**

```matlab
% Solution 1: Reduce memory usage
config = abcConfig();
config.algorithm.nPop = 30;                    % Smaller population
config.memory.maxMemoryMB = 2048;              % Lower memory limit
config.memory.checkpointInterval = 1;          % Frequent checkpoints
config.visualization.realTime = false;         % Disable real-time plots

% Solution 2: Implement memory monitoring
function memoryUsage = monitorMemory()
    if ispc
        [~, memInfo] = memory;
        memoryUsage = (memInfo.PhysicalMemory.Total - memInfo.PhysicalMemory.Available) / 1024^3;
    else
        memoryUsage = NaN;  % Unix memory monitoring more complex
    end
end

% Solution 3: Optimize data storage
% Use single precision instead of double where possible
BestCost = single(zeros(MaxIt, 1));
ParamHistory = single(zeros(MaxIt, nVar));

% Clear unnecessary variables
clearvars tempVar1 tempVar2 intermediateResult;

% Force garbage collection
pack;
```

### Issue 2: Slow Performance

**Symptoms:**
- Each iteration takes very long
- Progress bar moves slowly

**Performance Optimization:**

```matlab
% Optimization 1: Profile the code
profile on;
enhanced_abc_parallel();
profile off;
profile viewer;  % Analyze bottlenecks

% Optimization 2: Optimize objective function
function optimizedObjectiveFunction(params)
    persistent simulationData;  % Cache expensive computations
    
    if isempty(simulationData)
        simulationData = loadSimulationModel();  % Load once
    end
    
    % Vectorized operations where possible
    cost = vectorizedCostCalculation(params, simulationData);
end

% Optimization 3: Reduce I/O operations
config.memory.checkpointInterval = 20;  % Less frequent saves
config.visualization.updateInterval = 10;  % Less frequent updates
config.statistics.exportInterval = 50;  % Less frequent exports
```

## File I/O and Checkpoint Issues

### Issue 1: Cannot Save Checkpoints

**Error Messages:**
- `Permission denied`
- `No such file or directory`

**Solutions:**

```matlab
% Solution 1: Check and create directories
baseDir = 'ABC_Results';
checkpointDir = fullfile(baseDir, 'Checkpoints');

if ~exist(baseDir, 'dir')
    [success, msg] = mkdir(baseDir);
    if ~success
        error('Cannot create base directory: %s', msg);
    end
end

if ~exist(checkpointDir, 'dir')
    [success, msg] = mkdir(checkpointDir);
    if ~success
        error('Cannot create checkpoint directory: %s', msg);
    end
end

% Solution 2: Use temporary directory
config.files.baseDir = tempdir();  % Always writable

% Solution 3: Check disk space
if ispc
    [status, result] = system('dir /-c');
else
    [status, result] = system('df -h .');
end
fprintf('Disk space info:\n%s\n', result);
```

### Issue 2: Checkpoint Loading Fails

**Error Messages:**
- `File contains no objects`
- `Corrupt checkpoint file`

**Solutions:**

```matlab
% Solution 1: Verify checkpoint before loading
function data = safeLoadCheckpoint(filename)
    if ~exist(filename, 'file')
        error('Checkpoint file does not exist: %s', filename);
    end
    
    % Check file size
    fileInfo = dir(filename);
    if fileInfo.bytes == 0
        error('Checkpoint file is empty: %s', filename);
    end
    
    try
        data = load(filename);
    catch ME
        warning('Failed to load checkpoint %s: %s', filename, ME.message);
        data = [];
    end
end

% Solution 2: Implement backup checkpoints
function saveCheckpointWithBackup(data, filename)
    backupFile = [filename, '.backup'];
    
    try
        save(filename, '-struct', 'data', '-v7.3');
        if exist(backupFile, 'file')
            delete(backupFile);  % Remove old backup
        end
    catch ME
        warning('Failed to save checkpoint, trying backup: %s', ME.message);
        save(backupFile, '-struct', 'data', '-v7.3');
    end
end
```

## Visualization Problems

### Issue 1: Figures Don't Appear

**Symptoms:**
- Real-time visualization enabled but no plots shown
- Figures appear but don't update

**Solutions:**

```matlab
% Solution 1: Force figure visibility
config.visualization.realTime = true;
set(0, 'DefaultFigureVisible', 'on');

% Solution 2: Manual figure management
if config.visualization.realTime
    figHandle = figure('Name', 'ABC Optimization', 'Position', [100, 100, 1000, 600]);
    
    % Ensure figure stays on top and visible
    set(figHandle, 'Visible', 'on');
    drawnow;
end

% Solution 3: Check display settings
fprintf('Display information:\n');
get(0, 'ScreenSize')
get(0, 'DefaultFigureVisible')
```

### Issue 2: Plot Updates Are Slow

**Symptoms:**
- Visualization causes significant slowdown
- MATLAB becomes unresponsive during plotting

**Solutions:**

```matlab
% Solution 1: Reduce update frequency
config.visualization.updateInterval = 10;  % Update every 10 iterations

% Solution 2: Optimize plotting code
function optimizedPlotUpdate(data, iteration)
    persistent figHandle axHandle lineHandle;
    
    if isempty(figHandle) || ~isvalid(figHandle)
        figHandle = figure();
        axHandle = axes(figHandle);
        lineHandle = plot(axHandle, data.BestCost, 'b-');
    else
        % Update data without recreating plot
        set(lineHandle, 'YData', data.BestCost(1:iteration));
        set(axHandle, 'XLim', [1, iteration]);
    end
    
    drawnow limitrate;  % Limit drawing rate
end

% Solution 3: Disable real-time plotting for long runs
if config.algorithm.MaxIt > 100
    config.visualization.realTime = false;
    fprintf('Real-time visualization disabled for long run\n');
end
```

## Convergence and Solution Quality Issues

### Issue 1: Poor Convergence

**Symptoms:**
- Best cost doesn't improve significantly
- Algorithm gets stuck in local optima

**Analysis Tools:**

```matlab
function analyzeConvergence(BestCost)
    % Plot convergence
    figure;
    semilogy(BestCost);
    title('Convergence Analysis');
    xlabel('Iteration');
    ylabel('Best Cost (log scale)');
    
    % Calculate improvement rate
    if length(BestCost) > 10
        recent_improvement = abs(BestCost(end) - BestCost(end-10)) / BestCost(end-10);
        fprintf('Recent improvement: %.2f%%\n', recent_improvement * 100);
        
        if recent_improvement < 0.01
            fprintf('⚠ Poor convergence detected\n');
        end
    end
    
    % Detect stagnation
    stagnation_threshold = 20;
    min_improvement = 1e-6;
    
    stagnant_count = 0;
    for i = 2:length(BestCost)
        if abs(BestCost(i) - BestCost(i-1)) < min_improvement
            stagnant_count = stagnant_count + 1;
        else
            stagnant_count = 0;
        end
        
        if stagnant_count >= stagnation_threshold
            fprintf('⚠ Stagnation detected at iteration %d\n', i);
            break;
        end
    end
end
```

**Improvement Strategies:**

```matlab
% Strategy 1: Increase exploration
config.algorithm.nPop = 150;              % Larger population
config.algorithm.L = 50;                  % Earlier abandonment
config.algorithm.a = 2.5;                 % Larger step size
config.algorithm.nOnlooker = round(0.3 * config.algorithm.nPop);  % Less exploitation

% Strategy 2: Adaptive parameters
function a = adaptiveAcceleration(iter, maxIter)
    a_max = 2.5;
    a_min = 0.5;
    a = a_max - (a_max - a_min) * iter / maxIter;  % Decrease over time
end

% Strategy 3: Multiple restarts
function bestResult = multipleRestarts(numRestarts)
    bestCost = Inf;
    bestResult = [];
    
    for restart = 1:numRestarts
        fprintf('Restart %d/%d\n', restart, numRestarts);
        result = enhanced_abc_parallel();
        
        if result.BestSol.Cost < bestCost
            bestCost = result.BestSol.Cost;
            bestResult = result;
        end
    end
end
```

### Issue 2: Invalid Solutions

**Symptoms:**
- Parameters outside specified bounds
- Objective function returns NaN or Inf

**Validation and Fixes:**

```matlab
function validatedParams = validateParameters(params, lb, ub)
    % Check bounds
    validatedParams = max(min(params, ub), lb);
    
    % Check for NaN/Inf values
    if any(isnan(validatedParams) | isinf(validatedParams))
        warning('Invalid parameters detected, using random values');
        validatedParams = lb + rand(size(lb)) .* (ub - lb);
    end
end

function cost = robustObjectiveFunction(params)
    try
        cost = originalObjectiveFunction(params);
        
        % Validate output
        if isnan(cost) || isinf(cost) || ~isreal(cost)
            warning('Invalid cost function output, assigning penalty');
            cost = 1e10;  % Large penalty value
        end
    catch ME
        warning('Objective function error: %s', ME.message);
        cost = 1e10;  % Penalty for failed evaluation
    end
end
```

## Error Messages and Solutions

### Common Error Messages

#### Error 1: `Index exceeds matrix dimensions`

**Cause:** Array indexing beyond allocated size

**Solution:**
```matlab
% Pre-allocate arrays with correct size
BestCost = zeros(MaxIt, 1);
ParamHistory = zeros(MaxIt, nVar);

% Check bounds before indexing
if iteration <= length(BestCost)
    BestCost(iteration) = currentBest;
end
```

#### Error 2: `Function handle is invalid`

**Cause:** Objective function not properly defined

**Solution:**
```matlab
% Test function handle
[lb, ub, dim, fobj] = Get_Functions_details('F1');
if isa(fobj, 'function_handle')
    fprintf('✓ Function handle is valid\n');
    
    % Test with sample input
    sample_input = (lb + ub) / 2;
    try
        test_output = fobj(sample_input);
        fprintf('✓ Function evaluation successful: %f\n', test_output);
    catch ME
        fprintf('✗ Function evaluation failed: %s\n', ME.message);
    end
else
    fprintf('✗ Invalid function handle\n');
end
```

#### Error 3: `Conversion to double from cell is not possible`

**Cause:** Data type mismatch in array operations

**Solution:**
```matlab
% Convert cell arrays to numeric if needed
if iscell(data)
    data = cell2mat(data);
end

% Ensure consistent data types
BestCost = double(BestCost);
ParamHistory = double(ParamHistory);
```

## System-Specific Issues

### Windows-Specific Issues

#### Issue: Long Path Names
**Error:** `Filename too long`

**Solution:**
```matlab
% Use shorter path names
config.files.baseDir = 'C:\ABC';

% Or use Windows long path support
config.files.baseDir = ['\\?\', 'C:\very\long\path\to\results'];
```

#### Issue: Antivirus Interference
**Symptoms:** Random file access errors

**Solution:**
- Add MATLAB and project directory to antivirus exclusions
- Use Windows Defender exclusions for development

### macOS-Specific Issues

#### Issue: Permission Errors
**Error:** `Permission denied`

**Solution:**
```bash
# Grant MATLAB file access permissions
sudo chmod -R 755 /path/to/project/

# Or use user directory
config.files.baseDir = fullfile(getenv('HOME'), 'ABC_Results');
```

### Linux-Specific Issues

#### Issue: Display Problems
**Error:** `No display specified`

**Solution:**
```bash
# For remote sessions
export DISPLAY=:0.0

# Or use virtual display
Xvfb :99 -screen 0 1024x768x24 &
export DISPLAY=:99
```

## Performance Optimization

### Optimization Checklist

1. **Algorithm Parameters:**
   - [ ] Population size appropriate for problem complexity
   - [ ] Iteration count sufficient for convergence
   - [ ] Abandonment limit balanced for exploration/exploitation

2. **System Resources:**
   - [ ] Sufficient RAM available (>4GB recommended)
   - [ ] SSD storage for checkpoints if available
   - [ ] Parallel processing enabled if beneficial

3. **Configuration:**
   - [ ] Unnecessary features disabled
   - [ ] Checkpoint interval optimized
   - [ ] Visualization settings appropriate

### Performance Testing Script

```matlab
function performanceReport = generatePerformanceReport()
    fprintf('=== ABC PERFORMANCE ANALYSIS ===\n');
    
    % Test different configurations
    configs = {
        struct('name', 'Small', 'MaxIt', 20, 'nPop', 20),
        struct('name', 'Medium', 'MaxIt', 50, 'nPop', 50),
        struct('name', 'Large', 'MaxIt', 100, 'nPop', 100)
    };
    
    performanceReport = [];
    
    for i = 1:length(configs)
        cfg = configs{i};
        fprintf('\nTesting %s configuration...\n', cfg.name);
        
        % Measure performance
        tic;
        % Run abbreviated optimization test
        testResults = runOptimizationTest(cfg);
        elapsed = toc;
        
        % Store results
        performanceReport.(cfg.name) = struct(...
            'executionTime', elapsed, ...
            'iterationsPerSecond', cfg.MaxIt / elapsed, ...
            'finalCost', testResults.finalCost ...
        );
        
        fprintf('  Time: %.2f seconds\n', elapsed);
        fprintf('  Speed: %.2f iterations/second\n', cfg.MaxIt / elapsed);
    end
    
    % Generate recommendations
    fprintf('\n=== PERFORMANCE RECOMMENDATIONS ===\n');
    generatePerformanceRecommendations(performanceReport);
end
```

## Getting Additional Help

### Debug Mode

```matlab
% Enable comprehensive debugging
dbstop if error;
dbstop if warning;

% Set breakpoints at key locations
dbstop in enhanced_abc_parallel at 150;  % Main loop
dbstop in checkpointManager>save at 35;  % Checkpoint saving

% Run with debugging enabled
enhanced_abc_parallel();

% Disable debugging when done
dbclear all;
```

### Logging System

```matlab
function setupLogging(logLevel)
    % logLevel: 'INFO', 'WARNING', 'ERROR', 'DEBUG'
    global ABC_LOG_LEVEL ABC_LOG_FILE;
    
    ABC_LOG_LEVEL = upper(logLevel);
    ABC_LOG_FILE = sprintf('ABC_debug_%s.log', datestr(now, 'yyyy_mm_dd_HHMMSS'));
    
    logMessage('INFO', 'Logging system initialized');
end

function logMessage(level, message)
    global ABC_LOG_LEVEL ABC_LOG_FILE;
    
    levels = {'ERROR', 'WARNING', 'INFO', 'DEBUG'};
    current_level = find(strcmp(levels, ABC_LOG_LEVEL), 1);
    message_level = find(strcmp(levels, level), 1);
    
    if message_level <= current_level
        timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
        log_entry = sprintf('[%s] %s: %s\n', timestamp, level, message);
        
        % Display and save
        fprintf(log_entry);
        
        fid = fopen(ABC_LOG_FILE, 'a');
        if fid > 0
            fprintf(fid, log_entry);
            fclose(fid);
        end
    end
end
```

### Support Information

When reporting issues, please include:

1. **System Information:**
   ```matlab
   version('-release')    % MATLAB version
   computer              % System architecture
   feature('numcores')   % Number of CPU cores
   memory                % Memory information
   ```

2. **Configuration Used:**
   ```matlab
   config = abcConfig();
   % Include any modifications made
   ```

3. **Error Messages:**
   - Complete error message
   - Stack trace if available
   - When the error occurred

4. **Steps to Reproduce:**
   - Minimal working example
   - Data files if needed
   - Specific parameter values

5. **Expected vs. Actual Behavior:**
   - What should happen
   - What actually happens
   - Any partial results obtained

### Contact Information

- **Project Repository:** GitHub issues page
- **Email:** For private support requests
- **Documentation:** Refer to README.md and other guide files

---

This troubleshooting guide covers the most common issues encountered with the ABC optimization system. For additional help, please consult the other documentation files or contact support with detailed information about your specific issue.

**Last Updated:** December 2024  
**Version:** 1.0.0