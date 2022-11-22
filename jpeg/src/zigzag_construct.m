function blocks = zigzag_construct(sequences)
%zigzag_construct - zigzag_construct scan
%
% blocks = zigzag_construct(sequences)

arguments
    sequences (64, :)
end


p = zeros(1, 64);
p(zigzag_permutation(8)) = 1:64;

sequences = sequences(p, :);
blocks = reshape(sequences, 8, 8, []);

end