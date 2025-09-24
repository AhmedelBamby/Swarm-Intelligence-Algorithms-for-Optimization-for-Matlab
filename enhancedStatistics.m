function stats = enhancedStatistics(data, label)
%% ====================================================================
% ENHANCED STATISTICS CALCULATOR
% Provides comprehensive statistical analysis for optimization data
%% ====================================================================

if nargin < 2
    label = 'Data';
end

data = data(~isnan(data) & ~isinf(data)); % Clean data

if isempty(data)
    warning('No valid data points for analysis');
    stats = struct();
    return;
end

% Basic statistics
stats.label = label;
stats.count = length(data);
stats.mean = mean(data);
stats.median = median(data);
stats.mode = mode(data);
stats.std = std(data);
stats.variance = var(data);
stats.min = min(data);
stats.max = max(data);
stats.range = stats.max - stats.min;

% Percentiles
stats.percentiles.p25 = prctile(data, 25);
stats.percentiles.p75 = prctile(data, 75);
stats.percentiles.p90 = prctile(data, 90);
stats.percentiles.p95 = prctile(data, 95);
stats.percentiles.p99 = prctile(data, 99);

% Shape statistics
stats.skewness = skewness(data);
stats.kurtosis = kurtosis(data);

% Coefficient of variation
stats.cv = stats.std / abs(stats.mean);

% Interquartile range
stats.iqr = stats.percentiles.p75 - stats.percentiles.p25;

% Robust statistics
stats.mad = mad(data); % Median absolute deviation
stats.robust_mean = trimmean(data, 20); % 20% trimmed mean

% Outlier detection (using IQR method)
lower_bound = stats.percentiles.p25 - 1.5 * stats.iqr;
upper_bound = stats.percentiles.p75 + 1.5 * stats.iqr;
stats.outliers = data(data < lower_bound | data > upper_bound);
stats.outlier_count = length(stats.outliers);
stats.outlier_percentage = stats.outlier_count / stats.count * 100;

% Confidence intervals (95%)
sem = stats.std / sqrt(stats.count);
t_val = tinv(0.975, stats.count - 1);
stats.ci_95 = [stats.mean - t_val * sem, stats.mean + t_val * sem];

% Distribution fit assessment (normality tests)
if stats.count > 3
    try
        [stats.normality.h_jb, stats.normality.p_jb] = jbtest(data); % Jarque-Bera test
        [stats.normality.h_ks, stats.normality.p_ks] = kstest(zscore(data)); % Kolmogorov-Smirnov test
    catch
        stats.normality.h_jb = NaN;
        stats.normality.p_jb = NaN;
        stats.normality.h_ks = NaN;
        stats.normality.p_ks = NaN;
    end
end

% Time series properties (if applicable)
if length(data) > 1
    stats.trend.slope = polyfit(1:length(data), data, 1);
    stats.trend.correlation = corr((1:length(data))', data(:));
    
    % Autocorrelation at lag 1
    if length(data) > 2
        stats.autocorr_lag1 = corr(data(1:end-1), data(2:end));
    end
    
    % Volatility (moving standard deviation)
    windowSize = min(10, floor(length(data) / 4));
    if windowSize > 1
        movingStd = movstd(data, windowSize);
        stats.volatility.mean = mean(movingStd);
        stats.volatility.std = std(movingStd);
    end
end

fprintf('\n=== Enhanced Statistics for %s ===\n', label);
fprintf('Count: %d\n', stats.count);
fprintf('Mean: %.6f ± %.6f\n', stats.mean, stats.std);
fprintf('Median: %.6f\n', stats.median);
fprintf('Range: [%.6f, %.6f]\n', stats.min, stats.max);
fprintf('CV: %.4f\n', stats.cv);
fprintf('Outliers: %d (%.2f%%)\n', stats.outlier_count, stats.outlier_percentage);

if isfield(stats, 'trend')
    fprintf('Trend slope: %.6e\n', stats.trend.slope(1));
end

end
