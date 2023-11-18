clear; close all

cd('C:\Users\Chen\OneDrive - Duke University\CS 531\hw 9')

% map of: number -> artist name
artists = get_map('artists50.in');

% matrices
A = get_matrix('dataAm50.in');
G = get_matrix('dataGm50.in');
H = get_matrix('dataHm50.in');

% get D

DA = getD(A);

% unnormalized Laplacian:
LA = DA - A;

% compute eigenvectors and eigenvalues of L
% [V,D] = eig(A)
% [V,D] = eig(A) returns diagonal matrix D of eigenvalues and matrix V whose columns are the corresponding right eigenvectors, so that A*V = V*D.
[evecsA, evalsA] = eig(LA);

fprintf('second smallest eigenvalue: %.2f\n', evalsA(2, 2));
fprintf('fiedler vector: %s\n', array2str(evecsA(:, 2), '%.3f'));

% sort the fiedler vector
[sorted_fie, idx] = sort(evecsA(:, 2));

% compute rho

% partition no. and partition result
partition_no = 1 : 49;
partition_res = zeros(size(partition_no));

idx_conv = containers.Map('KeyType','double','ValueType','double');
for i = 1 : 50
    idx_conv(i) = idx(i);
end

% random partitions
rng default

test_len = 1000;
rand_res = [];
for i = 1 : test_len
    rand_idx = randperm(50);
    pivot = randi([1, 49]);
    curr_l = rand_idx(1 : pivot);
    curr_r = rand_idx(pivot + 1: 50);
    rand_res(i) = get_rho(A, {curr_l, curr_r});
end

fprintf('random partitions, n = %d, distribution: %.3f ± %.3f\n', test_len, mean(rand_res), std(rand_res));

for i = 1 : length(partition_no)
    % default
    l = 1 : i;
    r = i + 1: 50;
    % convert to actual row index
    curr_l = batch_query(idx_conv, l);
    curr_r = batch_query(idx_conv, r);

    partition_res(i) = get_rho(A, {curr_l, curr_r});

end

best_cut = partition_no(partition_res == min(partition_res));
best_rho = partition_res(best_cut);
fprintf('optimal partitioning is case no. %d, optimal RHO value: %.3f\n', best_cut, best_rho);

    l = 1 : best_cut;
    r = best_cut + 1: 50;
    curr_l = batch_query(idx_conv, l);
    curr_r = batch_query(idx_conv, r);
    
    G1 = query_artists(artists, curr_l - 1);
    G2 = query_artists(artists, curr_r - 1);

    fprintf('Group 1 contains %d artists: %s\n', length(G1), cellArrayToString(G1));
    fprintf('Group 2 contains %d artists: %s\n', length(G2), cellArrayToString(G2));
% end of res

% problem 2: k means
%%
km_idx = kmeans(evecsA(:, 1: 2), 2);

parts = {};

for i = 1 : length(unique(km_idx))
    parts{i} = find(km_idx == i);
end

rho_k_2 = get_rho(A, parts);

%% just chance this km value

km = 3;
km_idx = kmeans(evecsA(:, 1: km), km);

parts = {};
for i = 1 : length(unique(km_idx))
    parts{i} = find(km_idx == i);
end

rho_k = get_rho(A, parts);
fprintf('k = %d, RHO = %.3f\n', km, rho_k);
fprintf('partitions: \n');

for i = 1 : length(parts)
    curr_artists = query_artists(artists, parts{i} - 1);
    fprintf('Group %d, size %d: %s\n', i, length(parts{i}), cellArrayToString(curr_artists));
end

% random partitions

test_len = 100;
rho_data = zeros(test_len, 1);

for i = 1 : test_len
    parts = {};
    pivots = [1, sort(randsample(50, km))' ];
    rand_idx = randperm(50);
    for j = 1 : km
        parts{j} = rand_idx(pivots(j):pivots(j + 1));
    end
    rho_data(i) = get_rho(A, parts);
    
end

fprintf('randomly partitioning data into %d groups, performed %d tests, RHO = %.3f pm %.3f\n',km, test_len , mean(rho_data), std(rho_data));


%%

function out = batch_query(m, in)
    out = zeros(size(in));
    for i = 1 : numel(in)
        out(i) = m(in(i));
    end
end

function out = query_artists(m, in)
    out = cell(size(in));
    for i = 1 : numel(in)
        % out{i} = m(in(i));
        out{i} = [num2str(in(i)) ',' , strrep(m(in(i)),' ', '_')];
    end

end

function rho = get_rho(A, S)
% A: matrix
% S: cell array describing partitioning

rho = 0;
for i = 1 : length(S)
    up_side = 0;
    down_side = 0;
    curr_idx = S{i};

    for j = 1 : length(curr_idx)
        down_side = down_side + sum(A(curr_idx(j), :));
    end
    
    for k = 1 : length(A(:, 1))
        for l = 1 : length(A(1, :))
            if (ismember(k, curr_idx) && ~ismember(l, curr_idx))
                up_side = up_side + A(k, l);
            end
        end
    end
    rho = rho + .5*up_side/down_side;
end




end


function D = getD(in)

sz = size(in);
assert(sz(1) == sz(2));
D = zeros(sz);
for i = 1 : length(in)
    D(i, i) = sum(in(i, :));
end

end

function map = get_map(file_name)
    fid = fopen(file_name);

if (fid == -1)
error(['cannot open file: ' file_name]);
end

map = containers.Map('KeyType','double','ValueType','char');

tline = fgetl(fid);
while ischar(tline)
    %curr = extract_numbers(tline);
    if isempty(tline)
        continue;
    end
    tmp = split(tline, ',');
    assert(length(tmp ) == 2)
    map(extract_numbers(tmp{1})) = tmp{2};
    tline = fgetl(fid);

end
fclose(fid);
end

function m = get_matrix(file_name)

fid = fopen(file_name);

if (fid == -1)
error(['cannot open file: ' file_name]);
end

m = [];
tline = fgetl(fid);
while ischar(tline)
    curr = extract_numbers(tline);
    curr = curr(:)';
    if isempty(curr)
        continue;
    end
    m = [m; curr];
    tline = fgetl(fid);
end
fclose(fid);


end