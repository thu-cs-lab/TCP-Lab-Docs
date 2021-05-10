# 配置环境

该实验代码由 `git` 管理，构建软件需要 `meson` 和 `ninja`，还需要编译器 `gcc` 或者 `clang`，请用系统的包管理器进行安装。

以 Debian（Ubuntu） 为例，可以用 APT 安装依赖：

```shell
$ sudo apt install -y git meson ninja-build gcc g++
```

如果使用的是 Ubuntu 18.04、Debian 9 或更老的版本，请用 pip3 安装最新 meson：

```shell
$ pip3 install meson
```

因为官方 APT 源中 meson 的版本不够新。如果 meson 版本还是不对，检查一下运行的 meson 是否是 pip3 安装的 meson （比如 `~/.local/bin/meson`）。

## 支持的操作系统

实验框架保证支持下列的操作系统（发行版）：

1. Ubuntu 18.04 及更新
2. Debian 9 及更新
3. macOS High Sierra 及更新

在其他的一些环境（Windows w/o Visual Studio，WSL，OpenBSD 等）中代码可能也可以编译和运行，欢迎同学进行测试；但不保证可以正常工作和运行。
