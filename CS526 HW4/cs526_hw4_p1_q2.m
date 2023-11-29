% lasso
% B = lasso(X,y)

clear; close all

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

rng default;

n_test = 5;
n_fold = 2;

test_lambda = linspace(0, 20, 500);

all_lambda = [];
all_mse = [];

for test_id = 1 : n_test
    fprintf('# test no. %d\n', test_id);
    cv = cvpartition(len,'KFold',n_fold);

    test_mse = zeros(size(test_lambda));

    for lambda_idx = 1 : length(test_lambda)
        curr_lambda = test_lambda(lambda_idx);
        curr_mse = [];
        for fold_idx = 1 : n_fold            
            test_idx = cv.test(fold_idx);
            train_idx = ~test_idx;
            % do training
            % copied from matlab docs
            [B, FitInfo] = lasso(X(train_idx,:), y(train_idx));
            idxLambda1SE = FitInfo.Index1SE;
            coef = B(:,idxLambda1SE);
            coef0 = FitInfo.Intercept(idxLambda1SE);
            % get y_hat, do cv
            % yhat = XTest*coef + coef0;
            y_hat = coef0 + X(test_idx,:)*coef;
            curr_mse(fold_idx) = get_mse(y_hat, y(test_idx));
            error('@@')
        end
        test_mse(lambda_idx) = mean(curr_mse);
    end

    % report optimal lambda
    optimal_lambda_idx = find(test_mse == min(test_mse));
    fprintf('optimal lambda found at %dth test\n', optimal_lambda_idx);
    optimal_lambda = test_lambda(optimal_lambda_idx);
    fprintf('optimal lambda is: %.3f, minimum MSE is: %d\n', optimal_lambda, min(test_mse));

    all_lambda(test_id) = optimal_lambda;
    all_mse(test_id) = min(test_mse);
    
end

% report global optimal:
fprintf('# optimal result from all tests:\n')
fprintf('optimal lambda found through %d tests: %d\n', n_test, all_lambda(all_mse == min(all_mse)))
fprintf('optimal MSE found through %d tests: %d\n', n_test, min(all_mse))