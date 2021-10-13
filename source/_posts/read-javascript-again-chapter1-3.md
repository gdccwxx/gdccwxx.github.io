---
title: JavaScript高级程序设计重读—1-3章
date: 2017-07-11 09:03:44
tags: javascript
dir: javascript
keywords: JavaScript高级程序设计
---
### 基本概念
#### 关于script标签
```
<script src="/javascripts/application.js" type="text/javascript" charset="utf-8" async defer></script>
```
script标签共有src，type，charset，async，defer几个属性。在只有script时依然可以作用。
1、async是可选的，意为立即下载脚本，但不妨碍页面中的其他操作。且其下载后文件的执行顺序不定。
```
<script src="1.js" async></script>
<script src="2.js" async></script>
```
其下载后1.js和2.js不定制性。没有一定顺序，可能是1先，也可能是2先执行。

2、charset是指定字符集，在不写的情况下，默认charset为‘utf-8’编码。
3、type，在不谢的情况下默认值位‘text/javascript’
4、src属性，src属性并不是非得引用xx.js,而是其只要正确引用返回MIME类型即可。(mime类型：MIME (Multipurpose Internet Mail Extensions) 是描述消息内容类型的因特网标准。
MIME 消息能包含文本、图像、音频、视频以及其他应用程序专用的数据。)如果有src属性，则script标签中即使有代码也不会执行。

#### script标签位置
由于浏览器是由上到下解析内容。如果放在head变迁内，浏览器要等其下载完成后，再去渲染整个页面。因此会有一段时间延迟渲染，造成用户体验差，因此，为了避免这个问题，现代web应用一般是放在body元素中页面内容的后面。加上defer延迟后，将在浏览器解析完成整个页面，即解析完成< /html>之后再执行js代码。

_ps：defer，async都是先下载文件。加载页面完成后执行，但是不同点是defer保证js文件顺序执行，而async则不保证。_

