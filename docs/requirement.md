# 实验要求

本实验的目的是实现一个 TCP 网络栈，单人完成。

实验分数由两部分组成，一部分是必选功能共 80 分，一部分是限选功能共 20 分。

各项功能见下表，其中打 `*` 号的为必选功能，其余为限选功能。同学们需要实现所有的必选功能，并在剩余的限选功能中选择若干功能使得这部分分数累计达到或超过 40 分。

部分自选功能依赖必选功能的实现。你可以放弃实现一部分必选功能，但扣除的必选部分分数不会由溢出的自选功能分数弥补。

评分方法：

1. 必选部分（80分）：`sum(scores)`
2. 自选部分（20分）：`min(sum(scores),20)`

在实验报告中，对于所实现的每个功能，请编写一个章节，包括下列事情：

1. 标注这是属于下面哪个类别里的哪一项功能
2. 为了实现这个功能，做了哪些代码改动
3. 可以展示功能的 Wireshark 截图展示或者命令行输出

在选择实现的自选功能的时候，请研究一下如何实现和触发该功能。有的功能可能容易实现，但是不容易触发。另外，请注意，部分功能由 lwip 支持，可以在 `lwipopts.h` 中打开；如果有不支持的功能，可能需要自己实现客户端+服务端，难度较大。为了展示实现的客户端功能，可以用自己的协议栈或者 lwip 作为服务端进行测试；同样地，为了展示实现的服务端功能，可以用自己的协议栈或者 lwip 作为客户端进行测试。

## 必选功能（总分 80 分）

### Step 1. TCP 序列号的对比与生成（sequence number comparison and generation）

