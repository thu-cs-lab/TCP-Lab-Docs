# 实验流程

为了完成本实验的必选实验部分，只需要完成一个很简单的 TCP 协议栈：

1. 只需要支持客户端
2. 不考虑丢包
3. 不考虑乱序
4. 收到数据的时候立即发送 ACK
5. 用户调用 tcp_write 的时候立即发送数据到对端
6. 不考虑各种超时

[必选实验](/tcp/doc/requirement) 共有 11 项，建议按照如下顺序进行实现：

1. 实现 `2.1 sequence arithmetic`，也就是序列号的比较的四个函数。
2. 实现 `1.1 basic 3-way handshake` 和 `2.2 initial sequence number selection`，也就是在用户调用 `tcp_connect` 时候发送 `SYN`，当收到 `SYN+ACK` 的时候，再发送 `ACK`，不考虑附带数据。在判断收到的 `SYN+ACK` 是我们想要的序列号的时候，同时也实现了 `2.3 send/receive sequence variables` 的一部分。同时，也实现 `1.2 tcp state machine` 的一部分：从 CLOSED 转移到 SYN_SENT 再转移到 ESTABLISHED。
3. 实现 `4.1 simple client SEND to server`：把用户写入的数据放到 TCP 结构里的发送缓存，然后把尽量大的数据发出去（考虑 MSS、Send Window）。如果到这里实现正确，那么应该可以在服务端看到 HTTP 请求的信息。在发送的时候，为了知道此时的 Send Window 大小，需要记录对方发来的 TCP 头中的 window 大小；这就完成了 `5.1 send and receive window` 的第一部分。
4. 客户端发送数据给服务端后，服务端会给客户端发送数据；由于数据比较大，它会分成几个 segment 发送。为了让服务端知道客户端可以接收多少的数据，客户端需要在之前的 TCP 头中把自己的 Recv Window 发送给服务端，这就是 `5.1 send and receive window` 的第二部分。由于不考虑丢包和乱序，可以写的很简单：直接把收到的 segment 写入到 TCP 结构的接收缓存，并且更新 segment number 参数等等。当客户端读的时候，直接从接收缓存读出来即可。这就完成了 `4.2 simple client RECEIVE from server`。
5. 服务端发完数据以后，它会发 `FIN` 告诉客户端要终止连接，那么客户端就要发送 `ACK`，并且更新状态机。这就完成了 `3.2 TCP receives a FIN from the network`。
6. 最后还差 `3.1 local user initates the close` 功能，只需要同学修改一下客户端程序，让它调用 `tcp_shutdown`，相应的，协议栈也要发送 `FIN` 给对方，并处理对 `FIN` 的 `ACK`；还有 `6.1 slow start and congestion advoidance` 功能，留作同学们自行按照 RFC 和《计算机网络原理》课程的课件讲的方法去实现，不过，由于客户端和服务端之间的数据包较少，为了体现出明显的效果，请修改一下应用，并设置一下模拟出来的丢包率。

关于自选实验部分，就请同学们按照 RFC 自行发挥了，不再做过多提示。
