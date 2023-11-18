function str = cellArrayToString(cellArray)
    % This function takes a cell array of char arrays (strings) and returns a string
    % representation in the desired format: ['s_1', 's_2', ..., 's_n']

    % Initialize an empty string
    str = '[';

    % Loop through each element of the cell array
    for i = 1:length(cellArray)
        % Append the current string to the output, enclosed in single quotes
        str = [str, '''', cellArray{i}, ''''];

        % If it's not the last element, add a comma and space
        if i ~= length(cellArray)
            str = [str, ', '];
        end
    end

    % Close the bracket
    str = [str, ']'];
end