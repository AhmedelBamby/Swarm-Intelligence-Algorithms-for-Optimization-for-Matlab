function record_experiment_history(k1, k2, k3, k4, current_error, voltage_error, total_error, iterations)
% RECORD_EXPERIMENT_HISTORY Creates organized experiment records with timestamps
% 
% Inputs:
%   k1, k2, k3, k4 - Optimized parameters
%   current_error - Current control error metric
%   voltage_error - Voltage control error metric
%   total_error - Combined error metric
%   iterations - Number of iterations performed
%
% Outputs:
%   Creates folder structure and Excel file with experiment data

    % 1. Create main History folder if it doesn't exist
    main_folder = 'Optimization_History';
    if ~exist(main_folder, 'dir')
        mkdir(main_folder);
    end
    
    % 2. Create date-stamped subfolder (YYYY-MM-DD format)
    date_str = datestr(now, 'yyyy-mm-dd');
    subfolder = fullfile(main_folder, date_str);
    if ~exist(subfolder, 'dir')
        mkdir(subfolder);
    end
    
    % 3. Create unique timestamp for this experiment (including time)
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    filename = sprintf('Experiment_%s.xlsx', timestamp);
    filepath = fullfile(subfolder, filename);
    
    % 4. Prepare data for Excel recording
    headers = {'Parameter', 'Value', 'Metric', 'Value'};
    data = {
        'K1 (Current Proportional)', k1, 'Current Error', current_error;
        'K2 (Current Integral)', k2, 'Voltage Error', voltage_error;
        'K3 (Voltage Proportional)', k3, 'Total Error', total_error;
        'K4 (Voltage Integral)', k4, 'Iterations', iterations;
        'Timestamp', timestamp, 'Optimizer', 'Grey Wolf';
        'Optimized By', 'Eng. Ahmed ElBamby', 'College', 'AAST - AI Robotics'
    };
    
    % 5. Write to Excel with formatted cells
    try
        writecell(headers, filepath, 'Sheet', 'Results', 'Range', 'A1:B1');
        writecell(data, filepath, 'Sheet', 'Results', 'Range', 'A2');
        
        % Add some basic formatting
        excel = actxserver('Excel.Application');
        workbook = excel.Workbooks.Open(fullfile(pwd, filepath));
        sheet = workbook.Sheets.Item('Results');
        
        % Format headers
        sheet.Range('A1:B1').Interior.Color = hex2dec('CCE5FF');  % Light blue
        sheet.Range('A1:B1').Font.Bold = true;
        
        % Format parameters section
        sheet.Range(sprintf('A2:A%d', size(data,1)+1)).Interior.Color = hex2dec('E6E6E6');  % Light gray
        sheet.Range(sprintf('C2:C%d', size(data,1)+1)).Interior.Color = hex2dec('E6E6E6');
        
        % Autofit columns
        sheet.Columns.Item('A:D').EntireColumn.AutoFit;
        
        % Save and close
        workbook.Save();
        workbook.Close();
        excel.Quit();
        
        fprintf('Successfully recorded experiment to:\n%s\n', filepath);
    catch e
        fprintf('Error saving Excel file: %s\n', e.message);
    end
    
    % 6. Create a summary text file in the date folder
    summary_file = fullfile(subfolder, 'README.txt');
    if ~exist(summary_file, 'file')
        fid = fopen(summary_file, 'w');
        fprintf(fid, 'AAST - AI Robotics\n');
        fprintf(fid, 'SC-PI Controller Optimization Experiments\n');
        fprintf(fid, 'Conducted by: Eng. Ahmed ElBamby\n');
        fprintf(fid, 'Contact: ahmedelbamby1102003@gmail.com\n\n');
        fprintf(fid, 'This folder contains optimization experiments conducted on %s\n', date_str);
        fprintf(fid, 'Each Excel file contains parameters and performance metrics for one experiment.\n');
        fclose(fid);
    end
end