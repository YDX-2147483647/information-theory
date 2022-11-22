img = imread('../data/grayLena.png');
img = img(:,:,1);

blocks = split_to_blocks(img);


%% 变换
freq = dct_2d(blocks);

m = mean(abs(freq), 3);

imagesc(m);
title('变换后，8×8块中各点绝对值的平均值（后同）');
input('继续？> ');

imagesc(log(m));
title('变换后（按对数上色）');
input('继续？> ');


%% 量化
Q = readmatrix('luminance_quantum.csv');
data = quantize(freq, Q);

fprintf('量化后，非零元素只占 %.1f%%。\n', mean(logical(data), 'all') * 100);

imagesc(log(mean(abs(data), 3)));
title('量化后（按对数上色）');
