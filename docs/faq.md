# FAQ

!!! question "RFC 793 中 TCP 状态机写得很复杂，我需要都实现吗？"

    不需要，其中一些比较关键的部分已经在代码框架中给出，对于一些可选功能，可能会实现更完整的状态机。我们的建议是，对于没有实现的代码，使用 `UNIMPLEMENTED` 宏表示尚未实现，那么代码在运行到此处的时候，就会显示错误，此时再去实现对应的处理即可，没有必要先把完整的 TCP 状态机翻译成代码，那样代码量太大，并且会很枯燥。

!!! question "Nagle 算法是什么呢？"

    简单来说，Nagle 算法要解决的是小包问题：如果用户 `write` 调用的数据都很小，并且每次 `write` 都要发送一个 TCP 包给对端，就会产生大量的 TCP 包。一个简单解决的思路是，如果 `write` 的数据太小，那就等一小段时间，期望用户在这个时间里继续写入一些数据，直到超时或者积攒到足够大的数据可以发送。由于超时实现比较麻烦（需要用到 Timer，引入了额外的状态，实现不方便），一个更优雅的方式是，当所有发送过的数据都已经 ACK 了（类似于拿 rtt 做超时，在更新 `snd_una` 的时候判断），此时没有 unACKed 的数据，就把缓存的数据都发送出去。详细介绍见 [RFC896](https://tools.ietf.org/html/rfc896) 和 [Wikipedia 页面](https://en.wikipedia.org/wiki/Nagle%27s_algorithm)。

!!! question "TCP Urgent 怎么实现？"

    其实不是同学们的问题，而是 RFC 793 写得并不清晰。在 [RFC 6093](https://tools.ietf.org/html/rfc6093) 中，作者提到了历史上对 TCP Urgent 不同的处理和带来的一系列问题，并最后建议应用程序不要用 TCP Urgent 功能，TCP 协议栈实现它也只是为了兼容一些已有的程序。虽然我们把它列入了一个可选功能中，但并不建议大家实现。

!!! question "在 WSL 中运行程序的时候，出现了 local datagram socket: Operation not supported 的报错，这是为什么呢？"

    WSL 的 `/mnt` 路径下是 mount 的 NTFS，不支持 unix domain socket，请换到 WSL 内部的路径（比如 home 目录）再尝试。

!!! question "make 的时候报错：Division works only with integers"

    meson 版本太老，请用 `pip3 install -U meson` 升级。

!!! question "make 的时候报错：meson: No such file or directory"

    首先检查 meson 是否安装了，并且可以在命令行中执行；如果安装了还是显示失败，可能是因为更新了 meson，导致它的路径变了，可以删除整个 `builddir` 目录再重新 `make`。

!!! question "设置了丢包以后，lwip 服务器一段时间没有收到 TCP 包就给客户端发送 FIN 了，能不能延长一下这个超时？"

    lwip 的 HTTPD 实现中，如果发现客户端一段时间（默认是 2s）都没有发送任何数据，就会终止连接。可以在 `lwipopt.h` 头文件中设置 `#define HTTPD_MAX_RETRIES 10`（默认值是 4），这样 HTTPD 会等待更长的时间。详细的设置可以阅读 lwip 的 `httpd_opts.h` 头文件。