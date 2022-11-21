rng(42);
original_img = randn(70, 120);

%% Shapes
blocks = split_to_blocks(original_img);
assert(isequal( ...
    size(blocks), ...
    [8 8 ceil(70/8) * ceil(120/8)] ...
));

img = merge_from_blocks(blocks, size(original_img));
assert(isequal( ...
    size(img), ...
    size(original_img) ...
));


%% Values
delta = merge_from_blocks(split_to_blocks(original_img), size(original_img)) - original_img;
assert(all(delta < 1e-6, 'all'));

