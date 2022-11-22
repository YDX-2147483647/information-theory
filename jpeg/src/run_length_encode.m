function pairs = run_length_encode(sequence)
%run_length_encode - Count runs of a sequence
%
% pairs = run_length_encode(sequence)
%
% A pair is [n_zeros, nonzero_value].

arguments
    sequence (1, :) int8
end

pairs = [];
% We'll append items dynamically to it.
% There are only 1 or 2 pairs in most cases, so that's OK.

n_zeros = 0;

for x = sequence
    if x ~= 0
        % Save the pair
        pairs = [pairs; [n_zeros x]];

        % Reset
        n_zeros = 0;
    else
        n_zeros = n_zeros + 1;
    end
end

end