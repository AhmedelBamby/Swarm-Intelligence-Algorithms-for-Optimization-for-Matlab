function [lb, ub, dim, fobj] = Get_Functions_details(F)
% ======================================================================
% ENHANCED FUNCTION DETAILS WITH IMPROVED LOGGING
% Features:
%   - More detailed parameter descriptions
%   - Better formatted output
%   - Consistent with main SCA optimization code
% ======================================================================

fprintf('\n=== Loading function details for: %s ===\n', F);

switch F
    case 'F1'
        fobj = @F1;
        lb = [  0.2108   1.9801  -47.5692   57.1874];
        ub = [   700   700     700     700]; 
        dim = 4;
        
        % Display parameter information
        fprintf('Function loaded successfully:\n');
        fprintf('  Dimension: %d\n', dim);
        fprintf('  Parameter Bounds:\n');
        fprintf('    %-10s: [%.2f, %.2f]\n', 'Kp_I – Proportional gain for the current controller', lb(1), ub(1));
        fprintf('    %-10s: [%.2f, %.2f]\n', 'Ki_I – Integral gain for the current controller', lb(2), ub(2));
        fprintf('    %-10s: [%.2f, %.2f]\n', 'Kp_v – Proportional gain for the voltage controller', lb(3), ub(3));
        fprintf('    %-10s: [%.2f, %.2f]\n', 'Ki_v – Integral gain for the voltage controller', lb(4), ub(4));
        
    otherwise
        error('Unknown function specified: %s', F);
end

fprintf('Function details loading complete.\n');
end

function [o,nerr1,nerr2] = F1(x)
    % Suppress HMI warnings
    warning('off', 'Simulink:HMI:AssertionFailed');
    
    % Display parameter assignment
    fprintf('\n=== Evaluating F1 with parameters ===\n');
    fprintf('  k1: %.4f Kp_I\n', x(1));
    fprintf('  k2: %.4f Ki_I\n', x(2));
    fprintf('  k3: %.4f Kp_v\n', x(3));
    fprintf('  k4: %.4f Ki_v\n', x(4));

    % Assign parameters
    assignin('base', 'k1', x(1));
    assignin('base', 'k2', x(2));
    assignin('base', 'k3', x(3));
    assignin('base', 'k4', x(4));

    % Run simulation with timing
    fprintf('Starting simulation...\n');
    simStart = tic;
    [~,~] = evalc('sim(''h'')');  % Silent simulation
    simTime = toc(simStart);
    fprintf('Simulation completed in %.2f seconds\n', simTime);

    % Calculate errors
    nerr1 = norm(dF1);
    nerr2 = norm(dF2);
    o = nerr1 + nerr2;

    % Display results
    fprintf('Current error: %.4f\nVoltage error: %.4f\nTotal: %.4f\n\n',...
            nerr1, nerr2, o);
    
    % Restore warnings if needed
    warning('on', 'Simulink:HMI:AssertionFailed');
end
% Alternative objective function (commented out)
% o = trapz(T,T.*((dF1.^2)+(dF2.^2)));  % ITSE metric