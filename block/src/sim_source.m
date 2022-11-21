source_prob_list = [.05 .1: .1: .8];  % probability of zero
err = 0.05;

% bit error rates
ber1 = zeros(1, length(source_prob_list));
ber2 = zeros(1, length(source_prob_list));

%% Simulate
bar = waitbar(0, 'Start', 'Name', 'Simulating');
for i = 1: length(source_prob_list)
    source_prob = source_prob_list(i);
    waitbar(i / length(source_prob_list), bar, ['probability of zero: ' num2str(source_prob)]);
    out = sim('../linear_BSC');

    ber1(i) = out.ErrorVecRaw(end, 1);
    ber2(i) = out.ErrorVecCoding(end, 1);
end
close(bar)

%% Draw
plot( ...
    source_prob_list, ber1, 'ro-', ...
    source_prob_list, ber2, 'b--+', ...
    'LineWidth', 2, 'MarkerSize', 4 ...
);
legend('Raw', 'Linear Coding');
xlabel('信源取零的概率');
ylabel('误码率');

grid on;
set(gca, 'FontSize', 16);
