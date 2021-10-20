---
title: 使用 SSE 替代轮询
date: 2021-10-09 22:00:50
tags:
    - javascript
    - nodejs
    - http
dir: http
keywords:
    - Server-sent events
    - 服务器发送事件
description: 浏览器和服务端交互过程中，会有服务端向浏览器通信的场景。例如：服务端异步处理信息，处理成功后向浏览器推送。那有没有既不需要 `websocket` 通道，又不用`轮询`这么 “low” 的方法呢？本文介绍的 `SSE` (server-site events) 就足够简洁和优雅。
---

# 🎓 背景
浏览器和服务端交互过程中，会有服务端向浏览器通信的场景。例如：服务端异步处理信息，处理成功后向浏览器推送。

但并不是所有的后台服务都建立了 `websocket` 通道，因此常用做法是浏览器定时查询，`轮询`后台数据。

从请求的角度来看，`轮询`多余了浏览器向后台服务`发起握手`、`发送数据包`的过程，因此并不简洁、优雅。

那有没有既不需要 `websocket` 通道，又不用`轮询`这么 “low” 的方法呢？本文介绍的 `SSE` (server-site events) 就足够简洁和优雅。

# 🤔️ SSE 是啥

`SSE` 全称是 Server-sent events(服务器发送事件)，是服务器向客户端推送数据的一种方式。

`SSE` 的本质是通过 `HTTP` 请求，不断发送 `流信息(streaming)`，使得服务器向客户端推送信息。类似于视频流。

他不是一次性的数据包，而是会一直等着服务端的推送。因此客户端不会关闭连接，等着服务端的不断推送。这样就实现了服务端向客户端的推送。

# 🆚 SSE VS Websocket
`Websocket` 是双向通信(全双工)，浏览器 <-> 服务端相互通信，更强大也更灵活。

`SSE` 是单向通信(半双工)，浏览器 <- 服务端，本质是下载信息。

| 对比   | 优点 | 缺点 |
| ---- | ----  | ---- |
| `Websocket`  | 1. 全双工，功能更强大<br/> | 1.较为复杂，服务端需要重新支持<br/>2.断线重连需要额外部署 |
| `SSE`  | 1.协议轻量，支持 HTTP 的服务端就支持<br/>2.方便默认支持断线重连<br/>3.支持自定义数据类型 | 1.半双工，不够灵活 |

两者各有特点，适合不同场所

# 💡 SSE 的使用
既然 `SSE` 作用于客户端和服务端，下面分为`客户端`和`服务端`来分别介绍 `API`。

## 浏览器的使用

### 检查是否可以使用
`SSE` 在浏览器中的API在 `EventSource` 对象上。通过这样来检测是否可以使用，通常来讲，除了 IE\Edge，主流浏览器都支持：
```js
if (Boolean(window.EventSource)) {
  // ...
}
```

### 和服务器建立连接
浏览器先生成 `EventSource` 实例，再向服务器发起连接。

当然，url 可以是当前网址同域，也可以跨域。
```js
// 同网址
let source = new EventSource(url);

// 跨域带上 cookie。 打开withCredentials属性，表示是否一起发送 Cookie。
let source = new EventSource(url, { withCredentials: true });
```

### 状态变化
`EventSource` 实例中 `readyState` 属性表明了当前连接状态。可以取以下值。

| 取值 | 解释 |
| --- | --- |
| `0` | 表示连接还未建立，或者断线正在重连 |
| `1` | 表示连接已经建立，可以接受数据 |
| `2` | 表示连接已断，且不会重连 |

### 基本使用
- `建立连接时`，会触发 `open` 事件，和 `js` 其他事件用法基本一致
```js
// onopen 写法
source.onopen = (event) => {
    // ...
}

// addEventListener
source.addEventListener('open', (event) => {
  // ...
}, false);
```

- `收到消息时`，会触发 `message` 事件，和 `js` 其他事件用法基本一致。
```js
// onmessage 写法
source.onmessage = (event) => {
  const data = event.data;
  // ...
};

// addEventListener
source.addEventListener('message', (event) => {
  // data 是服务器回传的数据，是 文本格式，二进制需要重新转码
  const data = event.data;
  // ...
}, false);
```

- `发生错误时`(例如中断)，会触发 `error` 事件，和 `js` 其他事件用法基本一致。
```js
// onerror 写法
source.onerror = (event) => {
  // ...
};

// addEventListener
source.addEventListener('error', (event) => {
  // ...
}, false);
```

- `关闭连接`
```js
source.close();
```

- `自定义事件`, 默认情况下触发的是 `message` 事件，但是还能自定义事件，从而不触发 `message` 事件。本例子对 `info` 事件进行监听
```js
source.addEventListener('info', (event) => {
  const data = event.data;
  // ...
}, false);
```

## 服务端的使用
### 请求头
服务端的向浏览器发送的数据是 `UTF-8` 的编码文本，`HTTP` 头具有特定的信息。
必须指定 `Content-Type` 类型为 `event-steam`。
```
Content-Type: text/event-stream
Cache-Control: no-cache
Connection: keep-alive
```
![header](sse-header.png)


### 数据格式
每一次发送的信息，由若干个 `message` 组成，每个 `message` 之间用\n\n分隔。类型如下:
```js
// 数据栏
data: [value]\n

// 自定义信息类型
event: [value]\n

// 数据标识符
id: [value]\n

// 最大间隔时间
retry: [value]\n

// 注释
: [value]\n

```

| 对比   | 描述 | 例子 |
| ---- | ----  | ---- |
| `data`  | 数据内容用data表示，可以占用一行或多行，以“\n\n”结尾 | data: begin message\n<br/>data: continue message\n\n |
| `event`  | event头信息表示自定义的数据类型，没有则默认 `message` 事件 | event: foo\n<br/>data: a foo event\n\n |
| `id`  | 数据标识符用id表示，相当于每一条数据的编号 | id: msg1\n <br/> data: message\n\n |
| `retry`  | 浏览器默认三秒内没有发送任何信息开始重连。服务器端可以用 `retry` 头信息，指定通信的最大间隔时间| retry: 10000\n |
| ` `  | 通常，服务器每隔一段时间就会向浏览器发送一个注释保持连接不中断 | : This is a comment |

## 服务端实现
每个服务端实现不同，以下是 `NodeJS` 方案实现。

### NodeJS 实现
```js
// sse.js
const http = require("http");const http = require("http");

http.createServer(function (req, res) {
  res.writeHead(200, {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    "Connection": "keep-alive",
    "Access-Control-Allow-Origin": '*',
  });

  res.write("retry: 1000\n");
  res.write("event: connecttime\n");
  res.write("data: " + (new Date()) + "\n\n");

  interval = setInterval(function () {
    res.write("data: " + (new Date()) + "\n\n");
  }, 1000);

  req.addListener("close", function () {
    clearInterval(interval);
  }, false);
}).listen(8080);
```

### 启动和访问
仅需 `node sse.js` 即可打开

```bash
node sse.js
```

并访问 [http://127.0.0.1:8080/](http://127.0.0.1:8080/) 就能访问到 `sse` 的页面啦！

# 🔚 结语
从 `轮询` 到 `SSE`，再到 `SSE` 和 `Websocket` 的技术选型，不同的场景用不同方案。在鱼和熊掌都要兼得的道路上，道阻且长。

开发过程和成长过程一样。先是“长大”就行，再到“快点长大”，最后是“好好长大”。开发过程也是一样，字符串替换“长大” 成 “迭代”。这个过程必不可少，经历也完全不同。

希望能给你带来些帮助，感谢你的时间阅读到这里💗。