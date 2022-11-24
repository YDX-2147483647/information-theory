function blocks = split_to_blocks(img)
%split_to_blocks - Group the image to 8×8 blocks and shift to signed integers
%
% blocks = split_to_blocks(img)

arguments
    img(:,:) uint8
end


%% Shift
img = double(img) - 128;

%% Pad
pad_shape = mod(size(img), 8);
pad_shape = mod(-pad_shape, 8);
img = padarray(img, pad_shape, 'post');

%% Split
% dimensions of `img`: (height, width)

% → (h in a block, h accross blocks, w in a block, w across blocks)
blocks = reshape(img, 8, size(img, 1) / 8, 8, []);

% → (h & w in a block, h & w accross blocks)
blocks = permute(blocks, [1 3 2 4]);

% → (h & w in a block, n_block)
blocks = reshape(blocks, 8, 8, []);

end