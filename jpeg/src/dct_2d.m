function y = dct_2d(x)
%dct_2d - Perform a 2D DCT (discrete cosine transform) on blocks
%
% y = dct_2d(x)

arguments
    x (:, :, :)
end

y = dct(x, [], 1);
y = dct(y, [], 2);
    
end