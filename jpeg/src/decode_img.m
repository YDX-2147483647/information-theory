function img = decode_img(data, shape, Q)
%decode_img - Decode an image from compressed data
%
% img = decode_img(data, shape)

arguments
    data (64,:)
    shape(1,2) {mustBePositive, mustBeInteger}
    Q(8,8)
end

data = zigzag_construct(data);
freq = dequantize(data, Q);
blocks = idct_2d(freq);
img = merge_from_blocks(blocks, shape);

end