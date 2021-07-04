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

第一节主要介绍了Concurrency的定义以及历史

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

介绍go关于concurrency相关的feature支持

### goroutine

[官方FAQ](#https://golang.org/doc/faq#goroutines)

- `goroutine`是go封装的结构
- `coroutine`是在操作系统thread概念之上的抽象, 虽然看起来比直接用线程麻烦, 但是对于concurrency来说有很大好处 因为对于io场景线程太重了.
- `goroutine`是`fork-join`的model![86576fcfeefa4238bdc62549c964a98b.png](evernotecid://C89FDA3E-A873-421C-BFAE-498A116E39F9/appyinxiangcom/27330777/ENResource/p104)
- there is `no Guarantee` the order of goroutine executes.
- support closure
```go
var wg sync.WaitGroup
salutation := "hello"
wg.Add(1)
go func() {
    defer wg.Done()
    salutation = "welcome" 
}()
wg.Wait()
fmt.Println(salutation)
```
- M:N的调度模型
- KB级别的上下文(线程是2MB)
  ![0ad10f36d042c9b042cc796b14200d21.png](evernotecid://C89FDA3E-A873-421C-BFAE-498A116E39F9/appyinxiangcom/27330777/ENResource/p105)

### The sync Package

#### WaitGroup

```go
var wg sync.WaitGroup

wg.Add(1)                       
go func() {
    defer wg.Done()             
    fmt.Println("1st goroutine sleeping...")
    time.Sleep(1)
}()

wg.Add(1)                       
go func() {
    defer wg.Done()             
    fmt.Println("2nd goroutine sleeping...")
    time.Sleep(2)
}()

wg.Wait()                       
fmt.Println("All goroutines complete.")
```

#### Mutex and RWMutex

锁和读写锁

#### Cond

...a rendezvous point for goroutines waiting for or announcing the occurrence
of an event.

```go
c := sync.NewCond(&sync.Mutex{}) 
c.L.Lock() 
for conditionTrue() == false {
    c.Wait() 
}
c.L.Unlock()
```

#### Once

```go
var count int

increment := func() {
    count++
}

var once sync.Once

var increments sync.WaitGroup
increments.Add(100)
for i := 0; i < 100; i++ {
    go func() {
        defer increments.Done()
        once.Do(increment)
    }()
}

increments.Wait()
fmt.Printf("Count is %d\n", count)
```

输出: `Count is 1`

#### Pool

So when working with a Pool, just remember the following points:
- When instantiating sync.Pool, give it a New member variable that is thread-safe when called.
- When you receive an instance from Get, make no assumptions regarding the state of the object you receive back.
- Make sure to call Put when you’re finished with the object you pulled out of the pool. Otherwise, the Pool is useless. Usually this is done with defer.
- Objects in the pool must be roughly uniform in makeup.

```go
myPool := &sync.Pool{
    New: func() interface{} {
        fmt.Println("Creating new instance.")
        return struct{}{}
    },
}

myPool.Get() 
instance := myPool.Get() 
myPool.Put(instance) 
myPool.Get()
```

### Channels

Channels are one of the synchronization primitives in Go derived from Hoare’s CSP.

![d833aae0d8fcfe4de4aee85bc14f6637.png](evernotecid://C89FDA3E-A873-421C-BFAE-498A116E39F9/appyinxiangcom/27330777/ENResource/p106)

- Unbuffered channel 是 block的
- 可以配置range使用
- Buffered channel在buffer满之前是unblock的
- 有receiver的场景 新发送给channel的值直接发送给receiver 不存在slot

#### channel的scope要清晰

> channel owner的职责
- Instantiate the channel.
- Perform writes, or pass ownership to another goroutine.
- Close the channel.
- Ecapsulate the previous three things in this list and expose them via a reader channel.

> 明确职责之后可以规避的风险
- Because we’re the one initializing the channel, we remove the risk of deadlocking by writing to a nil channel.
- Because we’re the one initializing the channel, we remove the risk of panicing by closing a nil channel.
- Because we’re the one who decides when the channel gets closed, we remove the risk of panicing by writing to a closed channel.
- Because we’re the one who decides when the channel gets closed, we remove the risk of panicing by closing a channel more than once.
- We wield the type checker at compile time to prevent improper writes to our channel

> Consumer和channel owner的关系
- Knowing when a channel is closed.
- Responsibly handling blocking for any reason.

### The select Statement

The select statement is the glue that binds channels together; it’s how we’re able to compose channels together in a program to form larger abstractions

```go
var c1, c2 <-chan interface{}
var c3 chan<- interface{}
select {
case <- c1:
    // Do something
case <- c2:
    // Do something
case c3<- struct{}{}:
    // Do something
}
```

- select每个case进入的概率相等 和顺序无关
- time.After使用select的timeout
```go
var c <-chan int
select {
case <-c: 
case <-time.After(1 * time.Second):
    fmt.Println("Timed out.")
}
```
- 空select会永远blcok

### The GOMAXPROCS Lever
“really this function controls the number of OS threads that will host so-called "work queues."

## Chapter 4. Concurrency Patterns in Go

### Confinement

Confinement is the simple yet powerful idea of ensuring information is only ever available from one concurrent process.
对于并发的process confinement只会对其中一个available

#### ad hoc

Ad hoc confinement is when you achieve confinement through a convention—whether it be set by the languages community, the group you work within, or the codebase you work within

```go
data := make([]int, 4)

loopData := func(handleData chan<- int) {
    defer close(handleData)
    for i := range data {
        handleData <- data[i]
    }
}

handleData := make(chan int)
go loopData(handleData)

for num := range handleData {
    fmt.Println(num)
}
```

#### lexical

Lexical confinement involves using lexical scope to expose only the correct data and concurrency primitives for multiple concurrent processes to use.

```go
chanOwner := func() <-chan int {
    results := make(chan int, 5) 
    go func() {
        defer close(results)
        for i := 0; i <= 5; i++ {
            results <- i
        }
    }()
    return results
}

consumer := func(results <-chan int) { 
    for result := range results {
        fmt.Printf("Received: %d\n", result)
    }
    fmt.Println("Done receiving!")
}

results := chanOwner()        
consumer(results)
```

### The for-select Loop

```go
for { // Either loop infinitely or range over something
    select {
    // Do some work with channels
    }
}
```

### Preventing Goroutine Leaks

> 什么时候结束goroutine的生命周期
- When it has completed its work.
- When it cannot continue its work due to an unrecoverable error.
- When it’s told to stop working.

> 一般来说 main goroutine有最详细的上下文 我们期望在main goroutine通知sub goroutine结束

可以通过done channel通知goroutine结束

### The or-channel

At times you may find yourself wanting to combine one or more done channels into a single done channel that closes if any of its component channels close.

```go
var or func(channels ...<-chan interface{}) <-chan interface{}
or = func(channels ...<-chan interface{}) <-chan interface{} { 
    switch len(channels) {
    case 0: 
        return nil
    case 1: 
        return channels[0]
    }

    orDone := make(chan interface{})
    go func() { 
        defer close(orDone)

        switch len(channels) {
        case 2: 
            select {
            case <-channels[0]:
            case <-channels[1]:
            }
        default: 
            select {
            case <-channels[0]:
            case <-channels[1]:
            case <-channels[2]:
            case <-or(append(channels[3:], orDone)...): 
            }
        }
    }()
    return orDone
}
```

#### Error Handling

把错误抛出 上下文最全的goroutine接住错误之后开始处理

```go
type Result struct { 
    Error error
    Response *http.Response
}
checkStatus := func(done <-chan interface{}, urls ...string) <-chan Result { 
    results := make(chan Result)
    go func() {
        defer close(results)

        for _, url := range urls {
            var result Result
            resp, err := http.Get(url)
            result = Result{Error: err, Response: resp} 
            select {
            case <-done:
                return
            case results <- result: 
            }
        }
    }()
    return results
}
done := make(chan interface{})
defer close(done)

urls := []string{"https://www.google.com", "https://badhost"}
for result := range checkStatus(done, urls...) {
    if result.Error != nil { 
        fmt.Printf("error: %v", result.Error)
        continue
    }
    fmt.Printf("Response: %v\n", result.Response.Status)
}
```

### Pipelines

By using a pipeline, you separate the concerns of each stage, which provides numerous benefits.
You can modify stages independent of one another, you can mix and match how stages are combined independent of modifying the stages, you can process each stage concurrent to upstream or downstream stages, and you can fan-out, or rate-limit portions of your pipeline.

#### Stage

A stage consumes and returns the same type.
A stage must be reified2 by the language so that it may be passed around. Functions in Go are reified and fit this purpose nicely.

#### Best Practices for Constructing Pipelines

Use chanel to fulfill `pipeline`

```go
generator := func(done <-chan interface{}, integers ...int) <-chan int {
    intStream := make(chan int)
    go func() {
        defer close(intStream)
        for _, i := range integers {
            select {
            case <-done:
                return
            case intStream <- i:
            }
        }
    }()
    return intStream
}

multiply := func(
  done <-chan interface{},
  intStream <-chan int,
  multiplier int,
) <-chan int {
    multipliedStream := make(chan int)
    go func() {
        defer close(multipliedStream)
        for i := range intStream {
            select {
            case <-done:
                return
            case multipliedStream <- i*multiplier:
            }
        }
    }()
    return multipliedStream
}

add := func(
  done <-chan interface{},
  intStream <-chan int,
  additive int,
) <-chan int {
    addedStream := make(chan int)
    go func() {
        defer close(addedStream)
        “        for i := range intStream {
            select {
            case <-done:
                return
            case addedStream <- i+additive:
            }
        }
    }()
    return addedStream
}

done := make(chan interface{})
defer close(done)

intStream := generator(done, 1, 2, 3, 4)
pipeline := multiply(done, add(done, multiply(done, intStream, 2), 1), 2)

for v := range pipeline {
    fmt.Println(v)
}
```


#### Some Handy Generators

a generator for a pipeline is any function that converts a set of discrete values into a stream of values on a channel

##### repeat

```go
repeat := func(
    done <-chan interface{},
    values ...interface{},
) <-chan interface{} {
    valueStream := make(chan interface{})
    go func() {
        defer close(valueStream)
        for {
            for _, v := range values {
                select {
                case <-done:
                    return
                case valueStream <- v:
                }
            }
        }
    }()
    return valueStream
}
```

##### take

```go
take := func(
    done <-chan interface{},
    valueStream <-chan interface{},
    num int,
) <-chan interface{} {
    takeStream := make(chan interface{})
    go func() {
        defer close(takeStream)
        for i := 0; i < num; i++ {
            select {
            case <-done:
                return
            case takeStream <- <- valueStream:
            }
        }
    }()
    return takeStream
}
```

##### repeatFn

```go
repeatFn := func(
    done <-chan interface{},
    fn func() interface{},
) <-chan interface{} {
    valueStream := make(chan interface{})
    go func() {
        defer close(valueStream)
        for {
            select {
            case <-done:
                return
            case valueStream <- fn():
            }
        }
    }()
    return valueStream
}
```

### Fan-Out, Fan-In

Fan-out is a term to describe the process of starting multiple goroutines to handle input from the pipeline, and fan-in is a term to describe the process of combining multiple results into one channel.

fan-out: 用多个goroutine读取数据
fan-in: 将多个goroutine合并输出到一个channel

> Prerequisite
- It doesn’t rely on values that the stage had calculated before
- It takes a long time to run

`fan-out不保证执行顺序`

### The or-done-channel

done或者work

```go
“orDone := func(done, c <-chan interface{}) <-chan interface{} {
    valStream := make(chan interface{})
    go func() {
        defer close(valStream)
        for {
            select {
            case <-done:
                return
            case v, ok := <-c:
                if ok == false {
                    return
                }
                select {
                case valStream <- v:
                case <-done:
                }
            }
        }
    }()
    return valStream
}
```

### The tee-channel

同样的值发两遍

```go
tee := func(
    done <-chan interface{},
    in <-chan interface{},
) (_, _ <-chan interface{}) { <-chan interface{}) {
    out1 := make(chan interface{})
    out2 := make(chan interface{})
    go func() {
        defer close(out1)
        defer close(out2)
        for val := range orDone(done, in) {
            var out1, out2 = out1, out2 
            for i := 0; i < 2; i++ { 
                select {
                case <-done:
                case out1<-val:
                    out1 = nil 
                case out2<-val:
                    out2 = nil 
                }
            }
        }
    }()
    return out1, out2
}
```

### The bridge-channel

把多个channel combine起来

```go
“bridge := func(
    done <-chan interface{},
    chanStream <-chan <-chan interface{},
) <-chan interface{} {
    valStream := make(chan interface{}) 
    go func() {
        defer close(valStream)
        for { 
            var stream <-chan interface{}
            select {
            case maybeStream, ok := <-chanStream:
                if ok == false {
                    return
                }
                stream = maybeStream
            case <-done:
                return
            }
            for val := range orDone(done, stream) { 
                select {
                case valStream <- val:
                case <-done:
                }
            }
        }
    }()
    return valStream
}
```

### queuing

- queuing 不能提高pipeline的整体性能 但是能提高某个stage的性能
- queuing能避免恶性循环
- 应该放在pipeline的入口 或者批处理stage的前面
- panic的时候可能会丢数据

### The context Package

- cancellation
- timeout
- WithValue

## Chapter 5. Concurrency at Scale


### Error Propagation

concurrency的程序应该更加重视错误的处理

错误发生时需要知道这些信息

- What happened
- When and where occurred
- A friendly user-facing message
- How the user can get more information

为什么要重视错误处理

- 处理过的错误我们会很有自信
- 对于用户 应该始终给封装后的错误

### Timeouts and Cancellation

timeout场景

- System saturation
  - 系统饱和
- Stale data
- Attempting to prevent deadlocks

cancel的场景

- timeout
- User intervention
- Parent cancellation
- Replicated requests

### Heartbeats

Heartbeats are a way for concurrent processes to signal life to outside parties

```go
doWork := func(
    done <-chan interface{},
    pulseInterval time.Duration,
) (<-chan interface{}, <-chan time.Time) {
    heartbeat := make(chan interface{}) 
    results := make(chan time.Time)
    go func() {
        defer close(heartbeat)
        defer close(results)

        pulse := time.Tick(pulseInterval) 
        workGen := time.Tick(2*pulseInterval) 

        sendPulse := func() {
            select {
            case heartbeat <-struct{}{}:
            default: 
            }
        }
        sendResult := func(r time.Time) {
            for {
                select {
                case <-done:
                    return
                case <-pulse: 
                    sendPulse()
                case results <- r:
                    return
                }
            }
        }

        for {
            select {
            case <-done:
                return
            case <-pulse: 
                sendPulse()
            case r := <-workGen:
                sendResult(r)
            }
        }
    }()
    return heartbeat, results
}
```

### Replicated Requests

### Rate Limiting

避免ddos共计或者雪崩

access toekn

### Healing Unhealthy Goroutines

## Chapter 6. Goroutines and the Go Runtime

### work steal

1. At a fork point, add tasks to the tail of the deque associated with the thread.
2. If the thread is idle, steal work from the head of deque associated with some other random thread.
3. At a join point that cannot be realized yet (i.e., the goroutine it is synchronized with has not completed yet), pop work off the tail of the thread’s own deque.
4. If the thread’s deque is empty, either:
  1. Stall at a join.
  2. Steal work from the head of a random thread’s associated deque.