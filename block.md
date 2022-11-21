# [线性分组码](https://lexue.bit.edu.cn/course/view.php?id=12272)

- [x] 用 MATLAB 实现一个信源，信源符号数为10；进行霍夫曼编码，输出符号的码字。

  信源分布构造规则：用高斯分布生成10个随机数，将之平移、归一，使总和为1，以此作为信源各符号的概率。

  提交源代码及运行结果截图。

- [x] 运行 MATLAB Simulink 模拟线性分组码的实验，然后修改信源为其它信源或者修改参数。

  提交实验代码、中间过程截图。

## 笔记

`huffmandict`需要 Communications Toolbox。

### Simulink

> Comm: Communication.

- Comm Sources → Random Data Sources → Bernoulli Binary Generator
- Channels → Binary Symmetric Channel
- Comm Sinks → Error Rate Calculation

信源要成组输出，Samples per Frame 不能按默认值一，不然后面没法编码。Sample time 如果太小，模拟次数太小，误码率会很不准。

变量名是在模型中设置的。
