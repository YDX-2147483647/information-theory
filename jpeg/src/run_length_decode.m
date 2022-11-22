function sequence = run_length_decode(pairs, full_length)
%run_length_decode - Recover a sequence from runs counts
%
% sequence = run_length_decode(pairs, 64)
%
% A pair is [n_zeros, nonzero_value].

arguments
    pairs (:, 2) int8
    full_length (1, 1) {mustBePositive, mustBeInteger}
end

sequence = [];

for i = 1:size(pairs, 1)
    sequence = [sequence zeros(1, pairs(i, 1)) pairs(i, 2)];
end

sequence = [sequence zeros(1, full_length - length(sequence))];

end