source_prob = 0.5;  % probability of zero
EB = 0: .005: .05;

% bit error rates
ber1 = zeros(1, length(EB));
ber2 = zeros(1, length(EB));

%% Simulate
bar = waitbar(0, 'Start', 'Name', 'Simulating');
for i = 1: length(EB)
    err = EB(i);
    waitbar(i / length(EB), bar, ['error rate: ' num2str(err)]);
    out = sim('../linear_BSC');

    ber1(i) = out.ErrorVecRaw(end, 1);
    ber2(i) = out.ErrorVecCoding(end, 1);
end
close(bar)

%% Draw
plot( ...
    EB, ber1, 'ro-', ...
    EB, ber2, 'b--+', ...
    'LineWidth', 2, 'MarkerSize', 4 ...
);
legend('Raw', 'Linear Coding');
xlabel('信道差错概率');
ylabel('误码率');

grid on;
set(gca, 'FontSize', 16);
