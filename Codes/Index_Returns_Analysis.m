% Load the CSV file into a table
filename = 'Nifty_Fifty_Returns.csv';
dataTable = readtable(filename);

% Remove the first column (assuming the first column contains dates)
dataTable = removevars(dataTable, dataTable.Properties.VariableNames{1});

% Remove rows with NaN values
dataTable = rmmissing(dataTable);

% Extract data and column names (now without the first column)
data = table2array(dataTable);
columnNames = dataTable.Properties.VariableNames;

% Initialize variables for autocorrelation and cross-correlation tables
numColumns = size(data, 2);
numObservations = size(data, 1);
maxLags = 6; % Desired maximum number of lags for autocorrelation

% Storage for autocorrelation results
autocorrTable = cell(numColumns, maxLags + 1); % 1 column for names, remaining for autocorrelations

% Fill the headers for autocorrelation table
autocorrTable(:, 1) = columnNames';

% Standardize the data
data = zscore(data);

% Compute autocorrelations
for i = 1:numColumns
    % Get the valid number of lags for this column
    validLags = min(maxLags, numObservations - 1);
    
    % Debugging statement
    fprintf('Column %d (%s) has %d observations. Valid lags: %d\n', i, columnNames{i}, numObservations, validLags);
    
    % Initialize autocorrelation values for this column
    autocorrValues = nan(1, validLags);
    
    % Check if we have enough observations
    if validLags > 0
        % Autocorrelations using name-value syntax
        for lag = 1:validLags
            acf = autocorr(data(:, i), 'NumLags', lag);
            autocorrValues(lag) = acf(end); % Get the autocorrelation value for the specific lag
        end
    end
    
    % Store the autocorrelation values in the table
    autocorrTable(i, 2:(validLags + 1)) = num2cell(autocorrValues);
end

% Ensure proper variable names for autocorrTable
varNames = ['Column', strcat('Lag', arrayfun(@num2str, 1:maxLags, 'UniformOutput', false))];

% Convert autocorrTable to a MATLAB table and display
autocorrTable = cell2table(autocorrTable, 'VariableNames', varNames);
disp('Autocorrelation Table:');
disp(autocorrTable);

% Save autocorrelation table to CSV
writetable(autocorrTable, 'autocorrTable.csv');

% Initialize cross-correlation table
crosscorrTable = cell(numColumns + 1, numColumns + 1); % +1 for headers

% Fill the headers for cross-correlation table
crosscorrTable(1, 2:end) = columnNames;
crosscorrTable(2:end, 1) = columnNames;

% Compute cross-correlations
for i = 1:numColumns
    for j = 1:numColumns
        crosscorrTable{i + 1, j + 1} = xcorr(data(:, i), data(:, j), 0, 'coeff');
    end
end

% Convert crosscorrTable to a MATLAB table and display
crosscorrTable = cell2table(crosscorrTable(2:end, 2:end), 'VariableNames', crosscorrTable(1, 2:end), 'RowNames', crosscorrTable(2:end, 1));
disp('Cross-Correlation Table:');
disp(crosscorrTable);

% Save cross-correlation table to CSV
writetable(crosscorrTable, 'crosscorrTable.csv', 'WriteRowNames', true);

% Perform PCA
[coeff, score, latent, ~, explained] = pca(data);

% Display Eigenvalues, Proportion of Variance, and Cumulative Variance
eigenvalues = latent;
proportionVariance = explained;
cumulativeVariance = cumsum(explained);

pcaResults = table((1:length(eigenvalues))', eigenvalues, proportionVariance, cumulativeVariance, ...
    'VariableNames', {'Component', 'Eigenvalue', 'ProportionVariance', 'CumulativeVariance'});
disp('PCA Results:');
disp(pcaResults);

% Save PCA results to CSV
writetable(pcaResults, 'pcaResults.csv');

% Display the loadings to show how each stock index falls into each principal component
loadingsTable = array2table(coeff, 'VariableNames', strcat('PC', string(1:size(coeff, 2))));
loadingsTable.StockIndex = columnNames';  % Add the stock index names
disp('Loadings of each stock index on Principal Components:');
disp(loadingsTable);

% Save loadings table to CSV
writetable(loadingsTable, 'loadingsTable.csv');

% Compute cross-correlations of the principal components
numComponents = size(score, 2);
pcCrossCorrMatrix = zeros(numComponents);

for i = 1:numComponents
    for j = 1:numComponents
        pcCrossCorrMatrix(i, j) = xcorr(score(:, i), score(:, j), 0, 'coeff');
    end
end

% Convert pcCrossCorrMatrix to a MATLAB table and display
pcCrossCorrTable = array2table(pcCrossCorrMatrix, 'VariableNames', strcat('PC', string(1:numComponents)), 'RowNames', strcat('PC', string(1:numComponents)));
disp('Cross-Correlation Table of Principal Components:');
disp(pcCrossCorrTable);

% Save PCA cross-correlation table to CSV
writetable(pcCrossCorrTable, 'pcCrossCorrTable.csv', 'WriteRowNames', true);
