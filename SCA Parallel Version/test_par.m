% Test the fixed parallel pool setup
parallel_opts = struct('UseParallel', true, 'NumWorkers', 4);
poolObj = setupParallelPool(parallel_opts);

% Verify it works
if poolObj.NumWorkers > 1
    fprintf('Parallel pool working correctly!\n');
    
    % Test parallel execution
    parfor i = 1:4
        fprintf('Worker %d: Hello from parallel execution\n', i);
    end
else
    fprintf('Running in serial mode\n');
end
