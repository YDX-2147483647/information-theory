h = 4;
w = 4;
H = 3 * h;
W = 4 * h;

blocks = zeros(h, w, H/h * W/w);
for z = 1: size(blocks, 3)
    if mod(z, 2) == 0
        blocks(:, :, z) = z;
    else
        blocks(:, :, z) = 0;
    end
end


%% 分块
img = reshape(blocks, h, w, H/h, W/w);
img = permute(img, [1 3 2 4]);
img = reshape(img, H, W);
figure;
imagesc(img);
title('正确实现');


% 分条
img = reshape(blocks, H, W);
figure;
imagesc(img);
title('错误实现');
