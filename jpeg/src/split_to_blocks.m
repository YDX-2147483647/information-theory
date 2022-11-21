function blocks = split_to_blocks(img)
%split_to_blocks - Group the image to 8×8 blocks and shift to signed integers
%
% blocks = split_to_blocks(img)

arguments
    img(:,:)
end


%% Shift
img = img - 128;

%% Pad
pad_shape = mod(size(img), 8);
pad_shape = mod(-pad_shape, 8);
img = padarray(img, pad_shape, 'post');

%% Split
blocks = reshape(img, 8, 8, []);

end