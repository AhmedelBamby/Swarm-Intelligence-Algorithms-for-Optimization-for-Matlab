function tracker = progressTracker(maxIter, displayInterval)
    % Real-time progress tracking with ETA calculation
    tracker.maxIter = maxIter;
    tracker.displayInterval = displayInterval;
    tracker.startTime = tic;
    tracker.lastUpdate = 0;
    
    tracker.update = @(currentIter, bestCost, meanCost) updateProgress(tracker, currentIter, bestCost, meanCost);
end

function updateProgress(tracker, currentIter, bestCost, meanCost)
    if mod(currentIter, tracker.displayInterval) == 0 || currentIter == 1
        elapsed = toc(tracker.startTime);
        progress = currentIter / tracker.maxIter;
        eta = elapsed / progress * (1 - progress);
        
        fprintf('[%s] Iter %d/%d (%.1f%%) | Best: %.6e | Mean: %.6e | ETA: %.1fs\n', ...
            datestr(now, 'HH:MM:SS'), currentIter, tracker.maxIter, progress*100, ...
            bestCost, meanCost, eta);
    end
end
