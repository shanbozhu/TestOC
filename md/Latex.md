---
html:
    embed_local_images: true
    embed_svg: true
    offline: true
    toc: true

print_background: true
---

<style>
    pre {
        word-wrap: break-word;
        white-space: pre-wrap !important;
        overflow-wrap: break-word;
    }
    code, tt {
        white-space: pre-wrap !important;
        word-break: break-all;
        overflow-wrap: break-word;
    }
</style>

<h1 style="text-align:center; font-family:Times New Roman; color:blue;">
    Markdown<span style="font-family:SimSun;">入门教程</span>
</h1>

<h2 style="text-align:center; font-family:Times New Roman; font-size:20pt;">
    shanbo
</h2>

[TOC]

### 3.10 LaTex公式

- 行内显示公式：
- 数学公式：$f(x)=ax+b$

- 化学公式：$\ce{Hg^2+ ->[I-] HgI2 ->[I-] [Hg^{II}I4]^2-}$

- 块内显示公式：
- 示例一

$$
\begin{Bmatrix}
a & b \\
c & d
\end{Bmatrix}
$$

- 示例二 泰勒展开

$$
f(x)=f(a)+f'(a)(x-a)+\tfrac{f''(a)}{2!}(x-a)^{2}+\cdots
$$

- 示例三 二元离散随机变量的信息熵

$$H(D_2) = -\left(\frac{2}{4}\log_2 \frac{2}{4} + \frac{2}{4}\log_2 \frac{2}{4}\right) = 1$$

- 示例四 矩阵

$$
\begin{pmatrix}
1 & a_1 & a_1^2 & \cdots & a_1^n \\
1 & a_2 & a_2^2 & \cdots & a_2^n \\
\vdots & \vdots & \vdots & \ddots & \vdots \\
1 & a_m & a_m^2 & \cdots & a_m^n \\
\end{pmatrix}
$$
