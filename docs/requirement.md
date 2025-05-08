# 实验要求

本实验的目的是实现一个 TCP 网络栈，单人完成。

实验分数由两部分组成，一部分是必选功能共 60 分，一部分是限选功能共 40 分。

各项功能见下表，其中打 `*` 号的为必选功能，其余为限选功能。同学们需要实现所有的必选功能，并在剩余的限选功能中选择若干个功能使得这部分分数累计达到或超过 40 分。

部分自选功能依赖必选功能的实现。你可以放弃实现一部分必选功能，但扣除的必选部分分数不会由溢出的自选功能分数弥补。

评分方法：

1. 必选部分（60 分）：`sum(scores)`
2. 自选部分（40 分）：`min(sum(scores),40)`

在实验报告中，对于所实现的每个功能，请编写一个章节，包括下列内容：

1. 标注这是属于下面哪个类别里的哪一项功能
2. 为了实现这个功能，做了哪些代码改动
3. 可以展示功能的 Wireshark 截图展示或者命令行输出

在选择实现的自选功能的时候，请研究一下如何实现和触发该功能。有的功能可能容易实现，但是不容易触发。另外，请注意，部分功能由 lwip 支持，可以在 `lwipopts.h` 中打开；如果有不支持的功能，可能需要自己实现客户端 + 服务端，难度较大。为了展示实现的客户端功能，可以用自己的协议栈或者 lwip 作为服务端进行测试；同样地，为了展示实现的服务端功能，可以用自己的协议栈或者 lwip 作为客户端进行测试。

框架里为各项任务提供了自动化的测例，可以通过 `make test` 命令调用。你也可以适当修改 `src/test` 下的测例，以便于更好地展示你的实验结果，但是修改之处请在最终提交的`实验报告`中注明。

主要参考文档：

