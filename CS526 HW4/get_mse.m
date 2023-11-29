function err = get_mse(y1, y2)
% get square err between two arrays (of the same length)
check_input(y1);
check_input(y2);
assert(length(y1) == length(y2));

err = sum((y1(:) - y2(:)).^2)/length(y1);
end

function check_input(in)
assert(isnumeric(in) && isvector(in) && isreal(in));
end