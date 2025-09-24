
% Clean parallel environment
try
    poolobj = gcp('nocreate');
    if ~isempty(poolobj)
        delete(poolobj)
    end
    parallel.internal.pool.safeCleanup()
catch ME
    warning(ME.identifier,'Parallel cleanup failed: %s', ME.message)
end
%% ====================== Setup ======================
clc;
clear;
close all;

% Model name
modelName = 'h'; % Make sure your model is ready

% Load model
load_system(modelName);

%% ====================== Sampling Controller Gains (LHS) ---> [Latin Hypercube Sampling] ======================
numSamples = 5;   % Number of LHS samples

% Define sampling ranges for k1, k2, k3, k4
ranges = [1,10]; % Same range for all parameters

% Generate LHS samples (more uniform coverage than random)
lhs_samples = lhsdesign(numSamples, 4, 'iterations', 5, 'criterion', 'maximin'); % 4 parameters
data = ranges(1) + (ranges(2)-ranges(1)) * lhs_samples;

% Optional: Visualize parameter distributions
figure;
plotmatrix(lhs_samples);
title('LHS Sample Distributions (Normalized)');

k1_samples = data(:,1);
k2_samples = data(:,2);
k3_samples = data(:,3);
k4_samples = data(:,4);

% Prepare to collect cost
cost = zeros(numSamples,1);

%% ====================== Parallel Simulation ======================
parfor i = 1:numSamples
    modelNameLocal = 'h';
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
figure('Name','3D Cost Landscape (LHS)','Position',[100 100 800 600]);
scatter3(x, y, z, 40, z, 'filled');
xlabel('Principal Component 1');
ylabel('Principal Component 2');
zlabel('Total Cost');
title('3D Cost Scatter Plot (LHS Sampling)');
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

figure('Name','Surface Plot (LHS)','Position',[100 100 800 600]);
surfc(XI, YI, ZI); % Surface with contours
shading interp;
xlabel('PC1');
ylabel('PC2');
zlabel('Cost');
title('Cost Surface with Contours (LHS)');
colormap(jet);
colorbar;
view(135, 30);

%% ====================== Visualization 3: 3D Contour Lines ======================
figure('Name','3D Contour (LHS)','Position',[100 100 800 600]);
contour3(XI, YI, ZI, 15, 'LineWidth', 1.5);
hold on;
scatter3(x, y, z, 30, 'r', 'filled'); % Original points
xlabel('PC1');
ylabel('PC2');
zlabel('Cost');
title('3D Contour Lines with LHS Samples');
colormap(jet);
colorbar;
grid on;
view(135, 30);

%% ====================== Visualization 4: 2D Contour Heatmap ======================
figure('Name','2D Heatmap (LHS)','Position',[100 100 800 600]);
contourf(XI, YI, ZI, 15, 'LineWidth', 1.0);
hold on;
scatter(x, y, 30, z, 'filled');
xlabel('PC1');
ylabel('PC2');
title('2D Cost Contour Heatmap (LHS)');
colormap(jet);
colorbar;
grid on;

%% ====================== Visualization 5: Combined View ======================
figure('Name','Combined View (LHS)','Position',[100 100 1200 600]);

% Subplot 1: Surface
subplot(1,2,1);
surf(XI, YI, ZI, 'EdgeColor','none');
hold on;
scatter3(x, y, z, 30, 'r', 'filled');
title('Surface with LHS Samples');
view(135,30);
colorbar;

% Subplot 2: Contour
subplot(1,2,2);
contourf(XI, YI, ZI, 15);
hold on;
scatter(x, y, 30, 'r', 'filled');
title('Top-Down Contour View (LHS)');
colorbar;

colormap(jet);