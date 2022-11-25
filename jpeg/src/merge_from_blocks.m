function img = merge_from_blocks(blocks, shape)
%merge_from_blocks - Recover the image from 8×8 blocks, whose values are signed integers
%
% img = merge_from_blocks(blocks, 1280, 720) 从 blocks 恢复出 1280×720 的图像

arguments
    blocks(8,8,:)
    shape(1,2) {mustBePositive, mustBeInteger}
end


%% Calculate shapes
pad_shape = mod(shape, 8);
pad_shape = mod(-pad_shape, 8);
padded_shape = shape + pad_shape;
height = padded_shape(1);

%% Merge
% dimensions of `blocks`: (h & w in a block, n_block)

% → (h & w in a block, h & w across blocks)
blocks = reshape(blocks, 8, 8, height / 8, []);

% → (h in a block, h across blocks, w in a block, w across blocks)
blocks = permute(blocks, [1 3 2 4]);

% → (height, width)
img = reshape(blocks, height, []);

%% Cut
img = img(1: shape(1), 1: shape(2));

%% Shift
img = uint8(img + 128);

end