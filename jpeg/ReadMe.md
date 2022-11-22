# 基于DCT变换的图像编码

## 运行效果

```matlab
% 测试
>> cd src
>> runtests
……
总计:
   13 Passed, 0 Failed, 0 Incomplete.
   0.26174 秒测试时间。
```

```matlab
% 图像的编码与解码
>> main
```

这会编码`./data/grayLena.png`，然后再解码。

<figure>
    <div style="display: grid; grid-template-columns: 1fr 2fr;">
        <img src="data/grayLena.png">
        <img src="fig/main.jpg">
    </div>
    <figcaption>左：原图<br>右：编码再解码后</figcaption>
</figure>

```matlab
% 编码过程中的一些细节
>> main_hack
% 该脚本的结果及解释见下。
```

## 压缩算法

### 大致原理

标准 JPEG 算法如下。

```mermaid
flowchart LR
    Image[图像] --> Blocks["Blocks<br>8×8 块"] --> DCT

    subgraph 编码器
        DCT --> Quantizer["Quantizer<br>量化器"] --> entropy["Entropy Encoder<br>熵编码器"]
    end
    
    table(["Table Specifications"]) -.-> Quantizer
    table -.-> entropy

    entropy --> Compressed[压缩后数据]
```

```mermaid
flowchart LR
    Compressed[压缩后数据] --> entropy["Entropy Decoder<br>熵解码器"]

    subgraph 解码器
        entropy --> Dequantizer["Dequantizer<br>量化恢复器"] --> IDCT
    end
    
    table(["Table Specifications"]) -.-> Dequantizer
    table -.-> entropy

    IDCT --> Blocks["Blocks<br>8×8 块"] --> Image[图像]
```

- **图像**：彩色图像，亮度、颜色分开处理，颜色的分辨率比亮度小。
- **熵编码**：DC、AC 分开处理，DC 用 DPCM（Differential Pulse Code Modulation），AC 用游程编码和 Huffman 编码。

我这里实现的压缩算法大体与它相同，只是有如下区别。

- **图像**：只处理灰度图像。因此后续量化时只用亮度一张表，不用颜色的表。
- **熵编码**：DC、AC 不作区分，统一用游程编码，并且不再进一步用 Huffman 编码。因此我这里熵编码没有第二张规定的表（上图中的 Table Specifications）。

### 流程

#### 1 分块（`split_to_blocks`、`merge_from_blocks`）

- **转换数据类型**

  原始图像是`uint8`、$[0, 256)$，转换后是`double`、$[-128, 128)$。

- **分块／合并**

  后续 DCT（Discrete Cosine Transform）关注图像中的强关联。为了让它几种精力处理“空间位置接近”的关联，要把图像划分成一系列 8×8 的小块。

  由于图像长宽不一定是 8 的整倍数，还要补零或切零。

  原始图像是 685×806，补零为 688×808，分块后是 8×8 × 8686。

#### 2 变换（`dct_2d`、`idct_2d`）

对每一个 8×8 块分别应用二维 DCT 变换。

如下图，变换后低频部分（横纵坐标较小的）数值较大，高频部分几乎为零。

<figure>
    <div style='display: grid; grid-template-columns: repeat(2, auto);'>
        <img src="fig/main_hack-dct.jpg">
        <img src="fig/main_hack-dct-log.jpg">
    </div>
    <figcaption>变换后块中各点取值的绝对值的平均值（此后简称“情况”）</figcaption>
</figure>

#### 3 量化（`quantize`、`dequantize`）

- **量化**

  按量化表（`src/luminance_quantum.csv`）量化（多对一映射）上一步结果，低频量化精度更高。

- **转换数据类型**

  上一步是`double`，之后都是`int8`。

量化后，出现非常多的零，剩下非零部分的范围也缩小了。

> 由图，上一步范围大致是 $[e^1, e^6]$，量化后则是 $[e^{-8}, e^2]$。


```matlab
>> main_hack
……
量化后，非零元素只占 14.3%。
……
```

<figure>
    <img src="fig/main_hack-quantize-log.jpg" style='max-width: 70%;'>
    <figcaption>量化后情况</figcaption>
</figure>

#### 4 斜线扫描（`zigzag_destruct`、`zigzag_construct`）

上一步每块数据仍是 8×8 块，为方便后续熵编码，斜线扫描为 64 序列。

<figure>
    <img src="ReadMe.assets/zigzag.png" style="max-width: 40%;">
    <figcaption>斜线扫描｜<a href="https://medium.com/geekculture/how-jpeg-compression-works-a751cd877c8c">Bilal Himite</a></figcaption>
</figure>

下面以解码时的`zigzag_construct`为例，介绍我的实现。

