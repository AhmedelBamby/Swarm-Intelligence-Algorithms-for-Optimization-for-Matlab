%% ====================== Setup ======================
clc;
clear;
close all;

% Controller gains
k1 = 0.55;
k2 = 4;
k3 = 110.24;
k4 = 378.20;
 

% Model name
modelName = 'sc_pi';

%% ====================== Load and Assign ======================
% Load the Simulink model
load_system(modelName);

% Assign k1, k2, k3, k4 to model workspace
modelWorkspace = get_param(modelName, 'ModelWorkspace');
assignin(modelWorkspace, 'k1', k1);
assignin(modelWorkspace, 'k2', k2);
assignin(modelWorkspace, 'k3', k3);
assignin(modelWorkspace, 'k4', k4);

%% ====================== Simulate ======================
% Simulate the model
simOut = sim(modelName, 'SaveOutput', 'on', 'ReturnWorkspaceOutputs', 'on');

% Extract output signals
dF1 = simOut.get('dF1');   % Current error signal
dF2 = simOut.get('dF2');   % Voltage error signal

%% ====================== Calculate Errors ======================
% Calculate norms
currentError = norm(dF1);     % L2 norm of dF1
voltageError = norm(dF2);     % L2 norm of dF2
totalError = currentError + voltageError;

%% ====================== Display Results ======================
fprintf('\n=== Results ===\n');
fprintf('Current Error (||dF1||): %.6f\n', currentError);
fprintf('Voltage Error (||dF2||): %.6f\n', voltageError);
fprintf('Total Objective Error  : %.6f\n', totalError);

%% ====================== Clean Up ======================
% Close the model
close_system(modelName, 0);
