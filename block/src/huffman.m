%% 构造信源
alphabet = 1:10;
prob = randn(1, 10);
prob = prob - min(prob); % 总有个概率是零
prob = prob / sum(prob);

figure('Name', 'Huffman');
labels = compose("%d (%.1f%%)", [alphabet', 100 * prob']);
pie(prob, labels);
title('信源分布');

%% 生成信源符号
raw = randsrc(10, 1, [alphabet; prob]);

fprintf('信源符号：%s.\n', join(string(raw), ', '));

%% 编码
dict = huffmandict(alphabet, prob);
encoded = huffmanenco(raw, dict) ;

fprintf('编码规则：\n');
rules = cellfun(@(c) num2str(c, '%d'), dict, 'UniformOutput', false);
fprintf('  %s\n', join(string(rules), ' → '));

fprintf('编码后：%s.\n', join(string(encoded), ''));

%% 解码
recovered = huffmandeco(encoded, dict);

fprintf('解码后：%s.\n', join(string(recovered), ', '));
if isequal(raw, recovered)
    fprintf('✓ 一致。\n');
else
    fprintf('✗ 不一致。\n');
end

