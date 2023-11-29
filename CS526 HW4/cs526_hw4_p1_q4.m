clear; close all;

% Load the dataset
T = readtable(fullfile('C:\Users\Chen\OneDrive - Duke University\CS 526\HW 2\data','day.csv'));
y = T.cnt; % response data
X = [T.weathersit, T.temp, T.hum, T.windspeed]; % predictors

rng default; % For reproducibility

% Define the number of trees in the forest
numTrees = 100; % This can be adjusted based on computational resources

% Define the range for the number of variables to sample at each split
numVarsToSample = 1:size(X, 2); % Typically from 1 to the number of predictors

% Initialize variables to store results
optimalNumVars = NaN;
minCVTestMSE = inf;

% Perform 2-fold cross-validation to find the optimal number of variables to sample
for i = 1:length(numVarsToSample)
    cv = cvpartition(height(T),'KFold',2);
    cvMSE = zeros(cv.NumTestSets, 1);
    
    for fold = 1:cv.NumTestSets
        % Separate the training and test indices for the current fold
        trainInds = cv.training(fold);
        testInds = cv.test(fold);
        
        % Fit the random forest with the current number of variables to sample
        model = TreeBagger(numTrees, X(trainInds,:), y(trainInds), ...
                          'Method', 'regression', 'OOBPrediction', 'On', ...
                          'NumPredictorsToSample', numVarsToSample(i), ...
                          'MinLeafSize', 5, 'Options', statset('UseParallel', true));
        
        % Calculate out-of-bag MSE for the current model
        oobMSE = oobError(model, 'Mode', 'ensemble');
        
        % Predict on the test fold and calculate MSE
        yTestPred = predict(model, X(testInds,:));
        cvMSE(fold) = mean((y(testInds) - yTestPred).^2);
    end
    
    % Calculate the average MSE across the 2 folds
    avgCVTestMSE = mean(cvMSE);
    
    % Update the optimal number of variables if the current MSE is lower
    if avgCVTestMSE < minCVTestMSE
        minCVTestMSE = avgCVTestMSE;
        optimalNumVars = numVarsToSample(i);
    end
end

% Report the optimal number of variables and test MSE
fprintf('Optimal number of variables to sample at each split is %d\n', optimalNumVars);
fprintf('Test MSE with optimal number of variables is %.2f\n', minCVTestMSE);