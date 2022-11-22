img = imread('../data/grayLena.png');
img = img(:,:,1);

Q = readmatrix('luminance_quantum.csv');

[data, shape] = encode_img(img, Q);
img_recovered = decode_img(data, shape, Q);
imshow(img_recovered);