- [RFC 793](https://www.rfc-editor.org/rfc/rfc793.html) 和 [RFC 793 勘误](https://www.rfc-editor.org/errata/rfc0793)
- [RFC 1122 Section 4.2 TCP](https://www.rfc-editor.org/rfc/rfc1122#page-82)

教学目的：

1. 本实验从简易到困难，逐步完善一个 TCP 协议栈的功能，可以让同学理解 TCP 协议设计上的一些思路，并在写代码的过程中理解从设计到实现的区别，并考虑实现上的一些细节。
2. 锻炼同学对于 RFC 全英文文档的阅读能力，这个能力对于未来的学习和研究是很有必要的，因此在本文档中，不会很细致地用中文把要实现的内容复述一遍，目的是让同学去阅读 RFC 文档进行自学。如果实在不想自学，或者因为时间问题，可以在网上搜索中文博客，但这样做也缺少了一次很重要的锻炼机会。相比论文，RFC 的文字比较详细和朴实，是比较好的英文技术类阅读资料。
3. 希望同学在未来参加公司面试等场合，被问到 TCP 三次握手的时候，可以自信地说：我做过 TCP 实验，你问的这些，我都写过，我都会。
4. 希望同学可以从 TCP 协议解决问题的过程中，学习一些设计思路，并借鉴到自己所研究的领域当中。

??? question "我英语水平不够怎么办？"

	??? question "看到大段英文我就头晕怎么办？"

		??? question "我真的没法读 RFC，助教你饶了我吧！"

			那助教推荐一个中文 TCP 教程：[小林 x 图解计算机基础](https://xiaolincoding.com/network/3_tcp/tcp_feature.html)

## 必选功能（总分 60 分）
### Step 1. TCP 序列号的对比与生成（sequence number comparison and generation）

- 实现序列号的对比函数（共四个），注意序列号在可能溢出时大小比较的特殊情况。
- 实现序列号的生成函数，序列号可以从目前的时间戳计算得到。
- 分数：5
- 参考文档：[RFC 793 Section 3.3](https://www.rfc-editor.org/rfc/rfc793.html#section-3.3) 和 [RFC 793 Page 27](https://www.rfc-editor.org/rfc/rfc793.html#page-27)
- 测试 1：给定一些例子，测试对比函数结果是否正确
- 测试 2：每隔一段时间生成一系列的序列号，这些序列号应该不重复
- 代码量：~10 行
- 教学目的：了解序列号的大小关系，如何在整数溢出的情况下，实现保证相对顺序的比较
- 验收要求：通过自动化测试

### Step 2. TCP 三次握手连接的建立（3-way handshake）

- 对于客户端，首先发送 SYN，进入 SYN_SENT 状态；接收到 SYN+ACK 时，发送 ACK 并进入 ESTABLISHED 状态。
- 对于服务端，在 LISTEN 状态时，如果接收到 SYN，新建一个 TCP socket，发送 SYN+ACK 并进入 SYN_RCVD 状态；接收到 ACK 时，进入 ESTABLISHED 状态。
- 分数：10
- 参考文档：[RFC 793 Figure 7](https://www.rfc-editor.org/rfc/rfc793.html#page-23) 和 [RFC 793 Section 3.4](https://www.rfc-editor.org/rfc/rfc793.html#section-3.4)
- 测试 3a：测试客户端逻辑，启动 lab-client 和 lwip-server，在输出日志中检查 TCP 状态机的转移
- 测试 3b：测试服务端逻辑，启动 lwip-client 和 lab-server，在输出日志中检查 TCP 状态机的转移
- 代码量：~50 行
- 教学目的：学习 TCP 建立连接的三次握手过程，初步接触框架中发送 TCP 分组的方法和 TCP 状态机的实现，强化 SYN 占用序列号的记忆
- 验收要求：通过自动化测试

### Step 3. 简易的发送和接收逻辑（send & receive）

- 简易的发送和接收：不考虑丢包和乱序
- 发送：将用户调用 tcp_write 传入的数据写入缓冲区，综合 MSS、待发送的数据大小和对方窗口大小，发送数据
- 接收：将对方发送的数据写入缓冲区，当用户调用 tcp_read 时，从缓冲区复制数据到用户数组
- 分数：5
- 参考文档：[RFC 793 Page 56](https://www.rfc-editor.org/rfc/rfc793.html#page-56) 和 [RFC 793 Page 58](https://www.rfc-editor.org/rfc/rfc793.html#page-58) 和 [RFC 793 Send Sequence Space](https://www.rfc-editor.org/rfc/rfc793.html#page-20)
- 测试 4a：测试客户端逻辑，启动 lab-client 和 lwip-server，在输出日志中检查是否正确完成了 HTTP 请求
- 测试 4b：测试服务端逻辑，启动 lwip-client 和 lab-server，在输出日志中检查是否正确完成了 HTTP 请求
- 代码量：~50 行
- 注意：代码中的`TODO`只是提示这些地方需要添加代码，但是`TODO`之外也有一些地方根据 TCP 协议的标准来需要补充实现
- 注意：如果完成了 Step 3，但还没完成 Step 4，且本测试无法通过，请尝试把 TODO(step4) 的`UNIMPLEMENTED`注释掉再运行测试
- 教学目的：理解 TCP 栈与用户程序交互的方式，TCP 栈内发送缓存和接收缓存的意义，如何维护发送和接收的序列号空间（即 `SND.UNA`，`SND.NXT`，`SND.WND`，`RCV.NXT` 和 `RCV.WND`）
- 验收要求：通过自动化测试

### Step 4. TCP 连接的终止（connection termination）

- 实现 tcp_close 函数：发送 FIN
- 实现接收 FIN 的逻辑
- 分数：10
- 参考文档：[RFC 793 Page 60](https://www.rfc-editor.org/rfc/rfc793.html#page-60) 和 [RFC 793 Page 75](https://www.rfc-editor.org/rfc/rfc793.html#page-75)
- 测试 5a：测试客户端逻辑，启动 lab-client 和 lwip-server，在输出日志中检查是否出现了正确的状态机转移
- 测试 5b：测试服务端逻辑，启动 lwip-client 和 lab-server，在输出日志中检查是否出现了正确的状态机转移
- 教学目的：理解 TCP 连接终止的四次挥手过程，强化 FIN 占用序列号的记忆
- 验收要求：通过自动化测试

### Step 5. 访问百度主页（visit baidu homepage）

- 如果前面四步实现得当，这一步应该直接可以通过
- 给做实验的你一个有成就感的阶段性成果
- 分数：5
- 测试 6：在本地运行 socat 命令（命令：`sudo socat TCP-LISTEN:80,reuseaddr,fork TCP:www.baidu.com:80`），监听 80 端口并转发百度主页；然后运行 lab-client 并设置为 TUN 模式（命令：`make run-lab-client-tun`），那么 lab-client 会通过本机 80 端口访问百度主页 80 端口，并下载到本地
- 注意：部分发行版可能没有自带 socat命令， 需要额外安装 socat 软件包
- 注意：在关闭连接的过程中，当百度的服务器处于`FIN_WAIT_2`状态时，它只能接受`ACK=1, FIN=1`的包，而不会接受`ACK=0, FIN=1`的包，收到`ACK=0, FIN=1`的包时，服务器既不会返回`ACK`，也不会进入`TIME_WAIT`状态。如果你的实现里只能发送`ACK=0, FIN=1`的包，那么你的客户端可能会卡在`LAST_ACK`状态，无法进入`CLOSE`状态。（cr. 尤梓锐）
- 注意：如果采用虚拟机环境，发现无法访问百度，但是前面的 step 均正常，请尝试关闭防火墙（cr. 王楚怡）
- 教学目的：了解一个最小的 TCP 实现所需要的功能，并获得阶段性的成就
- 验收要求：通过自动化测试，并展示下载的百度网页

### Step 6. 重传和乱序重排（retransmission and out of order handling）

- 重传的实现思路是，对于发出去的 TCP 分组，记录在一个列表中，并且启动一个计时器，每一段时间检查一下列表中的 TCP 分组，如果发现有已经被对端 ACK 的，就删掉；否则就再次发送。
- 乱序重排的实现思路是，如果发现 TCP 分组的序列号不等于 RCV.NXT，此时出现了乱序，先把数据保存到列表中，当之后接受到序列号等于 RCV.NXT 的分组时，再将列表中已有的数据拼接起来，写入到接收缓冲区中。
- 分数：10
- 测试 7a：启动 lwip-client 和 lab-server，模拟接收端的丢包，在输出日志中检查是否出现了正确的状态机转移
- 测试 7b：启动 lab-client 和 lab-server，lab-server模拟 HTTP response 的延迟、乱序发送，在输出日志中检查是否出现了正确的状态机转移
- 测例的具体实现机理可以参见源代码。欢迎对这两个测例进行改进，通过其他方式来展现重传和乱序重排的效果
- 注意：有同学反映，有一定概率出现 HTTP response 不完整的情况。经分析可能是 `src/lab/lab-client.cpp` 中 95 行对 `close_and_exit` 函数的执行时间安排得太紧。现在已经做出了修改（cr. 郑皓之）
- 注意：在处理对面回应的 ACK 包时，不仅要排出重传队列中对应的包，也要排出 SendRingBuffer 中对应的包，否则会导致 SendRingBuffer 溢出
- 教学目的：理解在网络中出现丢包或者乱序的时候，如何在协议上保持不重不漏、顺序正确地实现数据传输
- 验收要求：通过抓包、日志等方式展示重传和重排，展示场景可以参考自动化测试脚本

### Step 7. 实现 Nagle 算法（Nagle's algorithm）

- 分数：5
- 参考文档：[RFC 896](https://datatracker.ietf.org/doc/html/rfc896)
- 测试 8a：启动 lwip-client 和 lab-server，启用 Nagle 算法，在输出日志中检查是否出现了正确的状态机转移
- 测试 8b：启动 lwip-client 和 lab-server，禁用 Nagle 算法，在输出日志中检查是否出现了正确的状态机转移
- lab-server 以每次发送 13 字节的 `Hello World!\n` 的方式，向客户端返回共计 1300 字节的 Content ，共调用 `tcp_write` 100 余次，产生较多的小数据包
- 请比较开启 Nagle 算法与关闭 Nagle 算法时，TCP 连接的传输效率
- 注意：编译时，我们用 `ENABLE_NAGLE` 这个宏来区分 Nagle 算法是否启用。如果存在 `ENABLE_NAGLE` 这个宏，你的 TCP 实现就应该启用 Nagle 算法
- 教学目的：学习并实现一个经典的 TCP 上的优化
- 验收要求：展示开启 Nagle 算法时 TCP 连接的传输效率相比关闭 Nagle 算法时有所提高，展示场景可以参考自动化测试脚本

### Step 8. 实现慢启动，冲突避免，快速重传和快速恢复（slow start, congestion avoidance and fast retransmit/recovery）

- 添加 cwnd 变量，表示拥塞窗口大小。还需要定义 ssthresh，表示慢启动的阈值。
- cwnd 初始状态下设为 MSS 的一个倍数，在慢驱动阶段（cwnd < ssthresh），每次接收到 ACK，都会增加 cwnd。
- 当 cwnd > ssthresh 时，进入冲突避免阶段，此时采用新的方式增加 cwnd。
- 当发现重复的 ACK 时，采用快速重传算法，更新 cwnd 和 ssthresh。
- 分数：10
- 参考文档：[RFC 5681 Section 3.1](https://datatracker.ietf.org/doc/html/rfc5681#section-3.1) 和 [RFC 5681 Section 3.2](https://datatracker.ietf.org/doc/html/rfc5681#section-3.2)
- 测试 9a：启动 lwip-client 和 lab-server，在输出日志中检查是否出现了正确的状态机转移
- 测试 9b：启动 lwip-client 和 lab-server，在输出日志中检查是否出现了正确的状态机转移
- 在测试中在模拟的网络层中实现一个类似漏桶算法的限速方法，当客户端平均接收带宽超过 10KiB/s 时，通过丢包（在客户端接收时丢弃）模拟网络拥塞
- 测试 9a 模拟极端的网络拥塞情况，带宽超过上限时，丢弃所有到达的包；测试 9b 模拟偶然的网络拥塞情况，带宽超过上限时，以一定概率丢弃到达的包
- 请比较测试 9a 和 9b 下，TCP 连接的传输效率
- 注：为了便于显示拥塞控制算法的效果，你可以修改 MTU 以便观察
- 教学目的：学习并实现经典的拥塞控制协议，并理解 TCP 协议栈是如何通过丢包和重复的 ACK 来判断链路上是否拥挤的，拥挤时要如何让出带宽来缓解网络的拥挤程度
- 验收要求：通过抓包、日志等方式展示慢启动和冲突避免阶段 cwnd 的变化模式，以及在丢包发生后算法的行为，展示场景可以参考自动化测试脚本

## 限选功能（总分 40 分）

### Feature 1. 实现 TCP BBR 拥塞控制算法

- 分数：40
- 参考文档：[RFC BBR draft](https://datatracker.ietf.org/doc/html/draft-cardwell-iccrg-bbr-congestion-control-00)
- 由于 lwIP 的一些实现细节，不建议在本部分实验中使用 lwIP 库，客户端和服务器都使用本实验实现的程序即可
- 教学目的：学习并实现一个较为复杂和现代的拥塞控制算法
- 验收要求：能介绍 TCP BBR 拥塞控制算法的核心思想

#### Step 1. 实现 pacing 功能

- 分数：5
- BBR 算法中使用了 pacing 功能，通过控制发送时间间隔的方式控制发送速率。
- 在这一步中，你很可能需要使用定时器。你可以在“实验框架”一节中获得一些提示。
- 完成这一步后，你应能使发送端按照给定速率发送。
- 验收要求：能通过控制 pacing 速率，使相同流以不同时间完成传输。

#### Step 2. 构建 rate sample

- 分数：10
- 参考文档：[RFC Delivery Rate Estimation draft](https://datatracker.ietf.org/doc/html/draft-cheng-iccrg-delivery-rate-estimation)
- BBR 算法中需要根据收到的 ACK 还原网络情况。因此，需要针对每一个 ACK 都构建一个 rate sample，并将其作为参数传入拥塞控制算法对于 ACK 的响应函数中。
- rate sample 中应当至少包含如下信息：RTT、delivery rate。
- 为了构建 rate sample，可能需要维护一些额外的数据结构。
- 完成这一步后，你应能在收到每一个 ACK 后输出一组统计信息。
- 验收要求：能展示收到每个 ACK 后的统计信息；展示的 RTT 与配置的链路延迟相匹配；展示的 delivery rate 与 pacing rate 设置的速率相匹配

#### Step 3. 实现 BBR 算法

- 分数：25
- 你已经完成了必要的准备工作。现在，将 BBR 算法实现出来吧！
- 提示：BBR 算法同时使用 cwnd 和 pacing rate 来控制发送，你只需理解在算法的几个状态以及核心状态的探测循环中 cwnd 和 pacing rate 应当如何设置，并正确计算和设置即可。
- 验收要求：能展示 BBR 算法的工作循环；能展示 BBR 算法在遇到丢包时的行为。如果能展示出比必选功能 Step 8 更高的带宽和更低的延迟就更好了。
- 验收提示：可以参考必选功能 Step 8 的自动化测试脚本模拟网络环境；推荐使用统计量随时间变化的图表来展示 BBR 的行为。

### Feature 2. 实现 SACK

- 由于 lwIP 不支持 SACK，此处需要用 TUN 模式进行测试。
- 分数：20
- 参考文档：[RFC 2018](https://datatracker.ietf.org/doc/html/rfc2018) [RFC 2018 勘误](https://www.rfc-editor.org/errata_search.php?rfc=2018&rec_status=0)
- 教学目的：学习并实现一个比较复杂一些的 TCP Option，理解如何通过添加简单的数据结构和扩展的方式来解决原有协议的不足
- 验收要求：能展示一个发出 SACK 的场景，并展示发出的 SACK 包；展示 SACK 接收方利用 SACK 实现的功能，通过对比不使用 SACK 的行为展示 SACK 的作用

!!! tip "BBRv2"

	目前 BBR 已经经过改进发布了 BBRv2 版本（[BBR draft](https://datatracker.ietf.org/doc/html/draft-cardwell-iccrg-bbr-congestion-control-02)），这个版本为 BBR 添加了
	对丢包的响应，使得 BBR 能和其他基于丢包的算法共存，且稳定性有所提升。如果有 SACK 支持，BBRv2 能更精准地处理丢包事件。如果你对 BBR 和 SACK 都很感兴趣，不妨在实现 SACK 后继续实现
	BBRv2，进一步挑战自己。如果你只计划实现 BBR，也不妨了解一下 BBRv2 进行了怎样的改进。