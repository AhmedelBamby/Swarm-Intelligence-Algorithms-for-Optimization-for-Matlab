function logExperimentResultsExcel(k1, k2, k3, k4, currentError, voltageError, totalError, iterations, execTime)
    % =====================================================================
    % FUNCTION: logExperimentResultsExcel
    % PURPOSE:  Logs experiment results to a timestamped Excel file
    % INPUTS:
    %   All parameters to be logged (k1-k4, errors, iterations, time)
    % OUTPUTS:
    %   Creates/updates Excel file in 'Important Excels' folder
    % =====================================================================
    
    % Generate unique filename using YYYY_MM_DD_HHMMSS format
    timestamp = datetime('now', 'Format', 'yyyy_MM_dd_HHmmss');
    logFolder = 'Important Excels';
    
    % Ensure the folder exists
    if ~exist(logFolder, 'dir')
        mkdir(logFolder);
    end
    
    % Create full file path
    logFile = fullfile(logFolder, sprintf('Experiment_%s.xlsx', char(timestamp)));
    
    % Prepare data for logging
    timestampLog = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
    logRow = {
        char(timestampLog), ...  % DateTime
        k1, k2, k3, k4, ...     % Controller parameters
        currentError, ...        % Current control error
        voltageError, ...        % Voltage control error
        totalError, ...         % Combined error
        iterations, ...         % Optimization iterations
        execTime                % Execution time
    };
    
    % Column headers
    headers = {
        'DateTime', ...
        'Kp_I', 'Ki_I', 'Kp_V', 'Ki_V', ...
        'Current Error', 'Voltage Error', 'Total Error', ...
        'Iterations', 'Execution Time (s)'
    };
    
    % Write to Excel (creates new file each time)
    writecell([headers; logRow], logFile);
    
    fprintf('Results successfully logged to:\n%s\n', logFile);
end