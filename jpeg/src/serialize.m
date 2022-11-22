function bytes = serialize(data)
%serialize - Serialize sequences of data by run length encoding
%
% bytes = serialize(data)

arguments
    data (64, :) int8
end

bytes = cell(1, size(data, 2));

for i = 1: size(data, 2)
    pairs = run_length_encode(data(:, i).');
    % Flatten the pairs and append two zeros.
    bytes{i} = [reshape(pairs.', 1, []) 0 0];
end

% Flatten
bytes = cat(2, bytes{:});

end