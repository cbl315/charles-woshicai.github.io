---
slug: Concurrency In Go
title: Concurrency In Go
author: woshicai
author_title: woshicai
author_image_url: https://avatars.githubusercontent.com/charles-woshicai
tags: [go]
---

# Concurrency In Go

After reading the book `Concurrency In Go`, in order to better understand and remember what the book says, record key point about the book.

## Charter 1. An introduction to Concurrency

第一节主要介绍了Concurrency的定义以及历史.

### Moore's Law, Web Scale, and the Mess We're In

介绍了摩尔定律以及Amdahl’s Law
[摩尔定律](https://zh.wikipedia.org/wiki/%E6%91%A9%E5%B0%94%E5%AE%9A%E5%BE%8B)
[Amdahl’s Law](https://zh.wikipedia.org/wiki/%E9%98%BF%E5%A7%86%E8%BE%BE%E5%B0%94%E5%AE%9A%E5%BE%8B)

### Why is Concurrency Hard

介绍几种引入concurrency带来的通用问题

#### Race Condition

“A race condition occurs when two or more operations must execute in the correct order, but the program has not been written so that this order is guaranteed to be maintained”

简单来说就是一致性问题

> 一个简单的反面例子
```go
1 var data int
2 go func() { 
3     data++
4 }()
5 if data == 0 {
6     fmt.Printf("the value is %v.\n", data)
7 }
```

#### Atomicity

“When something is considered atomic, or to have the property of atomicity, this means that within the context that it is operating, it is indivisible, or uninterruptible.”

原子性 不可打断的最小操作

#### Memory Access Synchronization

[官方参考资料](https://golang.org/ref/mem)

#### Deadlocks, Livelocks, and Starvation

##### Deadlock
死锁

常见的几种场景
- Mutual Exclusion
    - A concurrent process holds exclusive rights to a resource at any one time
- Wait for condition
    - A concurrent process must simultaneously hold a resource and be waiting for an additional resource.
- No Preemption
    - A resource held by a concurrent process can only be released by that process, so it fulfills this condition.
- Circular Wait
    - A concurrent process (P1) must be waiting on a chain of other concurrent processes (P2), which are in turn waiting on it (P1), so it fulfills this final condition too.

##### Livelock

Livelocks are programs that are actively performing concurrent operations, but these operations do nothing to move the state of the program forward.

程序在跑 但是程序的状态一直停留在原地

##### Starvation

Starvation is any situation where a concurrent process cannot get all the resources it needs to perform work.

过多的程序在竞争资源 导致资源都耗费在调度上了 结果大家都分不到资源

##### Determining Concurrency Safety

#### Simplicity in the Face of Complexity

介绍了和其他变成语言相比 go在concurrency这块做了哪些工作:
- 内存管理 即 gc
- goroutine调度 抽象的goroutine调度到操作系统的thread

## Charter 2. Modeling Your Code: Communicating Sequential Processes

### The Difference Between Concurrency and Parallelism

The fact that concurrency is different from parallelism is often overlooked or misunderstood. In conversations between many developers, the two terms are often used interchangeably to mean “something that runs at the same time as something else.” Sometimes using the word “parallel” in this context is correct, but usually if the developers are discussing code, they really ought to be using the word “concurrent.
并发和并行的区别

### What Is CSP?

CSP: Communicating Sequential Processes
[CSP Paper](https://dl.acm.org/doi/10.1145/359576.359585)

常规的并发安全思路是通过对内存的访问顺序做文章来保证内存的一致性, CSP提出了一种新的思路, 并发程序之间通过显式的输入输出来控制数据的access.

#### How This Helps You

go采纳了CSP的思路来实现并发, 诞生了goroutine和channel.

#### Go’s Philosophy on Concurrency

[官方参考资料](https://golang.org/ref/mem)

> 关于选择channel还是sync包的参考

---


![d04f6a989475155abb25e5407ce337af.png](evernotecid://C89FDA3E-A873-421C-BFAE-498A116E39F9/appyinxiangcom/27330777/ENResource/p103)

## Chapter 3. Go’s Concurrency Building Blocks


