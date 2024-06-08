% Step 1: Load the data from a CSV file
filename = 'DOW30_Returns.csv'; % Replace with your actual file name
data = readtable(filename);

% Step 2: Handle NaN values by removing rows with any NaNs
data = rmmissing(data);

% Step 3: Extract the numerical data (assuming the first column is datetime)
numerical_data = data{:, 2:end};

% Step 4: Perform PCA
[coeff, score, ~, ~, explained] = pca(numerical_data);

% Step 5: Extract the principal components
% The 'score' variable contains the principal components
principal_components = score;

% Step 6: Compute autocorrelations of the principal components
num_lags = 12;
num_components = size(principal_components, 2); % Number of principal components
autocorrs = zeros(num_components, num_lags+1); % Initialize matrix to hold autocorrelations

for i = 1:num_components
    autocorrs(i, :) = autocorr(principal_components(:, i), num_lags);
end

% Create a table with the autocorrelations
lags = 0:num_lags;
component_names = strcat('Component_', string(1:num_components)');
autocorr_table = array2table(autocorrs, 'VariableNames', strcat('Lag_', string(lags)), 'RowNames', component_names);

% Save the table to a CSV file
output_filename = 'PCA_AutoCorr.csv';
writetable(autocorr_table, output_filename, 'WriteRowNames', true);

disp(['Autocorrelations saved to ', output_filename]);