- 实现序列号的对比函数（共四个），注意序列号在可能溢出时大小比较的特殊情况。
- 实现序列号的生成函数，序列号可以从目前的时间戳计算得到。
- 分数：10
- 参考文档：[RFC 793 Section 3.3](https://www.rfc-editor.org/rfc/rfc793.html#section-3.3) 和 [RFC 793 Page 27](https://www.rfc-editor.org/rfc/rfc793.html#page-27)
- 测试 1：给定一些例子，测试对比函数结果是否正确
- 测试 2：每隔一段时间生成一系列的序列号，这些序列号应该不重复

### Step 2. TCP 三次握手连接的建立（3-way handshake）

- 对于客户端，首先发送 SYN，进入 SYN_SENT 状态；接收到 SYN+ACK 时，发送 ACK 并进入 ESTABLISHED 状态。
- 对于服务端，在 LISTEN 状态时，如果接收到 SYN，新建一个 TCP socket，发送 SYN+ACK 并进入 SYN_RCVD 状态；接收到 ACK 时，进入 ESTABLISHED 状态。
- 分数：10
- 参考文档：[RFC 793 Figure 7](https://www.rfc-editor.org/rfc/rfc793.html#page-23) 和 [RFC 793 Section 3.4](https://www.rfc-editor.org/rfc/rfc793.html#section-3.4)
- 测试 3a：测试客户端逻辑，启动 lab-client 和 lwip-server，在输出日志中检查 TCP 状态机的转移
- 测试 3b：测试服务端逻辑，启动 lwip-client 和 lab-server，在输出日志中检查 TCP 状态机的转移

### Step 3. 简易的发送和接收逻辑（send & receive）

- 简易的发送和接收：不考虑丢包和乱序
- 发送：将用户调用 tcp_write 传入的数据写入缓冲区，综合 MSS、待发送的数据大小和对方窗口大小，发送数据
- 接收：将对方发送的正确数据写入缓冲区，当用户调用 tcp_read 时，从缓冲区复制数据到用户数组
- 分数：10
- 参考文档：[RFC 793 Page 56](https://www.rfc-editor.org/rfc/rfc793.html#page-56) 和 [RFC 793 Page 58](https://www.rfc-editor.org/rfc/rfc793.html#page-58)
- 测试 4a：测试客户端逻辑，启动 lab-client 和 lwip-server，在输出日志中检查是否正确完成了 HTTP 请求
- 测试 4b：测试服务端逻辑，启动 lwip-client 和 lab-server，在输出日志中检查是否正确完成了 HTTP 请求

### Step 4. TCP 连接的终止（connection termination）

- 实现 tcp_close 函数：发送 FIN
- 实现接收 FIN 的逻辑
- 分数：10
- 参考文档：[RFC 793 Page 60](https://www.rfc-editor.org/rfc/rfc793.html#page-60) 和 [RFC 793 Page 75](https://www.rfc-editor.org/rfc/rfc793.html#page-75)
- 需要通过测试 xx

### Step 5. 访问百度主页（visit baidu homepage）

- 如果前面四步实现得当，这一步应该直接可以通过
- 给做实验的你一个有成就感的阶段性成果
- 分数：10
- 测试 5：在本地运行 socat 命令，监听 80 端口并转发百度主页；然后运行 lab-client 并设置为 TUN 模式，那么 lab-client 会通过本机 80 端口访问百度主页 80 端口，并下载到本地

### Step 6. 重传和乱序重排（retransmission and out of order handling）

- 重传的实现思路是，对于发出去的 TCP 分组，记录在一个列表中，并且启动一个计时器，每一段时间检查一下列表中的 TCP 分组，如果发现有已经被对端 ACK 的，就删掉；否则就再次发送。
- 乱序重排的实现思路是，如果发现 TCP 分组的序列号不等于 RCV.NXT，此时出现了乱序，先把数据保存到列表中，当之后接受到序列号等于 RCV.NXT 的分组时，再将列表中已有的数据拼接起来，写入到接收缓冲区中。
- 分数：10
- 需要通过测试 xx

### Step 7. 实现 Nagle 算法（Nagle's algorithm）

- 分数：5
- 参考文档：[RFC 896](https://datatracker.ietf.org/doc/html/rfc896)
- 需要通过测试 xx

### Step 8. 实现慢启动，冲突避免和快速重传（slow start, congestion avoidance and fast retransmit/recovery）

- 添加 cwnd 变量，表示拥塞窗口大小。还需要定义 ssthresh，表示慢启动的阈值。
- cwnd 初始状态下设为 MSS 的一个倍数，在慢驱动阶段（cwnd < ssthresh），每次接收到 ACK，都会增加 cwnd。
- 当 cwnd > ssthresh 时，进入冲突避免阶段，此时采用新的方式增加 cwnd。
- 当发现重复的 ACK 时，采用快速重传算法，更新 cwnd 和 ssthresh。
- 分数：15
- 参考文档：[RFC 5681 Section 3.1](https://datatracker.ietf.org/doc/html/rfc5681#section-3.1) 和 [RFC 5681 Section 3.2](https://datatracker.ietf.org/doc/html/rfc5681#section-3.2)
- 需要通过测试 xx

## 限选功能（总分 20 分）

### 实现 TCP Window Scale Option

- 分数：5
- 参考文档：[RFC 7323 Section 2](https://datatracker.ietf.org/doc/html/rfc7323#section-2)

### 实现 TCP Timestamps Option

- 分数：5
- 参考文档：[RFC 7323 Section 3](https://datatracker.ietf.org/doc/html/rfc7323#section-3)

### 实现 TCP New Reno 拥塞控制算法

- 分数：20
- 参考文档：[RFC 6582](https://datatracker.ietf.org/doc/html/rfc6582)

### 实现 TCP CUBIC 拥塞控制算法

- 分数：20
- 参考文档：[RFC 8312](https://datatracker.ietf.org/doc/html/rfc8312)

### 实现 TCP BBR 拥塞控制算法

- 分数：20
- 参考文档：[RFC BBR draft](https://datatracker.ietf.org/doc/html/draft-cardwell-iccrg-bbr-congestion-control-01)

### 实现 SACK

- 由于 lwIP 不支持 SACK，此处需要用 TUN 模式进行测试。
- 分数：20
- 参考文档：[RFC 2018](https://datatracker.ietf.org/doc/html/rfc2018)
