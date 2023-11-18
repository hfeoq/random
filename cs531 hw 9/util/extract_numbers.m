function num = extract_numbers(in)
% extract numbers into an array from a string/char input
% num = extract_numbers('220808 SCAN008');
% returns: [220808, 8]
%A = regexp(in, '\d*', 'match');

% replaced regexp here 220929
A = regexp(in, '(-?\d+(\.\d*)?)|(-?\.\d+)', 'match');
num = zeros(length(A),1);
for i = 1:length(A)
   num(i) = str2double(A{i}); 
end
end