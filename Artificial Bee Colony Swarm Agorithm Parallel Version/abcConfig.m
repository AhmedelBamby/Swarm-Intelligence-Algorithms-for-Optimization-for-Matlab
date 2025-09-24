function config = abcConfig()
    % ABC Algorithm Configuration
    config.algorithm.MaxIt = 200;
    config.algorithm.nPop = 100;
    config.algorithm.nOnlooker = 50;
    config.algorithm.L = 120;
    config.algorithm.a = 1.5;
    
    % Memory Management
    config.memory.maxMemoryMB = 10240; % 2GB
    config.memory.checkpointInterval = 2;
    config.memory.cleanupInterval = 5;
    
    % Visualization
    config.visualization.updateInterval = 1;
    config.visualization.saveInterval = 10;
    config.visualization.realTime = true;
    
    % File Management
    config.files.baseDir = 'ABC_Optimization_Results';
    config.files.timestamp = datestr(now, 'yyyy_mm_dd_HHMMSS');
    
    % Parallel Processing
    config.parallel.enabled = true;
    config.parallel.numWorkers = feature('numcores');
    
    % Statistics
    config.statistics.detailed = true;
    config.statistics.exportInterval = 2;
end
