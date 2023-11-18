function str = array2str(varargin)
    % returns a java style string representation
    
    % modified 231117: added opt format spec
    arr = varargin{1};
    if nargin == 2
        format_spec = varargin{2};
    else
        format_spec = '';
    end

    assert(isvector(arr) && isnumeric(arr));
    str = ['[' to_str(arr(1), format_spec)];
    for i = 2: length(arr)
        str = [str, ', ' to_str(arr(i), format_spec)];
    end
    str = [str, ']'];
end

function out = to_str(in, format_spec)
   if isempty(format_spec)
       out = num2str(in); 
       return
   end
   out = sprintf(format_spec, in);
end