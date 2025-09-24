%% ====================== Setup ======================
clc;
clear;
close all;

fprintf('=== Starting Setup ===\n');

% Model name
modelName = 'sc_pi';

% Load model
load_system(modelName);
fprintf('Loaded Simulink model: %s\n', modelName);

%% ====================== Sampling Controller Gains ======================
fprintf('=== Sampling Controller Gains ===\n');

numSamples = 5;   % Number of samples

% Define ranges
k1_range = [0.5, 2];
k2_range = [2, 6];
k3_range = [50, 60];
k4_range = [300, 350];

% Generate samples
k1_samples = linspace(k1_range(1), k1_range(2), numSamples)';
k2_samples = linspace(k2_range(1), k2_range(2), numSamples)';
k3_samples = linspace(k3_range(1), k3_range(2), numSamples)';
k4_samples = linspace(k4_range(1), k4_range(2), numSamples)';

% Combine samples
data = [k1_samples, k2_samples, k3_samples, k4_samples];

fprintf('Generated %d samples for each controller gain.\n', numSamples);

%% ====================== Prepare Parallel Simulations ======================
fprintf('=== Preparing Simulation Inputs ===\n');

simIn = repmat(Simulink.SimulationInput(modelName), numSamples, 1);

for i = 1:numSamples
    simIn(i) = setVariable(simIn(i), 'k1', data(i,1));
    simIn(i) = setVariable(simIn(i), 'k2', data(i,2));
    simIn(i) = setVariable(simIn(i), 'k3', data(i,3));
    simIn(i) = setVariable(simIn(i), 'k4', data(i,4));
end

%% ====================== Run Parallel Simulations ======================
fprintf('=== Running Parallel Simulations ===\n');

simOut = parsim(simIn, 'ShowProgress', 'on', 'TransferBaseWorkspaceVariables', 'on');

%% ====================== Extract Costs ======================
fprintf('=== Extracting Costs ===\n');

cost = zeros(numSamples,1);
valid_samples = false(numSamples,1);

for i = 1:numSamples
        % Access the simulation output
        current_output = simOut(i);
        fprintf('Processing sample %d\n', i);

        % Get the data directly from the output structure
        dF1_data = current_output.dF1;
        dF2_data = current_output.dF2;

        fprintf('Sample %d: dF1 size = %s, dF2 size = %s\n', ...
            i, mat2str(size(dF1_data)), mat2str(size(dF2_data)));

        % Calculate norms (using all columns if dF1 is 2D)
        currentError = norm(dF1_data(:)); % Flatten and take norm of all elements
        voltageError = norm(dF2_data(:));
        cost(i) = currentError + voltageError;
 end
valid_samples(i) = true;
% Filter valid samples
valid_indices = find(valid_samples);
if numel(valid_indices) < 2
    error('Only %d valid samples found. Need at least 2 for PCA.', numel(valid_indices));
end

data_valid = data(valid_indices,:);
cost_valid = cost(valid_indices);

%% ====================== Dimensionality Reduction (PCA) ======================
fprintf('=== Performing PCA ===\n');

[coeff, score, latent] = pca(data_valid);

% Use first two principal components
x = score(:,1);
if size(score,2) >= 2
    y = score(:,2);
else
    y = zeros(size(x));
end
z = cost_valid;

%% ====================== Plotting ======================
fprintf('=== Plotting Results ===\n');

figure;
scatter3(x, y, z, 40, z, 'filled');
xlabel('Principal Component 1');
ylabel('Principal Component 2');
zlabel('Total Objective Cost');
title('3D Cost Landscape after PCA Reduction');
colormap(jet);
colorbar;
grid on;
view(135, 30);

%% ====================== Clean Up ======================
fprintf('=== Cleaning Up ===\n');
close_system(modelName, 0);