1. **在第一维应用置换。**

   ```matlab
   sequences = sequences(zigzag_permutation(8), :);
   ```

   其中`zigzag_permutation(n)`构造一段序列，“第 $i$ 个元素为 $p$”表示（在 $n\times n$ 方阵中）线性索引为 $i$ 的那个元素（在斜线扫描后）应当位于 $p$ 处。

   ```matlab
   >> zigzag_permutation(3)
   ans =
        1     3     4     2     5     8     6     7     9
   
   >> reshape(ans, 3, 3)
   ans =
        1     2     6
        3     5     7
        4     8     9
   ```
   
   > `zigzag_permutation`是我自己写的函数，很繁琐。我在[源代码](./src/zigzag_permutation.m)里简单解释了一下，请参考。

2. **将 64×n 重建为 8×8×n。**

   ```matlab
   blocks = reshape(sequences, 8, 8, []);
   ```

#### 5 熵编码（`serialize`、`deserialize`）

- **游程编码**

  分别对每一串 64 序列应用游程编码。

  我这里只记“零”的游程，所以编码后是一些二元对 (前导零的数量, 非零元)。若最后剩一串零，则直接忽略——解码时能根据序列长补上。

  每一串序列编码前是`(1, :)`，编码后是`(:, 2)`。

- **序列化**

  每串序列游程编码后不一样长，难以直接存储。我这里将它们排成一大串，用`[0 0]`分隔。

  序列化前是一系列`(:, 2)`，之后是`(1, :)`。

到这里，我的整个编解码过程就结束了。

```matlab
>> main_hack
……
游程编码后，数据量从 539.2 kiB 降到了 172.4 kiB，仅为 32.0%。
编码后数据分布仍不均匀，而且是两种分布混合（零附近的 AC 与 +60 附近的 DC）。
若当成无记忆信源，按频率估计概率，则码率只有 3.17 bits/sig，效率仅为 39.6%。
总之仍有进一步压缩空间。
……
```

> “数据量”指最终`int8`序列的大小。

<figure>
    <img src="fig/main_hack-serialize.jpg" style='max-width: 70%;'>
    <figcaption>游程编码后数据</figcaption>
</figure>
> 图片原文件有 271.0 kiB，如果抛去色彩因素，除以 3，是 90.3 kiB，大概是我这结果的一半。
>
> 假如我再进一步用 Huffman 编码，把效率提高到百分之八九十，大小就和原文件差不多了。

### 评估

```matlab
>> main_hack
……
均方误差失真为 31.04。
```

<figure>
    <img src="fig/main_hack-distortion.jpg" style='max-width: 70%;'>
    <figcaption>图像逐点误差绝对值</figcaption>
</figure>


如上图，大部分地方几乎没误差（10 以下），个别地方（主要是图形边缘）误差超过 60。再看大体趋势，粗糙的帽子、装饰物误差大，光滑的皮肤、墙误差小。

## 案例分析

### 准备

```matlab
>> img = imread('../data/grayLena.png');
>> img = img(:,:,1);
>> blocks = split_to_blocks(img);
```

以第 4012 个 8×8 块为例。

```matlab
>> b = blocks(:, :, 4012)
b =
     4   -11    58    41    29    46    30    42
    -2    12    57    41    50    25    24    30
    -5    52    54    37    58    27    38    33
   -10    42    48    31    42    41    37    36
   -12    39    59    44    45    34    36    39
    -7    51    54    30    48    13    26    20
   -11    34    40    45    24    35    30    37
    -5    54    39    48    33    43    37    39

>> imagesc(b)
```

<img src="fig/case-block.jpg" style="zoom:50%;" />

$4012 = \qty(688/8) \times 46 + 56$，这一块的左上角是原图的 $(46 \times 8,\ 56 \times 8) = (368, 448)$，位置大概如下图。

```matlab
>> c = zeros(685, 806, 3);
>> c(:, :, 1) = img; c(:, :, 2) = img; c(:, :, 3) = img;

% ↓ 为方便观察，画大一些。
>> c(368-10: 368+17, 448-10: 448+17, 2:3) = 0;
>> c(368-10: 368+17, 448-10: 448+17, 1) = 255;

>> imshow(uint8(c))
```

<img src="fig/case-position.jpg" style="zoom: 33%;" />

### 编码过程

块已经分好，直接做**变换**。

```matlab
>> f = dct_2d(b)
f =
  259.7500  -40.1435  -77.8741  -72.1018  -41.2500  -31.1845   -5.0860   10.7462
   -2.8465  -10.1406   -9.7197    4.4149   15.3615   15.3257   28.5243   24.5352
   -7.8434   -9.9118    3.3817    4.6370   13.0696   22.6733   21.2708  -13.6949
  -15.8655    0.0486   -3.3091   -5.6548    6.7470   14.0723   18.8684    9.0985
    9.7500  -17.7385    5.0077    3.7682   -5.2500    8.7413   14.7028  -13.3926
   -5.7965  -10.0556    9.1781    4.7127   -5.1196    4.9330    6.8972  -10.1009
    7.8490   12.4182    2.7708    2.2542   -5.6842  -10.6653  -12.8817    8.5636
    9.6350   -7.8245   -0.9036   -5.6762    1.0217    4.8720    1.6745   -6.1376

>> imagesc(f)
>> colorbar
```

