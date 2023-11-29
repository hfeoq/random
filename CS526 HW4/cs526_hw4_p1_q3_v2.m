clear; close all;

% Load the dataset
T = readtable(fullfile('C:\Users\Chen\OneDrive - Duke University\CS 526\HW 2\data','day.csv'));
y = T.cnt; % response data
X = [T.weathersit, T.temp, T.hum, T.windspeed]; % predictors

rng default; % For reproducibility

% Define the range for MinLeafSize
minLeafSize = 1:20;

% Initialize variables to store results
optimalLeafSize = NaN;
minTestMSE = inf;
testMSEs = zeros(length(minLeafSize), 1);

% Perform 2-fold cross-validation to find the optimal MinLeafSize
for i = 1:length(minLeafSize)
    cv = cvpartition(length(y),'KFold',2);
    cvMSEs = zeros(cv.NumTestSets, 1);
    
    for j = 1:cv.NumTestSets
        trainIdx = cv.training(j);
        testIdx = cv.test(j);
        
        % Fit the tree with the current MinLeafSize
        tree = fitrtree(X(trainIdx, :), y(trainIdx), 'MinLeafSize', minLeafSize(i));
        
        % Evaluate on the validation fold
        yPred = predict(tree, X(testIdx, :));
        cvMSEs(j) = mean((y(testIdx) - yPred).^2);
    end
    
    % Calculate the average MSE across the 2 folds
    testMSEs(i) = mean(cvMSEs);
    
    % Update the optimal parameters if the current MSE is lower
    if testMSEs(i) < minTestMSE
        minTestMSE = testMSEs(i);
        optimalLeafSize = minLeafSize(i);
    end
end

% Fit the tree with the optimal MinLeafSize using the full dataset
optimalTree = fitrtree(X, y, 'MinLeafSize', optimalLeafSize);

% Evaluate the optimal tree using another round of 2-fold CV
finalCV = cvpartition(length(y), 'KFold', 2);
finalMSEs = zeros(finalCV.NumTestSets, 1);
for j = 1:finalCV.NumTestSets
    trainIdx = finalCV.training(j);
    testIdx = finalCV.test(j);
    
    % Predict and calculate MSE for the final model
    yPred = predict(optimalTree, X(testIdx, :));
    finalMSEs(j) = mean((y(testIdx) - yPred).^2);
end
finalTestMSE = mean(finalMSEs);

% Plot the tree
view(optimalTree, 'Mode', 'graph');

% Report the test MSE
fprintf('Optimal MinLeafSize is %d\n', optimalLeafSize);
fprintf('Test MSE of the optimal tree is %.2f\n', finalTestMSE);