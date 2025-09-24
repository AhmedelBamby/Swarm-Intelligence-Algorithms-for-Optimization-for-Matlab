% Main optimization script for SC-PI controller tuning
clear all
close all
clc
% ======================================================================
% Display Professional Information
% ======================================================================
fprintf('\n');
fprintf('============================================================\n');
fprintf('                    OPTIMIZATION PROJECT                     \n');
fprintf('============================================================\n');
fprintf('Name: Eng. Ahmed ElBamby\n');
fprintf('College: AAST - Artificial Intelligence (Robotics)\n');
fprintf('Algorithm: Grey Wolf Optimization Algorithm\n');
fprintf('Work Email: ahmedelbamby1102003@gmail.com\n');
fprintf('Work Phone Number: +201096562363\n');
fprintf('============================================================\n\n');


% Load function details for F1 (your SC-PI controller problem)
[lb, ub, dim, fobj] = Get_Functions_details('F1');

% GWO parameters
SearchAgents_no = 20;  % Number of wolves
Max_iter = 500;         % Maximum iterations

% Run GWO optimization
[Alpha_score, Alpha_pos, Convergence_curve] = GWO(SearchAgents_no, Max_iter, lb, ub, dim, fobj);



% Display final results
fprintf('\n=== Optimization Results ===\n');
fprintf('Best Parameters Found:\n');
fprintf('  Kp_I: %.4f\n', Alpha_pos(1));
fprintf('  Ki_I: %.4f\n', Alpha_pos(2));
fprintf('  Kp_v: %.4f\n', Alpha_pos(3));
fprintf('  Ki_v: %.4f\n', Alpha_pos(4));
fprintf('Best Objective Value: %.4f\n', Alpha_score);


record_experiment_history(...
    Alpha_pos(1), Alpha_pos(2), Alpha_pos(3), Alpha_pos(4),...
    nerr1, nerr2, Alpha_score, Max_iter);



% Plot convergence curve
figure;
plot(Convergence_curve, 'LineWidth', 2);
title('GWO Convergence Curve');
xlabel('Iteration');
ylabel('Best Objective Value');
grid on;


% Apply best parameters to Simulink model and run final simulation
fprintf('\nRunning final simulation with optimized parameters...\n');
k1 = Alpha_pos(1);
k2 = Alpha_pos(2);
k3 = Alpha_pos(3);
k4 = Alpha_pos(4);

assignin('base', 'k1', k1);
assignin('base', 'k2', k2);
assignin('base', 'k3', k3);
assignin('base', 'k4', k4);

sim('sc_pi');