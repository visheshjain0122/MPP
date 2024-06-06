filename = 'Nifty_Fifty_Returns.csv';
data = readtable(filename);
stockNames = data.Properties.VariableNames(2:end); % Extract stock names

% Preallocate variables for storing p, d, q values
p_values = zeros(length(stockNames), 1);
d_values = zeros(length(stockNames), 1);
q_values = zeros(length(stockNames), 1);

% Define the range of p, d, q values to search
p_range = 0:3;
d_range = 0:2;
q_range = 0:3;

for i = 1:length(stockNames)
    fprintf("On iteration %d \n", i);
    stockReturns = data{:, stockNames{i}};
    bestAIC = Inf; % Initialize the best AIC as infinity

    % Grid search for the best p, d, q values
    for p = p_range
        for d = d_range
            for q = q_range
                try
                    model = arima(p, d, q); % Define the ARIMA model
                    estimatedModel = estimate(model, stockReturns, 'Display', 'off');
                    [~,~,logL] = infer(estimatedModel, stockReturns);
                    numParams = p + q + 1; % Number of parameters (p + q + constant)
                    AIC = -2 * logL + 2 * numParams; % Calculate AIC
                    
                    % Update the best model if current AIC is lower
                    if AIC < bestAIC
                        bestAIC = AIC;
                        p_values(i) = p;
                        d_values(i) = d;
                        q_values(i) = q;
                    end
                catch
                    % In case of estimation error, continue with the next combination
                    continue
                end
            end
        end
    end
end

% Create a table to store the results
resultsTable = table(stockNames', p_values, d_values, q_values, ...
                     'VariableNames', {'StockName', 'p', 'd', 'q'});

% Display the results table
disp(resultsTable);

writetable(resultsTable, 'ARIMA_pqd_Table.csv');