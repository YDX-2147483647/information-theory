function [data, shape] = encode_img(img, Q)
%encode_img - Decode an image from compressed data
%
% [data, shape] = encode_img(img)

arguments
    img(:,:) uint8
    Q(8,8)
end

shape = size(img);

blocks = split_to_blocks(img);
freq = dct_2d(blocks);
data = quantize(freq, Q);
data = zigzag_destruct(data);

end