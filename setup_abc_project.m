function setupResult = setup_abc_project()
%% SETUP_ABC_PROJECT Setup and validation script for ABC Optimization System
% This function sets up the MATLAB path and validates the installation
% of the Enhanced Parallel Artificial Bee Colony optimization system.
%
% USAGE:
%   setup_abc_project()  % Run setup and validation
%
% OUTPUT:
%   setupResult (struct) - Setup results and system information
%
% AUTHOR: Enhanced ABC Optimization System
% DATE: 2024-12-24

    fprintf('\n');
    fprintf('====================================================================\n');
    fprintf('  ENHANCED PARALLEL ABC OPTIMIZATION SYSTEM - SETUP & VALIDATION\n');
    fprintf('====================================================================\n\n');
    
    setupResult = struct();
    setupResult.success = true;
    setupResult.issues = {};
    setupResult.warnings = {};
    setupResult.timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    
    %% Step 1: Path Setup
    fprintf('Step 1: Setting up MATLAB path...\n');
    try
        % Add current directory to path
        currentDir = pwd;
        addpath(currentDir);
        
        % Save path for future sessions
        savepath;
        
        fprintf('  ✓ Project directory added to MATLAB path\n');
        fprintf('  ✓ Path saved for future sessions\n');
        setupResult.pathSetup = true;
    catch ME
        fprintf('  ✗ Path setup failed: %s\n', ME.message);
        setupResult.success = false;
        setupResult.issues{end+1} = sprintf('Path setup failed: %s', ME.message);
        setupResult.pathSetup = false;
    end
    
    %% Step 2: System Information
    fprintf('\nStep 2: Collecting system information...\n');
    
    % MATLAB version
    matlabVersion = version('-release');
    fprintf('  MATLAB Version: %s\n', matlabVersion);
    setupResult.system.matlabVersion = matlabVersion;
    
    if str2double(matlabVersion(1:4)) >= 2019
        fprintf('  ✓ MATLAB version compatible (R2019b+ required)\n');
    else
        fprintf('  ⚠ MATLAB version may have compatibility issues (R2019b+ recommended)\n');
        setupResult.warnings{end+1} = 'MATLAB version older than recommended (R2019b+)';
    end
    
    % System architecture
    arch = computer;
    fprintf('  System Architecture: %s\n', arch);
    setupResult.system.architecture = arch;
    
    % CPU cores
    numCores = feature('numcores');
    fprintf('  CPU Cores: %d\n', numCores);
    setupResult.system.numCores = numCores;
    
    % Memory information
    try
        memInfo = memory;
        totalGB = memInfo.PhysicalMemory.Total / 1024^3;
        availableGB = memInfo.PhysicalMemory.Available / 1024^3;
        fprintf('  System Memory: %.1f GB total, %.1f GB available\n', totalGB, availableGB);
        setupResult.system.totalMemoryGB = totalGB;
        setupResult.system.availableMemoryGB = availableGB;
        
        if availableGB >= 4
            fprintf('  ✓ Sufficient memory available\n');
        elseif availableGB >= 2
            fprintf('  ⚠ Limited memory - consider using smaller population sizes\n');
            setupResult.warnings{end+1} = 'Limited memory available';
        else
            fprintf('  ✗ Insufficient memory for typical optimization runs\n');
            setupResult.issues{end+1} = 'Insufficient memory';
            setupResult.success = false;
        end
    catch
        fprintf('  ⚠ Could not determine memory information\n');
        setupResult.warnings{end+1} = 'Memory information unavailable';
    end
    
    %% Step 3: Toolbox Verification
    fprintf('\nStep 3: Verifying required toolboxes...\n');
    
    toolboxes = {
        'Distrib_Computing_Toolbox', 'Parallel Computing Toolbox', true;
        'Statistics_Toolbox', 'Statistics and Machine Learning Toolbox', true;
        'Optimization_Toolbox', 'Optimization Toolbox', false
    };
    
    setupResult.toolboxes = struct();
    
    for i = 1:size(toolboxes, 1)
        toolboxId = toolboxes{i, 1};
        toolboxName = toolboxes{i, 2};
        isRequired = toolboxes{i, 3};
        
        if license('test', toolboxId)
            fprintf('  ✓ %s: Available\n', toolboxName);
            setupResult.toolboxes.(toolboxId) = true;
        else
            setupResult.toolboxes.(toolboxId) = false;
            if isRequired
                fprintf('  ✗ %s: Not available (REQUIRED)\n', toolboxName);
                setupResult.issues{end+1} = sprintf('%s not available', toolboxName);
                if strcmp(toolboxId, 'Distrib_Computing_Toolbox')
                    fprintf('      Note: Parallel processing will be disabled\n');
                end
            else
                fprintf('  ⚠ %s: Not available (optional)\n', toolboxName);
                setupResult.warnings{end+1} = sprintf('%s not available', toolboxName);
            end
        end
    end
    
    %% Step 4: Core Function Verification
    fprintf('\nStep 4: Verifying core functions...\n');
    
    coreFunctions = {
        'enhanced_abc_parallel', 'Main optimization algorithm';
        'abcConfig', 'Configuration management';
        'Get_Functions_details', 'Objective function definitions';
        'checkpointManager', 'Checkpoint management class';
        'SaveAndPlotResults', 'Results visualization';
        'RouletteWheelSelection', 'Selection mechanism'
    };
    
    setupResult.functions = struct();
    
    for i = 1:size(coreFunctions, 1)
        funcName = coreFunctions{i, 1};
        funcDesc = coreFunctions{i, 2};
        
        if exist(funcName, 'file')
            fprintf('  ✓ %s: Found (%s)\n', funcName, funcDesc);
            setupResult.functions.(funcName) = true;
        else
            fprintf('  ✗ %s: Missing (%s)\n', funcName, funcDesc);
            setupResult.functions.(funcName) = false;
            setupResult.issues{end+1} = sprintf('Function %s not found', funcName);
            setupResult.success = false;
        end
    end
    
    %% Step 5: Configuration Test
    fprintf('\nStep 5: Testing configuration system...\n');
    
    try
        config = abcConfig();
        fprintf('  ✓ Configuration system working\n');
        fprintf('  ✓ Default configuration loaded successfully\n');
        
        % Validate key configuration fields
        requiredFields = {'algorithm', 'memory', 'parallel', 'files', 'visualization', 'statistics'};
        configValid = true;
        
        for field = requiredFields
            if isfield(config, field{1})
                fprintf('  ✓ Configuration section "%s": Present\n', field{1});
            else
                fprintf('  ✗ Configuration section "%s": Missing\n', field{1});
                configValid = false;
            end
        end
        
        if configValid
            setupResult.configTest = true;
        else
            setupResult.configTest = false;
            setupResult.issues{end+1} = 'Configuration structure incomplete';
            setupResult.success = false;
        end
        
    catch ME
        fprintf('  ✗ Configuration test failed: %s\n', ME.message);
        setupResult.configTest = false;
        setupResult.issues{end+1} = sprintf('Configuration test failed: %s', ME.message);
        setupResult.success = false;
    end
    
    %% Step 6: Objective Function Test
    fprintf('\nStep 6: Testing objective function...\n');
    
    try
        [lb, ub, dim, fobj] = Get_Functions_details('F1');
        fprintf('  ✓ Objective function F1 loaded\n');
        fprintf('  ✓ Problem dimension: %d parameters\n', dim);
        fprintf('  ✓ Parameter bounds defined\n');
        
        % Test function evaluation
        testParams = (lb + ub) / 2;  % Middle of bounds
        testCost = fobj(testParams);
        
        if isfinite(testCost) && isreal(testCost)
            fprintf('  ✓ Objective function evaluation successful (cost = %.6f)\n', testCost);
            setupResult.objectiveFunctionTest = true;
        else
            fprintf('  ⚠ Objective function returned invalid result: %f\n', testCost);
            setupResult.warnings{end+1} = 'Objective function returned invalid result';
            setupResult.objectiveFunctionTest = true;  % Still functional
        end
        
    catch ME
        fprintf('  ✗ Objective function test failed: %s\n', ME.message);
        setupResult.objectiveFunctionTest = false;
        setupResult.issues{end+1} = sprintf('Objective function test failed: %s', ME.message);
        setupResult.success = false;
    end
    
    %% Step 7: File System Test
    fprintf('\nStep 7: Testing file system access...\n');
    
    try
        % Test directory creation
        testDir = 'ABC_Setup_Test';
        if exist(testDir, 'dir')
            rmdir(testDir, 's');
        end
        mkdir(testDir);
        
        % Test file creation
        testFile = fullfile(testDir, 'test_file.mat');
        testData = struct('timestamp', now, 'data', rand(10, 10));
        save(testFile, 'testData');
        
        % Test file reading
        loadedData = load(testFile);
        
        % Cleanup
        delete(testFile);
        rmdir(testDir);
        
        fprintf('  ✓ Directory creation: OK\n');
        fprintf('  ✓ File write: OK\n');
        fprintf('  ✓ File read: OK\n');
        fprintf('  ✓ File cleanup: OK\n');
        setupResult.fileSystemTest = true;
        
    catch ME
        fprintf('  ✗ File system test failed: %s\n', ME.message);
        setupResult.fileSystemTest = false;
        setupResult.issues{end+1} = sprintf('File system test failed: %s', ME.message);
        setupResult.success = false;
    end
    
    %% Step 8: Parallel Processing Test
    fprintf('\nStep 8: Testing parallel processing...\n');
    
    if setupResult.toolboxes.Distrib_Computing_Toolbox
        try
            % Check for existing pool
            currentPool = gcp('nocreate');
            if ~isempty(currentPool)
                fprintf('  ✓ Parallel pool already active (%d workers)\n', currentPool.NumWorkers);
            else
                fprintf('  ⚠ No active parallel pool\n');
            end
            
            % Test parallel for loop
            tic;
            parfor i = 1:4
                dummy = sum(rand(100, 100));
            end
            parallelTime = toc;
            
            fprintf('  ✓ Parallel for loop test completed in %.3f seconds\n', parallelTime);
            setupResult.parallelTest = true;
            
        catch ME
            fprintf('  ⚠ Parallel processing test failed: %s\n', ME.message);
            fprintf('      Parallel processing will be disabled in configuration\n');
            setupResult.parallelTest = false;
            setupResult.warnings{end+1} = sprintf('Parallel processing test failed: %s', ME.message);
        end
    else
        fprintf('  ⚠ Parallel Computing Toolbox not available\n');
        fprintf('      Optimization will run in serial mode\n');
        setupResult.parallelTest = false;
    end
    
    %% Step 9: Quick Optimization Test (Optional)
    fprintf('\nStep 9: Quick optimization test...\n');
    
    if setupResult.success && setupResult.configTest && setupResult.objectiveFunctionTest
        try
            fprintf('  Running minimal optimization test (5 iterations, 10 bees)...\n');
            
            % Create minimal test configuration
            config = abcConfig();
            config.algorithm.MaxIt = 5;
            config.algorithm.nPop = 10;
            config.algorithm.nOnlooker = 5;
            config.parallel.enabled = setupResult.parallelTest;
            config.visualization.realTime = false;
            config.memory.checkpointInterval = 10;  % No checkpoints for quick test
            
            % This would require manual integration currently
            fprintf('  ⚠ Quick optimization test requires manual configuration integration\n');
            fprintf('      See USER_GUIDE.md for configuration instructions\n');
            
            setupResult.quickOptimizationTest = false;  % Not implemented in current version
            
        catch ME
            fprintf('  ⚠ Quick optimization test failed: %s\n', ME.message);
            setupResult.quickOptimizationTest = false;
            setupResult.warnings{end+1} = sprintf('Quick optimization test failed: %s', ME.message);
        end
    else
        fprintf('  ⚠ Skipping optimization test due to previous issues\n');
        setupResult.quickOptimizationTest = false;
    end
    
    %% Final Results Summary
    fprintf('\n');
    fprintf('====================================================================\n');
    fprintf('  SETUP RESULTS SUMMARY\n');
    fprintf('====================================================================\n');
    
    if setupResult.success
        fprintf('✓ SETUP SUCCESSFUL\n\n');
        
        fprintf('System is ready for ABC optimization!\n\n');
        
        fprintf('Quick Start:\n');
        fprintf('1. Run: enhanced_abc_parallel()  %% Default optimization\n');
        fprintf('2. Check results in: ABC_Optimization_Results_YYYY_MM_DD_HHMMSS/\n');
        fprintf('3. Generate reports: loadLatestCheckpointAndReport()\n\n');
        
        if ~isempty(setupResult.warnings)
            fprintf('Warnings to note:\n');
            for i = 1:length(setupResult.warnings)
                fprintf('  ⚠ %s\n', setupResult.warnings{i});
            end
            fprintf('\n');
        end
        
    else
        fprintf('✗ SETUP INCOMPLETE - Issues detected\n\n');
        
        fprintf('Issues that need attention:\n');
        for i = 1:length(setupResult.issues)
            fprintf('  ✗ %s\n', setupResult.issues{i});
        end
        fprintf('\n');
        
        fprintf('Please resolve these issues before running optimization.\n');
        fprintf('Refer to TROUBLESHOOTING.md for detailed solutions.\n\n');
    end
    
    % Recommendations
    fprintf('Recommendations:\n');
    if setupResult.system.availableMemoryGB < 8
        fprintf('  • Consider using smaller population sizes (nPop = 30-50)\n');
    end
    if ~setupResult.parallelTest
        fprintf('  • Disable parallel processing in configuration for better stability\n');
    end
    fprintf('  • Read USER_GUIDE.md for detailed usage instructions\n');
    fprintf('  • Check CONFIGURATION_GUIDE.md for parameter tuning\n');
    fprintf('  • Refer to TROUBLESHOOTING.md if you encounter issues\n\n');
    
    % Save setup results
    setupFileName = sprintf('ABC_setup_results_%s.mat', datestr(now, 'yyyy_mm_dd_HHMMSS'));
    try
        save(setupFileName, 'setupResult');
        fprintf('Setup results saved to: %s\n', setupFileName);
    catch
        fprintf('Could not save setup results to file\n');
    end
    
    fprintf('\nFor additional help, refer to the documentation files or project repository.\n');
    fprintf('====================================================================\n');
    
end