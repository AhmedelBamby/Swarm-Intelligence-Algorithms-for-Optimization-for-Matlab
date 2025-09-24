% Load and check your model
modelName = 'sc_pi';
if ~bdIsLoaded(modelName)
    load_system(modelName);
end

% Verify model can run with sample parameters
k1 = 0.5; k2 = 100; k3 = 5; k4 = 300;
assignin('base', 'k1', k1);
assignin('base', 'k2', k2); 
assignin('base', 'k3', k3);
assignin('base', 'k4', k4);

% Test simulation
try
    sim(modelName);
    fprintf('Simulink model verified successfully\n');
catch ME
    error('Simulink model failed: %s', ME.message);
end
