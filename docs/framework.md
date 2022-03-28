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

1. lwip: 基于 lwIP 编写的 TCP 客户端和服务端。
2. lab: 同学需要补全的 TCP 协议栈，也包括了一个简单的 HTTP 客户端和服务端。
3. test: 用于测试 TCP 协议栈的测试代码和脚本

同学们主要需要编写的就是 `lab` 目录下的代码。

## 客户端与服务端通信

在 `src/common.cpp` 中，提供了进程间通信的代码。在本次实验中，客户端和服务端分别运行在一个进程中，为了发送 IP 分组给对方，采用的是 unix socket 的方法。如果出现创建 unix socket 失败的错误，请检查文件系统是否支持。

编译后，会生成四个可执行程序：

- lab-client, lab-server：采用同学编写的 TCP 协议栈的客户端和服务端
- lwip-client, lwip-server：采用 lwIP 协议栈的客户端和服务端

## 如何运行程序

程序所使用的 unix socket 路径通过命令行参数给出，比如，如果用 `s` 表示服务端，`c` 表示客户端，那么应该这样编译并运行 `lwip-server`:

```shell
$ make && ./builddir/lwip-server -l s -r c -p lwip-server.pcap
```

这表示 `lwip-server` 的本地（监听）unix socket 是 `s`，远端（目的）unix socket 是 `c`，并且会把收发的 IP 分组写入到 `lwip-server.pcap` 文件里。

类似地，可以运行 `lwip-client`：

```shell
$ make && ./builddir/lwip-client -l c -r s -p lwip-client.pcap
```

注意要保持这里参数的 `-l` `-r` 应该和 `lwip-server` 的次序正好颠倒，这样就可以保证两个进程可以正常通信。同样地，它会把收发的 IP 分组写入到 `lwip-client.pcap` 文件里。

如果同时运行 `lwip-server` 和 `lwip-client` 并且路径正确，应该可以看到 HTTP 获取到的结果：

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

为了测试同学编写的协议栈作为客户端的功能，可以运行 lwip-server，再运行 lab-client 进行测试；如果要测试同学编写的协议栈作为服务端的功能，可以运行 lab-server，再运行 lwip-client 进行测试。最后，也可以自己与自己测试：运行 lab-server 和 lab-client。

## 模拟丢包

在代码 `common.h` 和 `common.cpp` 中，提供了伪随机模拟丢包的逻辑，可以通过命令行参数指定：

- -R 0.1: 表示设置接收时的丢包率
- -S 0.1: 表示设置发送时的丢包率

默认设置下为不丢包。你可以任意设置丢包的比例，然后观察协议栈是否还可以正常工作。

除了模拟丢包以外，还可以模拟乱序：比如在收发包的时候，先保存到缓冲区，然后按照一定的策略（定时+随机）选择缓冲区中的 IP 分组发出去。

## 如何调试

利用程序生成的 pcap 文件，可以用 wireshark 打开并查看各个 TCP segment 的信息以找到问题。

此外，也可以在代码中添加调试信息，也可以打开 lwIP 的更多调试信息，详见 [lwIP 库](/tcp/doc/lwip/)。

最后，别忘了可以用调试器来单步调试。

## 框架设计

框架代码是一个单线程并发的模式，有些类似 Node.JS，即不会进行阻塞的操作。如果进行的操作可能阻塞，注册一个回调函数，定期轮询是否可以继续。以 `lab-client.cpp` 的发送逻辑为例子：

```cpp
// write HTTP request line by line every 1s
const char *data[] = {
    "GET /index.html HTTP/1.1\r\n",
    "Accept: */*\r\n",
    "Host: 10.0.0.1\r\n",
    "Connection: Close\r\n",
    "\r\n",
};
int index = 0;
size_t offset = 0;
timer_fn write_fn = [&] {
  if (tcp_state(tcp_fd) == TCPState::CLOSED) {
    printf("Connection closed\n");
    return -1;
  }
  if (tcp_state(tcp_fd) != TCPState::ESTABLISHED) {
    printf("Waiting for connection establishment\n");
    return 1000;
  }

  const char *p = data[index];
  size_t len = strlen(p);
  ssize_t res = tcp_write(tcp_fd, (const uint8_t *)p + offset, len - offset);
  if (res > 0) {
    printf("Write '%s' to tcp\n", p);
    offset += res;

    // write completed
    if (offset == len) {
      index++;
      offset = 0;
    }
  }

  // next data
  if (index < 5) {
    return 100;
  } else {
    return -1;
  }
};
TIMERS.schedule_job(write_fn, 1000);
```

这段代码向计时器类 TIMER 注册了一个回调函数，然后这个函数内部有一个状态机，记录当前发送到哪一段数据的哪个偏移。如果发送不完全（比如因为 buffer 满等原因），就再注册一个回调函数，等下一次超时再尝试发送。

接受端也是类似的，只不过更复杂一些，在 `struct read_http_response` 中实现。它实现了一个状态机，保存了当前的状态（是否读入了 http header，读了多少 http body），并且不断尝试读取；类似地，如果发现 TCP 读取缓冲区为空，就注册一个回调函数（恰好也是结构体自己），等下一次超时再次尝试接收。

那么，上面的机制，很重要的一个基础设施就是计时器，在代码中就是 TIMERS 结构体。它维护了一个优先队列，根据事件发生时间从小到大排序。注册回调的时候，会往优先队列中插入一个新的事件。在 main 函数调用 `TIMERS.trigger` 函数的时候，它就会检查优先队列中，执行那些已经到了时间的事件。

TIMERS 的用法也很简单：

- `TIMERS.add_job(timer_fn fn, uint64_t ts_msec)`: 注册一个回调，会在 `ts_msec` 这个时间戳之后的时间内尽快被调用
- `TIMERS.schedule_job(timer_fn fn, uint64_t delay_msec)`: 注册一个回调，会在距离现在 `delay_msec` 毫秒之后不远的时间内尽快被调用

需要注意的是，在这种单线程并发的模式里，如果代码中写了死循环，TIMERS 也不会触发，因为代码不会进入 `TIMERS.trigger` 函数中。另外，事件的触发也是不准时的：如果之前的事件跑的时间太久，后面的事件可能很晚才能开始执行。同学们可以回忆一下《操作系统》课程中对调度器和实时性操作系统的讲解。和操作系统不同的是，这里没有时钟中断，无法打断正在执行的程序，只能程序主动交出执行权限（类似 coroutine/green thread，同学们可以回忆一下《操作系统》课程中讲的用户线程，内核线程和用户线程 N:M 的理论知识）。