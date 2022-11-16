%% 构造信源
alphabet = 1:10;
prob = randn(1, 10);
prob = prob - min(prob); % 总有个概率是零
prob = prob / sum(prob);

%% 生成信源符号
raw = randsrc(10, 1, [alphabet; prob]);

%% 编码
dict = huffmandict(alphabet, prob);
encoded = huffmanenco(raw, dict) ;

%% 解码
recovered = huffmandeco(encoded, dict) ;
isequal(raw, recovered)
