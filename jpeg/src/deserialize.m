function data = deserialize(bytes)
%deserialize - Deserialize sequences of data by run length encoding
%
% data = deserialize(bytes)

arguments
    bytes (1,:) int8
end


bytes = reshape(bytes.', 2, []).';

data = [];

start_i = 1;
for i = 1: length(bytes)
    if isequal(bytes(i, :), [0 0])
        pairs = bytes(start_i: i-1, :);
        data = [data; run_length_decode(pairs, 64)];

        start_i = i + 1;
    end
end

data = data.';

end