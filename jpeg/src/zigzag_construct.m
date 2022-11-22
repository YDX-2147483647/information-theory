function blocks = zigzag_construct(sequences)
%zigzag_construct - zigzag_construct scan
%
% blocks = zigzag_construct(sequences)

arguments
    sequences (64, :)
end


sequences = sequences(zigzag_permutation(8), :);
blocks = reshape(sequences, 8, 8, []);

end