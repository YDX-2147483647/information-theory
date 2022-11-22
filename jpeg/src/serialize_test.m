data = int8(randi([-128 127], 64, 10));
bytes = serialize(data);

%% Shapes
assert(size(serialize(data), 1) == 1);
assert(mod(size(serialize(data), 2), 2) == 0);
assert(size(deserialize(bytes), 1) == 64);

%% Inverse
assert(isequal( ...
    deserialize(bytes), ...
    data ...
));