#### 标识符
规则：
1、第一个字符必须是字母、下划线，或美元符号
2、其他字符可以使字母，下划线，美元符号或数字
最佳采用驼峰式命名
#### 变量
未初始化的变量都有一个默认的值，undefined，若未使用var，则其将直接变成全局变量。可以使用逗号分隔，多个变量赋值，即
```
var a = 0,
    b = 1,
    c = 2
```
#### 数据类型
JavaScript共有5种基本数据类型和1种复杂数据类型。分别是：
Undefined，Null，Boolean，Number，String；Object
##### TYPEOF操作
typeof操作只能返回下列字符串
undefined – 值未定义
boolean – 布尔值
string — 字符串
number – 数值
object – 对象或null
function – 函数
##### Undefined类型
显示的对一个值赋值为undefined和不初始化某个变量，其都===undefined
```
var message
// var age   此变量未声明
typeof message // undefined
typeof age //undefined
```
_ps：对未初始化的变量执行typeof操作符会返回undefined，而对未声明的变量执行统一配发操作符同样也会返回undefined值。_
##### Null类型
Null类型是表示一个空对象指针，也正是typeof null 返回Object的原因了。因此在声明一个为初始化的对象时，应该赋值为Null,在判断语句if中，null代表false。因此常用其作为未初始对象的赋值
##### Boolean类型
| 数据类型 | 转换为true的值 | 转换位为false的值 |
| --- | --- | --- |
| Boolean | true | false |
| String | 任何非空字符串 | “”空字符串 |
| Number | 任何非零数值(包括无穷大) | 0和NaN |
| Object | 任何对象 | null |
| Undefined | 不存在的 | undefined |
##### Number类型
1、如果前缀为 0，则 JavaScript 会把数值常量解释为八进制数，如果前缀为 0 和 “x”，则解释为十六进制数。即
```
var octalNum = 070 // 56
var hexNum1 = 0xA //10
```
在进行算术运算时其右会转化成10进制
2、JavaScript中+0和-0是相等的
3、由于浮点数的数值计算产生误差，即0.1 + 0.2 = 0.30000000000000004是因为给予IEEE754数值的浮点数计算的通病(详见：计算机系统基础－－第二章(数据的机器级表示与处理) – 浮点数的表示)
4、由于浮点数的表示范围有限，因此其表示范围有Number.MIN_VALUE(最小值)和Number.MAX_VALUE(最大值)表示。采用isFinite()函数判断其是否溢出
5、NaN表示not a number 是一个特殊的值，表示其转换不是一个数值。任何数值的算术运算对NaN的结果都是NaN，且NaN不等于其本身。判断是否是NaN有专门函数isNaN()来判断。传入参数会先尝试转换成number再判断。而测试对象时先调用对象的valueOf方法，在确定是否可以转换成数值，如果不能，再调用toString方法。在测试返回值。
6、数值转换函数Number(),规则如下
```
(1)boolean,true转换成1，false转换成0
(2)数值，简单传入和返回
(3)null，返回0
(4)undefined，返回NaN
(5)字符串：   <1>转换为十进制数，并且将前面多余的0去除
             <2>浮点数格式相同
             <3>如果包含0x、0o，将其转换成10进制数
             <4>空字符串转换为0
             <5>其他格式外都转换成NaN
(6)对象，先调用valueOf()方法，然后依照返回值，如果是NaN，则调用对象toString方法，再根据前面返回字符串
```
7、parseInt()，parseFloat()函数
parseInt也是将传入参数转换成数值，与Number函数不同的地方是，parseInt函数会选取从首字符开始的数值，到非数值字符结束，即parseInt(‘123abc’)转换成123，而Number转换成NaN。
parseInt可以接受第二个参数，代表转换成的基于格式。即
```
parseInt('10',2)  // 2
```
基于格式格式转化成相应十进制数
##### String类型
1、字符字面量，例如\n(换行),\t(制表)等等。这些字面量在字符串的任意位置都会被当做字符来解析。例如
```
var a = '\t\t\t'
a.length // 3
```
而a打印出来是三个制表
2、字符串的特点。
```
var lang = 'Java'
lang = lang + 'Script'
```
开始时lang保存字符串Java，而第二行把lang的值重新定义为Java和script结合，这个操作首先创建一个能容纳10个字符的新字符串，然后在这个字符串中填入java 和script，最后一步是销毁原来的字符串java和字符串script。
3、字符串的转换
利用toString方法来将数值转化成string，而其参数是转化成不同进制
```
var num = 11
num.toString() // '11'
var nums = 10
nums.toString(2) // '1010'
```
在不是null和undefined的情况下，还可以调用String()函数其转换规则如下
1、如果值有toString方法，调用其不带参数的toString方法
2、如果值是null，返回’null’
3、如果是undefined，返回’undefined’
##### Object类型
可以使用 var o = new Object()或者使用var o = new Object来构造Object实例。每个Object实例都有下列属性和方法
1、constructor 保存着创建当前对象的函数
2、hasOwnProperty 用于检查给定的属性在当前实例中(而不是实例的原型中)
3、isPrototypeOf 用于检查传入的对象是否是当前对象的原型
4、propertyIsEnumerable 用于检查给定的属性是否能用for-in语句来枚举
5、toLocaleString 返回对象的字符串表示，该字符串与执行环境的地区对应
6、toString 返回对象的字符串表示
7、valueOf 返回对象的字符串、数值或布尔值
##### 位操作符
1、按位非 (NOT) ~
```
var num1 = 25   // 二进制00000000000000000000000000011001
var num2 = ~num1// 二进制11111111111111111111111111100110
num2            // ~26
```
2、按位与 (AND) &
```
var result = 25 & 3
result  // 1
25 = 0000 0000 0000 0000 0000 0000 0001 1001
3 =  0000 0000 0000 0000 0000 0000 0000 0011
----------------------------------------------
AND= 0000 0000 0000 0000 0000 0000 0000 0001
```
3、按位或 (OR) |
```
var result = 25 | 3
result  // 27
25 = 0000 0000 0000 0000 0000 0000 0001 1001
3 =  0000 0000 0000 0000 0000 0000 0000 0011
----------------------------------------------
AND= 0000 0000 0000 0000 0000 0000 0001 1011
```
4、按位异或 (XOR) ^
```
var result = 25 ^ 3
result  // 27
25 = 0000 0000 0000 0000 0000 0000 0001 1001
3 =  0000 0000 0000 0000 0000 0000 0000 0011
----------------------------------------------
AND= 0000 0000 0000 0000 0000 0000 0001 1010
```
5、 操作符
```
25**2 = 625
```
**代表次方
#### 语句
label语句结合break，continue语句
```
var num = 0;
outermost:
    for (var i = 0; i < 10; i++) {
        for (var j = 0; j < 10; j++) {
            if (i == 5 && j == 5) {
               break outermost
            }
        }
    }
num // 55
var num = 0;
outermost:
    for (var i = 0; i < 10; i++) {
        for (var j = 0; j < 10; j++) {
            if (i == 5 && j == 5) {
               continue outermost
            }
        }
    }
num // 95
```
lable结合break，continue语句可以控制跳出位置
#### with语句
将代码作用域设定到特定对象中。
```
var qs = location.search.substring(1)
var hostName = location.hostname
var url = location.href
//使用with语句后
with(location){
    var qs = search.substring(1)
    var hostName = hostname
    var url = href
}
```

#### 小结
通过本章学习，发现许多细节问题之前没有搞清楚，一直使用老方法去引用script。变量命名一直也是随意命名，今后的学习、coding之路，让我更清晰，明了基础的知识