%% ====================== Setup ======================
clc;
clear;
close all;

% Model name
modelName = 'sc_pi'; % Make sure your model is ready

% Load model
load_system(modelName);

%% ====================== Sampling Controller Gains ======================
numSamples = 1000;   % Increased for better visualization

% Define sampling ranges for k1, k2, k3, k4
k1_range = [0,6000];
k2_range = [0, 6000];
k3_range = [0, 6000];
k4_range = [0, 6000];

% Random samples (using uniform distribution)
k1_samples = k1_range(1) + (k1_range(2)-k1_range(1)) * rand(numSamples,1);
k2_samples = k2_range(1) + (k2_range(2)-k2_range(1)) * rand(numSamples,1);
k3_samples = k3_range(1) + (k3_range(2)-k3_range(1)) * rand(numSamples,1);
k4_samples = k4_range(1) + (k4_range(2)-k4_range(1)) * rand(numSamples,1);

data = [k1_samples, k2_samples, k3_samples, k4_samples];

% Prepare to collect cost
cost = zeros(numSamples,1);

%% ====================== Parallel Simulation ======================
parfor i = 1:numSamples
    modelNameLocal = 'sc_pi';
    load_system(modelNameLocal);
    
    modelWorkspace = get_param(modelNameLocal, 'ModelWorkspace');
    assignin(modelWorkspace, 'k1', data(i,1));
    assignin(modelWorkspace, 'k2', data(i,2));
    assignin(modelWorkspace, 'k3', data(i,3));
    assignin(modelWorkspace, 'k4', data(i,4));
    
    simOut = sim(modelNameLocal, 'SaveOutput', 'on', 'ReturnWorkspaceOutputs', 'on');
    
    dF1 = simOut.get('dF1');
    dF2 = simOut.get('dF2');
    cost(i) = norm(dF1) + norm(dF2);
end

%% ====================== Dimensionality Reduction ======================
[coeff, score, latent] = pca(data);
x = score(:,1); % PC1
y = score(:,2); % PC2
z = cost;

%% ====================== Visualization 1: 3D Scatter Plot ======================
figure('Name','3D Cost Landscape','Position',[100 100 800 600]);
scatter3(x, y, z, 40, z, 'filled');
xlabel('Principal Component 1');
ylabel('Principal Component 2');
zlabel('Total Cost');
title('3D Cost Scatter Plot');
colormap(jet);
colorbar;
grid on;
view(135, 30);

%% ====================== Visualization 2: Surface + Contour ======================
% Create interpolation grid
xi = linspace(min(x), max(x), 50);
yi = linspace(min(y), max(y), 50);
[XI, YI] = meshgrid(xi, yi);
ZI = griddata(x, y, z, XI, YI, 'v4'); % v4 method for smooth interpolation

figure('Name','Surface Plot','Position',[100 100 800 600]);
surfc(XI, YI, ZI); % Surface with contours
shading interp;
xlabel('PC1');
ylabel('PC2');
zlabel('Cost');
title('Cost Surface with Contours');
colormap(jet);
colorbar;
view(135, 30);

%% ====================== Visualization 3: 3D Contour Lines ======================
figure('Name','3D Contour','Position',[100 100 800 600]);
contour3(XI, YI, ZI, 15, 'LineWidth', 1.5);
hold on;
scatter3(x, y, z, 30, 'r', 'filled'); % Original points
xlabel('PC1');
ylabel('PC2');
zlabel('Cost');
title('3D Contour Lines with Samples');
colormap(jet);
colorbar;
grid on;
view(135, 30);

%% ====================== Visualization 4: 2D Contour Heatmap ======================
figure('Name','2D Heatmap','Position',[100 100 800 600]);
contourf(XI, YI, ZI, 15, 'LineWidth', 1.0);
hold on;
scatter(x, y, 30, z, 'filled');
xlabel('PC1');
ylabel('PC2');
title('2D Cost Contour Heatmap');
colormap(jet);
colorbar;
grid on;

%% ====================== Visualization 5: Combined View ======================
figure('Name','Combined View','Position',[100 100 1200 600]);

% Subplot 1: Surface
subplot(1,2,1);
surf(XI, YI, ZI, 'EdgeColor','none');
hold on;
scatter3(x, y, z, 30, 'r', 'filled');
title('Surface with Samples');
view(135,30);
colorbar;

% Subplot 2: Contour
subplot(1,2,2);
contourf(XI, YI, ZI, 15);
hold on;
scatter(x, y, 30, 'r', 'filled');
title('Top-Down Contour View');
colorbar;

colormap(jet);