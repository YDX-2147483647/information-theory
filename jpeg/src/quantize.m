function y = quantize(x, Q)
%quantize - Quantize blocks
%
% y = quantize(x)

arguments
    x(8,8,:)
    Q(8,8)
end

y = int8(x ./ Q);

end