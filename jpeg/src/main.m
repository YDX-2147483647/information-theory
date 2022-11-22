img = imread('../data/grayLena.png');
img = img(:,:,1);

blocks = split_to_blocks(img);
freq = dct_2d(blocks);
blocks_recovered = idct_2d(freq);
img_recovered = merge_from_blocks(blocks, size(img));
imshow(img_recovered);
