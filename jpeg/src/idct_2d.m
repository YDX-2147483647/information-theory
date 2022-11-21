function x = idct_2d(y)
%idct_2d - Perform a 2D inverse DCT (discrete cosine transform) on blocks
%
% x = idct_2d(y)

arguments
    y (:, :, :)
end

x = idct(y, [], 1);
x = idct(x, [], 2);
    
end