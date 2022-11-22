function p = zigzag_permutation(n)
%zigzag_permutation - Zigzag permutation
%
% p = zigzag_permutation(n)
%
% - i: linear index in original array.
% - p(i): index in zigzag sequence.

arguments
    n (1,1) {mustBePositive, mustBeInteger}
end


p = zeros(1, n * n);

% u, v are major and minor diagonal respectively.
% u ≡ row + col.

% zigzag index at v = 0.
start_z_index = 0;

for u = 0: n-1
    for v = 0: u
        if mod(u, 2) == 0
            row = u - v;
            col = v;
        else
            row = v;
            col = u - v;
        end
        array_index = row + n*col;

        z_index = start_z_index + v;
        
        p(array_index + 1) = z_index + 1;
    end

    start_z_index = start_z_index + u + 1;
end

for u = n: 2*n-2
    max_v = 2*n-2 - u;

    for v = 0: max_v
        if mod(u, 2) == 0
            row = n-1 - v;
            col = u - row;
        else
            col = n-1 - v;
            row = u - col;
        end
        array_index = row + n*col;

        z_index = start_z_index + v;
        
        p(array_index + 1) = z_index + 1;
    end

    start_z_index = start_z_index + max_v + 1;
end

end