<img src="fig/case-freq.jpg" style="zoom: 50%;" />

然后**量化**。

```matlab
>> Q = readmatrix('luminance_quantum.csv');

>> d = quantize(f, Q)
d =
  8×8 int8 矩阵
    16    -4    -8    -5    -2    -1     0     0
     0    -1    -1     0     1     0     0     0
    -1    -1     0     0     0     0     0     0
    -1     0     0     0     0     0     0     0
     1    -1     0     0     0     0     0     0
     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0
```

接着**斜线扫描**。

```matlab
>> s = zigzag_destruct(d)
s =
  64×1 int8 列向量
    16
    -4
     0
    -1
    ……
```

最后**熵编码**。只记录了开头 $14 + 1 + 3 + 2 = 20$ 个元素，剩下都是零。

```matlab
>> run_length_encode(s.')
ans =
  14×2 int8 矩阵
     0    16
     0    -4
     1    -1
     0    -1
     0    -8
     0    -5
     0    -1
     0    -1
     0    -1
     0     1
     3    -2
     0    -1
     0     1
     2    -1
```

用`serialize`就是压平再补分隔符。

```matlab
>> bytes = serialize(s)
bytes =
  1×30 int8 行向量
  列 1 至 12
     0    16     0    -4     1    -1     0    -1     0    -8     0    -5
  ……
  列 25 至 30
     0     1     2    -1     0     0
```

### 评估

```matlab
>> whos('bytes', 'b')
  Name      Size            Bytes  Class     Attributes
  bytes     1x30               30  int8                
  b         8x8               512  double     
```

编码前是 8×8 个`int8`，一共 64 B；编码后是 30 个`int8`，共 30 B。因此压缩比为 46.9%。

下面来看失真。

```matlab
>> recovered = decode_img(bytes, 8, 8)
recovered =
  8×8 uint8 矩阵
   112   132   149   155   154   148   144   147
   117   136   151   155   152   146   141   143
   121   140   155   157   153   147   142   143
   122   142   157   158   155   150   146   147
   122   142   156   155   152   148   145   145
   121   142   154   151   147   143   140   139
   120   142   154   150   146   144   142   140
   119   142   155   152   149   149   148   146

% ↓ uint8 可能溢出，故要先转换。
>> int8(double(recovered) - double(img(368: 368+7, 448: 448+7)))
ans =
  8×8 int8 矩阵
    -2    17    30    29    33    25    23    21
    21    46    52    42    35    24    15    22
    29    53    70    68    61    33    24    25
    11    37    61    58    68    53    33    28
    -3    23    45    45    49    50    36    24
   -11    16    35    32    29    27    28    19
   -10    18    38    31    28    22    14     3
   -17    13    37    31    22     7    -8   -27

>> mean(ans .^ 2, 'all')
ans =
  118.5781
```

均方误差为 118.6，其算术平方根为 10.9，与 256 相比不是很大。

## 可能存在的问题

`padarray`等函数需要 Image Processing Toolbox。

## 参考

- [图像处理-余弦变换 - PamShao - 博客园](https://www.cnblogs.com/pam-sh/p/14533603.html)

- [数字图像处理（三）—— 离散余弦变换 - 知乎](https://zhuanlan.zhihu.com/p/114626779)（[GitHub](https://github.com/Jingtao-ZHANG/DigitalImageProcessingWithPython/blob/master/04-DCT.py)）

- [The JPEG Still Picture Compression Standard](https://www.ijg.org/files/Wallace.JPEG.pdf)

  `Wallace.JPEG.pdf`

- [JPEG at 25: Still Going Strong | IEEE Journals & Magazine | IEEE Xplore](https://ieeexplore.ieee.org/document/7924246)

  `JPEG_at_25_Still_Going_Strong.pdf`

- [Digital compression and coding of continuous-tone still images requirements and guidelines](https://repo.zenk-security.com/Cryptographie%20.%20Algorithmes%20.%20Steganographie/DIGITAL%20COMPRESSION%20AND%20CODING%20OF%20CONTINUOUS-TONE%20STILL%20IMAGES%20REQUIREMENTS%20AND%20GUIDELINES.pdf)

  `ISO_IEC_10918-1-1993-E.pdf`

- [How JPEG Compression Works. Explaining the magic steps behind JPEG… | by Bilal Himite | Geek Culture | Medium](https://medium.com/geekculture/how-jpeg-compression-works-a751cd877c8c)

- [JPEG不可思议的压缩率——归功于信号处理理论 | 圆桌字幕组 | 哔哩哔哩](https://www.bilibili.com/video/BV1iv4y1N7sq/)
