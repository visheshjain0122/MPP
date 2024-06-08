% Load the autocorrelation data from the CSV file
autocorr_data = readtable('autocorrelations.csv', 'ReadRowNames', true);

% Convert the table to an array for easier manipulation
autocorr_array = table2array(autocorr_data);

% Calculate the sum of absolute autocorrelations for each component
sum_abs_autocorr = sum(abs(autocorr_array), 2);

% Find the index of the most auto-correlated component
[~, most_autocorrelated_idx] = max(sum_abs_autocorr);
most_autocorrelated_component = autocorr_data.Properties.RowNames{most_autocorrelated_idx};

% Calculate a combined metric for mean-reversion
% Metric: Negative first-lag autocorrelation and small absolute autocorrelation at the last lag
first_lag_autocorr = autocorr_array(:, 2); % Lag 1 is the second column
num_lags = size(autocorr_array, 2);
last_lag_autocorr = abs(autocorr_array(:, num_lags)); % Last lag autocorrelation

% Combined metric: negative first-lag autocorrelation + small last-lag autocorrelation
mean_reversion_metric = -first_lag_autocorr + (1 - last_lag_autocorr);

% Find the index of the component with the highest mean reversion metric
[~, most_mean_reverting_idx] = max(mean_reversion_metric);
most_mean_reverting_component = autocorr_data.Properties.RowNames{most_mean_reverting_idx};

% Display the results
disp(['The most auto-correlated principal component is: ', most_autocorrelated_component]);
disp(['The most mean-reverting principal component is: ', most_mean_reverting_component]);

% Display the autocorrelation values for these components
disp(['Autocorrelations of the most auto-correlated component:']);
disp(autocorr_array(most_autocorrelated_idx, :));

disp(['Autocorrelations of the most mean-reverting component:']);
disp(autocorr_array(most_mean_reverting_idx, :));
