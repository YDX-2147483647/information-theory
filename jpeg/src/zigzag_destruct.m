function sequences = zigzag_destruct(blocks)
%zigzag_destruct - zigzag_destruct scan
%
% sequences = zigzag_destruct(blocks)

arguments
    blocks (8,8,:)
end


p = zeros(1, 64);
p(zigzag_permutation(8)) = 1:64;

sequences = reshape(blocks, 64, []);
sequences = sequences(p, :);

end