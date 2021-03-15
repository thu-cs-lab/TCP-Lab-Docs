# 实验框架

实验框架代码在 [https://git.tsinghua.edu.cn/tcp-lab/tcp-lab](https://git.tsinghua.edu.cn/tcp-lab/tcp-lab) ，请同学克隆下来进行开发。

## 目录结构

目录结构大体如下：

1. include: 头文件目录
2. src: 源代码目录
3. thirdparty: 第三方库，目前只有 lwIP
4. Makefile: 用于 Make 命令构建
5. meson.build: 实际的构建描述文件

需要同学们修改的，主要是 `include` `src` 和 `meson.build`。一般不需要修改 lwIP 的源代码，关于如何配置 lwIP，请阅读 [lwIP 库](/tcp/doc/lwip/)。

在源代码目录 `src` 下，又有三个子目录：

1. client: 一个已经编写好的基于 lwIP 的 TCP 客户端，它会进行一次 HTTP GET 请求。
2. server: 一个已经编写好的基于 lwIP 的 TCP 服务端，它上面运行了一个 HTTP 服务器。
3. lab: 同学需要补全的 TCP 协议栈，也包括了一个简单的 HTTP 客户端，进行 HTTP GET 请求。

同学们主要需要编写的就是 `lab` 目录下的代码。在部分功能里，可能需要对 server 添加功能，请参考 lwIP 文档进行添加或者寻求助教协助。

## 客户端与服务端通信

在 `src/common.cpp` 中，提供了进程间通信的代码。在本次实验中，客户端和服务端分别运行在一个进程中，为了发送 IP 分组给对方，采用的是 unix socket 的方法。如果出现创建 unix socket 失败的错误，请检查文件系统是否支持。

## 如何运行程序

程序所使用的 unix socket 路径通过命令行参数给出，比如，如果用 `s` 表示服务端，`c` 表示客户端，那么应该这样编译并运行 `server`:

```shell
$ make && ./builddir/server -l s -r c -p server.pcap
```

这表示 `server` 的本地（监听）unix socket 是 `s`，远端（目的）unix socket 是 `c`，并且会把收发的 IP 分组写入到 `server.pcap` 文件里。

类似地，可以运行 `client`：

```shell
$ make && ./builddir/client -l c -r s -p client.pcap
```

注意要保持这里参数的 `-l` `-r` 应该和 `server` 的次序正好颠倒，这样就可以保证两个进程可以正常通信。同样地，它会把收发的 IP 分组写入到 `client.pcap` 文件里。

如果同时运行 `server` 和 `client` 并且路径正确，应该可以看到 HTTP 获取到的结果：

```text
tcp_recved: received 130 bytes, wnd 1738 (406).
HTTP Got Body:
<html>
<head><title>lwIP - A Lightweight TCP/IP Stack</title></head>
<body bgcolor="white" text="black">

    <table width="100%">
      <tr valign="top"><td width="80">
          <a href="http://www.sics.se/"><img src="/img/sics.gif"
          border="0" alt="SICS logo" title="SICS logo"></a>
        </td><td width="500">
          <h1>lwIP - A Lightweight TCP/IP Stack</h1>
          <p>
            The web page you are watchitcp_output: nothing to send (0x0)
RX: 45 00 02 40 00 02 00 00 FF 06 A5 B3 0A 00 00 01 0A 00 00 02 00 50 C0 01 00 00 1B 87 00 00 19 FD 50 18 07 D1 35 FA 00 00 6E 67 20 77 61 73 20 73 65 72 76 65 64 20 62 79 20 61 20 73 69 6D 70 6C 65 20 77 65 62 0D 0A 09 20 20 20 20 73 65 72 76 65 72 20 72 75 6E 6E 69 6E 67 20 6F 6E 20 74 6F 70 20 6F 66 20 74 68 65 20 6C 69 67 68 74 77 65 69 67 68 74 20 54 43 50 2F 49 50 20 73 74 61 63 6B 20 3C 61 0D 0A 09 20 20 20 20 68 72 65 66 3D 22 68 74 74 70 3A 2F 2F 77 77 77 2E 73 69 63 73 2E 73 65 2F 7E 61 64 61 6D 2F 6C 77 69 70 2F 22 3E 6C 77 49 50 3C 2F 61 3E 2E 0D 0A 09 20 20 3C 2F 70 3E 0D 0A 09 20 20 3C 70 3E 0D 0A 09 20 20 20 20 6C 77 49 50 20 69 73 20 61 6E 20 6F 70 65 6E 20 73 6F 75 72 63 65 20 69 6D 70 6C 65 6D 65 6E 74 61 74 69 6F 6E 20 6F 66 20 74 68 65 20 54 43 50 2F 49 50 0D 0A 09 20 20 20 20 70 72 6F 74 6F 63 6F 6C 20 73 75 69 74 65 20 74 68 61 74 20 77 61 73 20 6F 72 69 67 69 6E 61 6C 6C 79 20 77 72 69 74 74 65 6E 20 62 79 20 3C 61 0D 0A 09 20 20 20 20 68 72 65 66 3D 22 68 74 74 70 3A 2F 2F 77 77 77 2E 73 69 63 73 2E 73 65 2F 7E 61 64 61 6D 2F 6C 77 69 70 2F 22 3E 41 64 61 6D 20 44 75 6E 6B 65 6C 73 0D 0A 09 20 20 20 20 6F 66 20 74 68 65 20 53 77 65 64 69 73 68 20 49 6E 73 74 69 74 75 74 65 20 6F 66 20 43 6F 6D 70 75 74 65 72 20 53 63 69 65 6E 63 65 3C 2F 61 3E 20 62 75 74 20 6E 6F 77 20 69 73 0D 0A 09 20 20 20 20 62 65 69 6E 67 20 61 63 74 69 76 65 6C 79 20 64 65 76 65 6C 6F 70 65 64 20 62 79 20 61 20 74 65 61 6D 20 6F 66 20 64 65 76 65 6C 6F 70 65 72 73 0D 0A 09 20 20 20 20 64 69 73 74 72 69 62 75 74 65 64 20 77 6F 72 6C 64 2D 77 69 64 65 2E 20 53 69 6E 63 65 20 69 74 27 73 20 72 65 6C 65 61 73 65 2C 20 6C 77 49 50 20 68 61 73 0D 0A 09 20 20 20 20 73 70 75 72 72 65 64 20 61 20 6C 6F 74 20 6F 66
tcp_receive: window update 2001
HTTP Got Body:
ng was served by a simple web
            server running on top of the lightweight TCP/IP stack <a
            href="http://www.sics.se/~adam/lwip/">lwIP</a>.
          </p>
          <p>
            lwIP is an open source implementation of the TCP/IP
            protocol suite that was originally written by <a
            href="http://www.sics.se/~adam/lwip/">Adam Dunkels
            of the Swedish Institute of Computer Science</a> but now is
            being actively developed by a team of developers
            distributed world-wide. Since it's release, lwIP has
            spurred a lot oftcp_output: nothing to send (0x0)
tcp_output: sending ACK for 7583
TX: 45 00 00 28 00 02 00 00 FF 06 A7 CB 0A 00 00 02 0A 00 00 01 C0 01 00 50 00 00 19 FD 00 00 1D 9F 50 10 04 30 9F B4 00 00
RX: 45 00 02 40 00 03 00 00 FF 06 A5 B2 0A 00 00 01 0A 00 00 02 00 50 C0 01 00 00 1D 9F 00 00 19 FD 50 10 07 D1 AF 50 00 00 20 69 6E 74 65 72 65 73 74 20 61 6E 64 20 68 61 73 20 62 65 65 6E 20 70 6F 72 74 65 64 20 74 6F 20 73 65 76 65 72 61 6C 0D 0A 09 20 20 20 20 70 6C 61 74 66 6F 72 6D 73 20 61 6E 64 20 6F 70 65 72 61 74 69 6E 67 20 73 79 73 74 65 6D 73 2E 20 6C 77 49 50 20 63 61 6E 20 62 65 20 75 73 65 64 20 65 69 74 68 65 72 0D 0A 09 20 20 20 20 77 69 74 68 20 6F 72 20 77 69 74 68 6F 75 74 20 61 6E 20 75 6E 64 65 72 6C 79 69 6E 67 20 4F 53 2E 0D 0A 09 20 20 3C 2F 70 3E 0D 0A 09 20 20 3C 70 3E 0D 0A 09 20 20 20 20 54 68 65 20 66 6F 63 75 73 20 6F 66 20 74 68 65 20 6C 77 49 50 20 54 43 50 2F 49 50 20 69 6D 70 6C 65 6D 65 6E 74 61 74 69 6F 6E 20 69 73 20 74 6F 20 72 65 64 75 63 65 0D 0A 09 20 20 20 20 74 68 65 20 52 41 4D 20 75 73 61 67 65 20 77 68 69 6C 65 20 73 74 69 6C 6C 20 68 61 76 69 6E 67 20 61 20 66 75 6C 6C 20 73 63 61 6C 65 20 54 43 50 2E 20 54 68 69 73 0D 0A 09 20 20 20 20 6D 61 6B 65 73 20 6C 77 49 50 20 73 75 69 74 61 62 6C 65 20 66 6F 72 20 75 73 65 20 69 6E 20 65 6D 62 65 64 64 65 64 20 73 79 73 74 65 6D 73 20 77 69 74 68 20 74 65 6E 73 0D 0A 09 20 20 20 20 6F 66 20 6B 69 6C 6F 62 79 74 65 73 20 6F 66 20 66 72 65 65 20 52 41 4D 20 61 6E 64 20 72 6F 6F 6D 20 66 6F 72 20 61 72 6F 75 6E 64 20 34 30 20 6B 69 6C 6F 62 79 74 65 73 0D 0A 09 20 20 20 20 6F 66 20 63 6F 64 65 20 52 4F 4D 2E 0D 0A 09 20 20 3C 2F 70 3E 0D 0A 09 20 20 3C 70 3E 0D 0A 09 20 20 20 20 4D 6F 72 65 20 69 6E 66 6F 72 6D 61 74 69 6F 6E 20 61 62 6F 75 74 20 6C 77 49 50 20 63 61 6E 20 62 65 20 66 6F 75 6E 64 20 61 74 20 74 68 65 20 6C 77 49 50 0D 0A 09 20 20 20 20 68 6F 6D 65 70 61 67 65 20 61 74 20 3C 61 0D 0A 09 20 20 20 20
tcp_receive: window update 2001
HTTP Got Body:
 interest and has been ported to several
            platforms and operating systems. lwIP can be used either
            with or without an underlying OS.
          </p>
          <p>
            The focus of the lwIP TCP/IP implementation is to reduce
            the RAM usage while still having a full scale TCP. This
            makes lwIP suitable for use in embedded systems with tens
            of kilobytes of free RAM and room for around 40 kilobytes
            of code ROM.
          </p>
          <p>
            More information about lwIP can be found at the lwIP
            homepage at <a
            tcp_output: nothing to send (0x0)
RX: 45 00 01 39 00 04 00 00 FF 06 A6 B8 0A 00 00 01 0A 00 00 02 00 50 C0 01 00 00 1F B7 00 00 19 FD 50 19 07 D1 0D C0 00 00 68 72 65 66 3D 22 68 74 74 70 3A 2F 2F 73 61 76 61 6E 6E 61 68 2E 6E 6F 6E 67 6E 75 2E 6F 72 67 2F 70 72 6F 6A 65 63 74 73 2F 6C 77 69 70 2F 22 3E 68 74 74 70 3A 2F 2F 73 61 76 61 6E 6E 61 68 2E 6E 6F 6E 67 6E 75 2E 6F 72 67 2F 70 72 6F 6A 65 63 74 73 2F 6C 77 69 70 2F 3C 2F 61 3E 0D 0A 09 20 20 20 20 6F 72 20 61 74 20 74 68 65 20 6C 77 49 50 20 77 69 6B 69 20 61 74 20 3C 61 0D 0A 09 20 20 20 20 68 72 65 66 3D 22 68 74 74 70 3A 2F 2F 6C 77 69 70 2E 77 69 6B 69 61 2E 63 6F 6D 2F 22 3E 68 74 74 70 3A 2F 2F 6C 77 69 70 2E 77 69 6B 69 61 2E 63 6F 6D 2F 3C 2F 61 3E 2E 0D 0A 09 20 20 3C 2F 70 3E 0D 0A 09 3C 2F 74 64 3E 3C 74 64 3E 0D 0A 09 20 20 26 6E 62 73 70 3B 0D 0A 09 3C 2F 74 64 3E 3C 2F 74 72 3E 0D 0A 20 20 20 20 20 20 3C 2F 74 61 62 6C 65 3E 0D 0A 3C 2F 62 6F 64 79 3E 0D 0A 3C 2F 68 74 6D 6C 3E 0D 0A 0D 0A
tcp_receive: window update 2001
HTTP Got Body:
href="http://savannah.nongnu.org/projects/lwip/">http://savannah.nongnu.org/projects/lwip/</a>
            or at the lwIP wiki at <a
            href="http://lwip.wikia.com/">http://lwip.wikia.com/</a>.
          </p>
        </td><td>
          &nbsp;
        </td></tr>
      </table>
</body>
</html>

HTTP Result: 0
```

接下来，用类似的方法运行同学编写的实验程序 `lab-client`：

```shell
$ make && ./builddir/lab-client -l c -r s -p lab-client.pcap
```

如果工作正常，应该也可以看到类似上面的输出。

## 模拟丢包

在代码 `common.h` 和 `common.cpp` 中，提供了伪随机模拟丢包的逻辑，通过全局变量修改：

- recv_drop_{numerator, denomiator}：收包时的丢包率（分子/分母）
- send_drop_{numerator, denomiator}：收包时的丢包率（分子/分母）

默认设置下为不丢包。你可以任意设置丢包的比例，然后观察协议栈是否还可以正常工作。

除了模拟丢包以外，还可以模拟乱序：比如在收发包的时候，先保存到缓冲区，然后按照一定的策略（定时+随机）选择缓冲区中的 IP 分组发出去。同学在完成相关功能的时候，也请自行实现乱序的模拟。

## 如何调试

利用程序生成的 pcap 文件，可以用 wireshark 打开并查看各个 TCP segment 的信息以找到问题。

此外，也可以在代码中添加调试信息，也可以打开 lwIP 的更多调试信息，详见 [lwIP 库](/tcp/doc/lwip/)。

最后，别忘了可以用调试器来单步调试。
