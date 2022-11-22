# 基于DCT变换的图像编码

```matlab
% 测试
>> runtests

% 图像的编码与解码
>> main

% 编码过程中的一些细节
>> main_hack
```

```mermaid
flowchart LR
    Image --> Nlocks --> DCT

    subgraph Encoder
        DCT --> Quantizer --> entropy["Entropy Encoder"]
    end
    
    table(["Table Specifications"]) -.-> Quantizer
    table -.-> entropy

    entropy --> Compressed
```

```mermaid
flowchart LR
    Compressed --> entropy["Entropy Decoder"]

    subgraph Decoder
        entropy --> Dequantizer --> IDCT
    end
    
    table(["Table Specifications"]) -.-> Dequantizer
    table -.-> entropy

    IDCT --> Blocks --> Image
```

Entropy Encoder:

- AC: Run length Encoding.
- DC: Differential Pulse Code Modulation.

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
