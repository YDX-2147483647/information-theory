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
input('继续？> ');


%% 游程编码
data = zigzag_destruct(data);
data = serialize(data);
fprintf("游程编码后，数据量从 %.1f kiB 降到了 %.1f kiB，仅为 %.1f%%。\n", ...
    whos('img').bytes / 1024, ...
    whos('data').bytes / 1024, ...
    whos('data').bytes / whos('img').bytes * 100 ...
);
fprintf('编码后数据分布仍不均匀，而且是两种分布混合（零附近的 AC 与 +60 附近的 DC）。\n');
fprintf('总之仍有进一步压缩空间。\n');
histogram(data);
title('游程编码后数据');
xlabel('数据取值');
ylabel('频数/组距');

