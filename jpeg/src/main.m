img = imread('../data/grayLena.png');
img = img(:,:,1);

Q = readmatrix('luminance_quantum.csv');

[data, shape] = encode_img(img, Q);
fprintf("压缩前 %.1f kiB。压缩后 %.1f kiB，仅为 %.1f%%。\n", ...
    whos('img').bytes / 1024, ...
    whos('data').bytes / 1024, ...
    whos('data').bytes / whos('img').bytes * 100 ...
);

img_recovered = decode_img(data, shape, Q);
imshow(img_recovered);
