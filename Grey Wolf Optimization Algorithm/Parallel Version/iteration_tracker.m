function iteration_tracker(iteration, Positions, fitness, Alpha_pos, Alpha_score, current_err, voltage_err)
% ITERATION_TRACKER Records optimization progress with timestamped organization
%
% Inputs:
%   iteration - Current iteration number
%   Positions - Current wolf positions (parameters)
%   fitness   - Current fitness values (total error)
%   Alpha_pos - Best solution position
%   Alpha_score - Best solution fitness
%   current_err - Current control error for each wolf
%   voltage_err - Voltage control error for each wolf
%
% Outputs:
%   Creates organized folder structure with timestamped files

%% Initialize persistent history structure
    persistent history
    
    % Initialize data structure on first call
    if isempty(history)
        history = struct();
        history.iterations = [];
        history.all_positions = {};
        history.all_fitness = [];
        history.alpha_positions = [];
        history.alpha_scores = [];
        history.current_errors = [];
        history.voltage_errors = [];
    end
    
%% Store current iteration data
    history.iterations(end+1) = iteration;
    history.all_positions{end+1} = Positions;
    history.all_fitness(end+1,:) = fitness;
    history.alpha_positions(end+1,:) = Alpha_pos;
    history.alpha_scores(end+1) = Alpha_score;
    history.current_errors(end+1,:) = current_err;
    history.voltage_errors(end+1,:) = voltage_err;
    
%% Create organized folder structure
    % Main folder
    main_folder = 'Optimization History';
    if ~exist(main_folder, 'dir')
        mkdir(main_folder);
    end
    
    % Date-stamped subfolder (YYYY-MM-DD format)
    date_str = datestr(now, 'yyyy-mm-dd');
    subfolder = fullfile(main_folder, date_str);
    if ~exist(subfolder, 'dir')
        mkdir(subfolder);
    end
    
    % Unique timestamp for files (YYYY-MM-DD_HH-MM format)
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM');
    
%% Prepare and save Excel data
    % Prepare data array with all error metrics
    data = {};
    for i = 1:size(Positions,1)
        row = {iteration, i, Positions(i,1), Positions(i,2), Positions(i,3), Positions(i,4),...
               current_err(i), voltage_err(i), fitness(i)};
        if i == 1
            data = row;
        else
            data = [data; row];
        end
    end
    
    % Excel file with timestamp
    excel_filename = sprintf('Optimization_History_%s.xlsx', timestamp);
    excel_path = fullfile(subfolder, excel_filename);
    headers = {'Iteration', 'Wolf', 'Kp_I', 'Ki_I', 'Kp_v', 'Ki_v',...
               'Current_Error', 'Voltage_Error', 'Total_Error'};
    
    % Write headers if new file
    if ~exist(excel_path, 'file')
        writecell(headers, excel_path, 'Sheet', 'IterationData');
    end
    
    % Append data to Excel
    try
        [~,~,existing] = xlsread(excel_path);
        next_row = size(existing, 1) + 1;
        writecell(data, excel_path, 'Sheet', 'IterationData',...
                 'Range', sprintf('A%d', next_row));
    catch ME
        warning(ME.identifier,'Could not write to Excel: %s', ME.message);
    end
    
%% Save MATLAB data file
    mat_filename = sprintf('optimization_history_%s.mat', timestamp);
    mat_path = fullfile(subfolder, mat_filename);
    
    try
        save(mat_path, 'history');
    catch ME
        warning(ME.identifier,'Could not save MAT file: %s', ME.message);
    end
    
%% Display status update
    if mod(iteration,10) == 0  % Print every 10 iterations
        fprintf('Iteration %d data saved to:\n%s\n%s\n',...
                iteration, excel_path, mat_path);
    end
end