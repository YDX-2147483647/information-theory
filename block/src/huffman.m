% Create unique symbols, and assign probabilities of occurrence to them.
symbols = 1:6;
p = [.5 .125 .125 .125 .0625 .0625];
% Create a Huffman dictionary based on the symbols and their probabilities.
dict = huffmandict(symbols , p);
% Generate a vector of random symbols.
inputSig = randsrc(10,1, [symbols; p]);
% Encode the random symbols.
code = huffmanenco(inputSig, dict) ;
% Decode the data.
sig = huffmandeco(code, dict) ;
% Verify that the decoded symbols match the original symbols.
isequal(inputSig, sig)
