function sequences = zigzag_destruct(blocks)
%zigzag_destruct - zigzag_destruct scan
%
% sequences = zigzag_destruct(blocks)

arguments
    blocks (8,8,:)
end


sequences = reshape(blocks, 64, []);
sequences = sequences(zigzag_permutation(8), :);

end