% LASSO code for question 1, problem 1

clear; close all;

T = readtable(fullfile('C:\Users\Chen\OneDrive - Duke University\CS 526\HW 2\data','day.csv'));
S = table2struct(T);
sz = size(T);
len = sz(1);

% Extract the relevant fields into separate arrays
weathersit = [S.weathersit];
temp = [S.temp];
hum = [S.hum];
windspeed = [S.windspeed];
cnt = [S.cnt];

y = cnt(:); % response data

X = [weathersit(:), temp(:), hum(:), windspeed(:)]; % predictors

rng default; % For reproducibility

n_test = 5;
n_fold = 2;

% Define a range for the Lambda regularization parameter for LASSO
test_lambda = linspace(0, 20, 100); % LASSO does not support Lambda = 0

non_zero_coeff_count = [];
mse_data = [];
lambda_data = [];

for test_id = 1 : n_test
    
    cv = cvpartition(len,'KFold',n_fold);

    test_mse = zeros(size(test_lambda));

    for lambda_idx = 1 : length(test_lambda)
        curr_lambda = test_lambda(lambda_idx);
        curr_mse = [];
        for fold_idx = 1 : n_fold
            test_idx = cv.test(fold_idx);
            train_idx = ~test_idx;

            % do training with LASSO
    
%             tree = fitrtree([Weight, Cylinders],MPG,...
%                 'CategoricalPredictors',2,'MinParentSize',20,...
%                 'PredictorNames',{'W','C'})

            tree = fitrtree(X(train_idx, :), y(train_idx), 'MinParentSize', 20, 'PredictorNames', {'w','t','h','ws'});
            % MPG4Kpred = predict(tree,[4000 4; 4000 6; 4000 8])
            % get y_hat, do cv
            y_hat = predict(tree, X(test_idx, :));
            curr_mse(fold_idx) = get_mse(y_hat, y(test_idx));
        end
        test_mse(lambda_idx) = mean(curr_mse);
    end
    
    % report optimal lambda
    optimal_lambda_idx = 1;
    fprintf('# test no. %d\n', test_id);
    %fprintf('optimal lambda found at %dth test\n', optimal_lambda_idx);
    optimal_lambda = test_lambda(optimal_lambda_idx);
    %fprintf('optimal lambda is: %.3f, minimum MSE is: %.3f\n', optimal_lambda, min(test_mse));
    fprintf('minimum MSE is: %.3f\n', min(test_mse));
    %non_zero_coeff_count = [non_zero_coeff_count, sum(B ~= 0)];
    %fprintf('coefficients: %s\n', array2str(B));
    %fprintf('number of non-zero coefficients: %d\n', non_zero_coeff_count(end));
    mse_data = [mse_data, min(test_mse)];
    lambda_data = [lambda_data, optimal_lambda];
    if length(lambda_data) == 5
        break;
    end

    if test_id == 1
        figure;view(tree,'Mode','graph');

    end
end

fprintf('%s\n', '# summary of tests');
%fprintf('performed %d tests, %d of them are valid\n',  test_id, length(mse_data));
fprintf('optimal MSE = %.2f\n', min(mse_data));