# 实验要求

本实验的目的是实现一个 TCP 客户端的网络栈。必选功能里，只要求 TCP 客户端的实现，自选功能中可能包括 TCP 服务端的功能。

实验分数由两部分组成，一部分是必选功能共 60 分，一部分是自选功能共 40 分。

各项功能见下表，其中分值打 `*` 号的为必选功能，其余为自选功能。同学们需要实现所有的必选功能，并在剩余的自选功能中选择若干功能使得这部分分数累计达到或超过 40 分。

部分自选功能依赖必选功能的实现。你可以放弃实现一部分必选功能，但扣除的必选部分分数不会由溢出的自选功能分数弥补。

评分方法：

1. 必选部分（60分）：`sum(scores)`
2. 自选部分（40分）：`min(sum(scores), 40)`

在实验报告中，对于所实现的功能，请编写一个章节，包括下列事情：

1. 标注这是属于下面哪个类别里的哪一项功能
2. 为了实现这个功能，做了哪些代码改动
3. 可以展示功能的 Wireshark 截图展示或者命令行输出

在选择实现的自选功能的时候，请研究一下如何实现和触发该功能。有的功能可能容易实现，但是不容易触发。另外，请注意，部分功能由 lwip 支持，可以在 `lwipopts.h` 中打开；如果有不支持的功能，可能需要自己实现客户端+服务端，难度较大。

## 1. 连接建立

| 功能                                                         | 分值 | 引用              |
| ------------------------------------------------------------ | ---- | ----------------- |
| 1. basic 3-way handshake                                     | 5*   | RFC 793 Figure 7  |
| 2. tcp state machine                                         | 5*   | RFC 793 Figure 6  |
| 3. simultaneous connection synchronization                   | 2    | RFC 793 Figure 8  |
| 4. recovery from old duplicate syn                           | 2    | RFC 793 Figure 9  |
| 5. half-open connection discovery                            | 2    | RFC 793 Figure 10 |
| 6. active side causes half-open connection discovery         | 2    | RFC 793 Figure 11 |
| 7. old duplicate syn initiates a reset on two passive sockets | 2    | RFC 793 Figure 12 |

注：

1. 功能 2 指的是需要在代码中补全状态机的状态转移，转移的时候输出信息到标准输出
2. 功能 3-7 把情况构造出来可能比较麻烦

## 2. 序列号计算

| 功能                                 | 分值 | 引用                |
| ------------------------------------ | ---- | ------------------- |
| 1. sequence arithmetic (comparison)  | 1*   | RFC 793 Section 3.3 |
| 2. initial sequence number selection | 2*   | RFC 793 Page 27     |
| 3. send/receive sequence variables   | 2*   | RFC 793 Section 3.2 |

注：

1. 功能 1 和 2 在实验报告中只需要简单介绍一下代码实现。
2. 功能 3 需要在报告里介绍一下各个变量都代表什么，在什么情况下会更新。。
3. 功能 1 到 3 都不需要展示。

## 3. 连接终止

| 功能                                   | 分值 | 引用                                   |
| -------------------------------------- | ---- | -------------------------------------- |
| 1. local user initiates the close      | 3*   | RFC 793 Section 3.5 Case 1 & Figure 13 |
| 2. TCP receives a FIN from the network | 2*   | RFC 793 Section 3.5 Case 2             |
| 3. both users close simultaneously     | 2    | RFC 793 Section 3.5 Case 3 & Figure 14 |

注：

1. 功能 3 把情况构造出来可能比较麻烦

## 4. 数据传输

| 功能                                 | 分值 | 引用                |
| ------------------------------------ | ---- | ------------------- |
| 1. simple client SEND to server      | 10*  | RFC 793 Section 3.8 |
| 2. simple client RECEIVE from server | 10*  | RFC 793 Section 3.8 |
| 3. retransmission                    | 10   | RFC 793 Section 3.7 |
| 4. urgent                            | 3    | RFC 793 Section 3.7 |
| 5. out of order handling             | 5    |                     |

注：

1. simple 指的是不需要考虑丢包和乱序，故不需要重传，也不需要缓存并按照序列号顺序重新组装收到的 segment

## 5. 流量控制

| 功能                       | 分值 | 引用                |
| -------------------------- | ---- | ------------------- |
| 1. send and receive window | 10*  | RFC 793 Section 3.2 |
| 2. zero window report      | 5    | RFC 793 Page 42     |

## 6. 拥塞控制

| 功能                                   | 分值 | 引用                 |
| -------------------------------------- | ---- | -------------------- |
| 1. Nagle's algorithm                   | 10*  | RFC 896              |
| 2. slow start and congestion avoidance | 10   | RFC 5681 Section 3.1 |
| 3. fast transmit/fast recovery         | 10   | RFC 5681 Section 3.2 |
| 4. cubic                               | 20   | RFC 8312             |

## 其他

| 功能                             | 分值 | 引用               |
| -------------------------------- | ---- | ------------------ |
| 1. tcp selective acknowledgement | 20   | RFC 2018           |
| 2. tls over tcp                  | 10   | RFC 5246           |
| 3. window scaling                | 5    | RFC 7323 Section 2 |
| 4. timestamps                    | 5    | RFC 7323 Section 3 |
| 5. iperf client                  | 5    |                    |

注：

1. 不需要自己实现 TLS，请使用 OpenSSL 等库
2. iperf 的要求是在自己的网络栈基础上，编写 iperf 客户端链接 lwip 内置的 iperf 服务端
