# 线性分组码

## 1 Huffman 编码

源代码：[`huffman.m`](./src/huffman.m)。

运行结果如下。

![](./fig/huffman.jpg)

```matlab
>> huffman
信源符号：6, 3, 8, 9, 6, 3, 2, 6, 2, 1.
编码规则：
  1 → 100
  2 → 000
  3 → 010
  4 → 00110
  5 → 001111
  6 → 011
  7 → 001110
  8 → 101
  9 → 0010
  10 → 11
编码后：0110101010010011010000011000100.
解码后：6, 3, 8, 9, 6, 3, 2, 6, 2, 1.
✓ 一致。
```

## 2 模拟传输线性分组码

源代码：[`sim_channel.m`](./src/sim_channel.m)、[`sim_source.m`](./src/sim_source.m)。Simulink：[`linear_BSC.slx`](./linear_BSC.slx)。

### 改变信道错误概率（`sim_channel.m`）

> 此部分为视频讲解内容。

信源为二元均匀分布信源；编码为线性分组码，其生成矩阵如下。

$$
\begin{bmatrix}
1 & 1 & 0 & 1 &   &   &   \\
0 & 1 & 1 &   & 1 &   &   \\
1 & 1 & 1 &   &   & 1 &   \\
1 & 0 & 1 &   &   &   & 1 \\
\end{bmatrix}.
$$

运行结果如下。

![](fig/bar-屏幕截图 2022-11-06 140509.png)

![](fig/simulink-屏幕截图 2022-11-21 153851.jpg)

![成功-屏幕截图 2022-11-06 135856](fig/成功-屏幕截图 2022-11-06 135856.png)

红线没编码，误码率就是信道错误概率。

### 改变信源分布（`sim_source.m`）

信道为二元对称信道，错误概率为 0.05；编码同上。

运行结果如下。

<img src="fig/source.jpg" style="width: 70%;" />

由图，对于线性分组码、二元对称信道，误码率和信源分布无关！

这并非不合理。注意译码过程：校验矩阵 $H$ × 接收序列 $R$ ⇒ 伴随式 $S$ ⇒ 错误图样 $E$——纠错的结论是错误图样 $E$，不涉及具体发送什么码字。根据信道错误概率，可将错误图样 $E$ 直接转换为误码率 $P_E$。

因此，无论发送什么码字，这一条件下的误码率都相等。进而总误码率与各个码字的发送比例无关，即误码率与信源分布无关。

### 遇到的问题：模拟次数太少时，误码率会很不准

模拟次数 = Sample time × Samples per frame，这两项的默认值分别是1、4。最开始我没改，误码率一直是零，莫名其妙。

> 此节的图都是“改变信道错误概率”。

![](fig/sample_rate-1.png)

调试就是调一调试一试，我把信道错误概率改得特别大（最大 5% → 90%），发现误码率不是零了。后来又转了几个弯，最终发觉是模拟次数太少——如果只模拟四次，全都正确的概率不低于 $\qty(1-0.05)^4 \approx 81.5\%$，确实很大。

经过试验，我发现采样频率一万次（下图右）曲线比较平滑（⇒ 误差足够小），时间也勉强能接受（两三分钟）。

<figure>
  <div style='display: grid; grid-template-columns: repeat(2, auto);'>
    <img src='fig/sample_rate-100.jpg'>
    <img src='fig/sample_rate-10000.jpg'>
  </div>
  <figcaption>采样频率 100（左）、10000（右）时的图象</figcaption>
</figure>

#### 事后诸葛亮

可用随机变量 $E$ 描述传递错误的次数，它服从 $\operatorname{Bernoulli}(n,q)$，其中 $n$ 是传输次数，$p$ 是信道单次错误概率。可知 $\operatorname{Var} E = nq(1-q)$。

误码率 $\eta = E/n$，其期望当然是 $q$。又

$$
\operatorname{Var} \eta = \frac{\operatorname{Var} E}{n^2} = \frac{q(1-q)}{n}.
$$

相对误差远小于一即 $\sqrt{\operatorname{Var} E} \ll q$，相当于 $ \sqrt{n} \gg \sqrt{1-q} / \sqrt{q} \approx 1/\sqrt{q}$，或者 $n \gg 1/q$。这里 $q \approx 0.025$，图中差 10% 就能看出来，$n$ 要远大于 $1 / 0.025 / 10\% \approx 400$ 才行。
