function x = dequantize(y, Q)
%dequantize - Dequantize blocks
%
% x = dequantize(y)

arguments
    y(8,8,:)
    Q(8,8)
end

x = double(y) .* Q;

end