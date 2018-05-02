---
title: 你不知道的javascript————类型和语法
date: 2017-12-17 21:17:15
tags: JavaScript
---
### 类型
#### 七个内置类型
*   空值 (null)
*   未定义 (undefined)
*   布尔值 (boolean)
*   数字 (number)
*   字符串 (string)
*   对象 (object)
*   符号 (symbol)

#### 检测各个类型
```
typeof undefined		=== "undefined" 	// true
typeof true 				=== "boolean"			// true
typeof 42						=== "number"			// true
typeof "42" 				=== "string"			// true
typeof {"life": 42}	=== "object"			// true
typeof Symbol				=== "symbol"			// true
typeof null 				=== "object"			// true
typeof function(){}	=== "function" 		// true
typeof [0,1]				=== "object"			// true
```
本身null对象里面代表空值，所以其为object也是合理。但应该typeof null 返回是 null才符合常理。由于这个bug在许多代码中已经这样做了，所以重新修回会导致更严重的bug。因此被修回的可能性很小。
因此，对null应该采用复合查询语句
```
var a = null;
(!a && typeof a === "object")	// true

```
而对于typeof function(){} === “function” 而言，因为本身function是object的一个子类型，具体的说，函数是一个可调用对象。
且typeof [0,1] === “object”,因为数组也是object的一个子类型

_ps：由于所有的typeof都会返回一个string，所以 typeof typeof 42会是”string”，因为typeof 42首先会变成一个“number”，是一个string类型，所以typeof “number”是一个string_
#### undefined && undeclared && typeof undeclared
```
var a;
typeof a;			// "undefined"
var b = 42;
var c;
b=c;
typeof c			// "undefined"
typeof b			// "undefined"
a							// "undefined"
d							// "VM422:1 Uncaught ReferenceError: d is not defined at <anonymous>:1:1"
```
从上述可以看出，undefined 和 undeclared 是两码事。undefined意思是定义但未赋值，或者赋值为undefined，而undeclared是未定义。因此两者不能画等号
#### typeof undeclared
```
typeof a			// "undefined"
```
出现这种原因因为typeof有一个特殊的安全防范机制，因为多个脚本文件会在共享的全局变量命名空间中加载变量。如果typeof一个未命名的报错，会导致整段程序停止运行。对于typeof来检查undeclared变量，有时是一个不错的办法。

#### 值
##### 数组
js的数组可以容纳任何的值，甚至可以是另一个数组，因此多维数组就是这种方式来实现的。
由于数组本身就是一个特殊的对象，所以数组也可以包含字符串键值和属性，但是这并不计算在数组长度内。
```
var a = [];
a[0] = 1;
a["foobar"] = 1;
a.length 			// 1
a["foobar"];	// 1
a.foobar			// 1
a["13"] = 42;
a.length		// 14
```
为什么会这样呢？由于本身数组就是一个对象的子集合，因此在[]中，使用十进制字符串数字会直接强制类型转化成数字。a[“13”]就变成了a[13],因此在数组内会直接将其长度变化成14。同理，在属性给foobar加到a数组中，因为数组的界定是有数字来确定下标位置，而length是最后一个下标数字+1，因而加入的非数字就不在长度里面了。

##### 类数组
对于es5而言，可以用slice,concat来实现类数组转数组，对于es6而言，可以用Array.from()来实现从类数组转换成数组。

##### 字符串
字符串的一些方法indexOf(),concat(),toUpperCase(),reverse()等等。
字符串的一些方法：
|方法|描述|
|---|---|
|charAt() | 返回指定索引位置的字符|
|charCodeAt() | 返回指定索引位置字符的 Unicode 值|
|concat() | 连接两个或多个字符串，返回连接后的字符串|
|fromCharCode() | 将 Unicode 转换为字符串|
|indexOf() | 返回字符串中检索指定字符第一次出现的位置|
|lastIndexOf() | 返回字符串中检索指定字符最后一次出现的位置|
|localeCompare() | 用本地特定的顺序来比较两个字符串|
|match() | 找到一个或多个正则表达式的匹配|
|replace() | 替换与正则表达式匹配的子串|
|search() | 检索与正则表达式相匹配的值|
|slice() | 提取字符串的片断，并在新的字符串中返回被提取的部分|
|split() | 把字符串分割为子字符串数组|
|substr() | 从起始索引号提取字符串中指定数目的字符|
|substring() | 提取字符串中两个指定的索引号之间的字符|
|toLocaleLowerCase() | 根据主机的语言环境把字符串转换为小写，只有几种语言（如土耳其语）具有地方特有的大小写映射|
|toLocaleUpperCase() | 根据主机的语言环境把字符串转换为大写，只有几种语言（如土耳其语）具有地方特有的大小写映射|
|toLowerCase() | 把字符串转换为小写|
|toString() | 返回字符串对象值|
|toUpperCase() | 把字符串转换为大写|
|trim() | 移除字符串首尾空白|
|valueOf() | 返回某个字符串对象的原始值|

如果需要经常一字符数组的方式来处理字符串的话，倒不如直接用数组。这样就不用在字符串和数组之间来回折腾。可以在有需要的时候使用join(“”)来将字符串数组转换为字符串

#### 数字
和大部分编程语言一样，js中的数字是基于IEE754标准来实现的。该标准通常也被称为“浮点数”。而js使用的是双精度单位(64位)格式。所以也会有iee754标准的通病，即浮点数之间相加会有奇妙的现象。
数字的一些方法：
toExponential()
```
var a = 5E10			// 可以通过这种方式赋值
a									// 50000000000
a.toExponential()	// "5e+10"
var b = a * a;
b 								// 2.5e+21
```	
toFixed()					// 精度
```bash
var a = 42.59
a.toFixed(1)			// "42.6"
// 无效
42.toFixed(3)			// Uncaught SyntaxError: Invalid or unexpected token
// 有效
42..toFixed(3)		// "42.000"
(42).toFixed(3)		// "42.000"
0.42.toFixed(3)		// "0.420"
42 .toFixed(3)		// "42.000"
```
因为.被视为常量42.的一部分。所以没有.属性访问运算符来调用toFixed()
toPrecision() // 执行有效位数的显示位数
```
var a = 42.59
a.toPrecision(1)		// "4e+1"
a.toPrecision(2)		// "43"
a.toPrecision(3)		// "42.6"
``` 
es6支持新格式
```bash
0B		0b					// 二进制
0O		0o					// 八进制
0X		0x					// 十六进制
```
EPSILON // 最小精度
```
if(((0.1 + 0.2) - 0.3)<Number.EPSILON){
}else{
}
```
MAX_VALUE
MAX_SAFE_INTEGER
```
Number.MAX_VALUE						// 1.7976931348623157e+308
Number.MAX_SAFE_INTEGER			// 9007199254740991
```
isInteger
```
Number.isInteger(1)					// true
Number.isInteger(1.1)				// false
Number.isInteger(1.0)				// true
```
#### 特殊数值
##### undefined
```
var undefined = 2
undefined 	// 2

```
_ps：永远不要重新定义undefined_
#### void 运算符
在不需要返回值的时候，可以void掉
```
if(ready){
	return void setTimeout(..)
}
```
这样做可以将setTimeout返回的id给void掉
#### NaN
NaN是一个数值型。意思指的是不是一个数值，并且NaN != NaN。可以使用isNaN来判断是否是NaN
```
Number.isNaN(NaN)				// true
Number.isNaN(1)					// false

```
#### 0值
加法和减法运算永远不会有-0
使用toString和JSON.stringify()会将-0变成0
```
0/-1			// -0
0/1				// 0
var a = -0
a 				// -0
a.toString()		// 0
JSON.stringify(a)	// 0
```
#### 特殊等式
Object.is
Object.is 可以判断是+0还是-0,而且可以判断是否为NaN
```
Object.is(+0, -0)	// false
Object.is(NaN, NaN)		// true

```
#### 值和引用
null，undefined，字符串，数字，布尔，symbol都是简单值
对象，函数都是复杂值
```
function foo(x) {
	x.push(4);	
	x;							// [1,2,3,4]
	x = [4,5,6];
	x.push(7);
	x;							// [4,5,6,7]
}
var a = [1,2,3];
foo(a);
a;				// [1,2,3,4]
由于一开始是引用赋值，然后x是a对应数组的一个引用，x在push一个4之后，重新引用一个新的数组，4.5.6,而a引用的数组变化成了[1,2,3,4];
function foo(x){
	x.push(4);
	x;				// [1,2,3,4]
	x.length = 0;	
	x.push(4,5,6,7)
	x;				// [4,5,6,7]
}
var a = [1,2,3]
foo(a)
a;		// [4,5,6,7]
和上面一开始一样，只是后面在x.length=0后，再push进去了4,5,6,7。所以x的引用没变，还是和a引用的一样。所以a和x一同变化
```
_ps：我们无法自行决定使用值赋值还是引用赋值，一切由值的类型决定_
```
function foo(warpper){
	warpper.a = 42
}
var obj = {
	a: 1
}
foo(obj)
obj.a			//42
function foo (x) {
	x = x+1;
	x;				// 3
}
var a = 2;
var b = new Number(a);
foo(b)
console.log(b)		// 2
前者是引用赋值，后者是值赋值
```
#### 原生函数
* String
* Number
* Boolean
* Array
* Object
* Function
* RegExp
* Date
* Error
* Symbol

#### 内部属性[[Class]]
所有typeof返回值为“Object”的对象(如数组)都包含一个内部属性[[Class]]，这个属性通常无法直接访问，一般通过Object.prototype.toString查看
```
Object.prototype.toString.call([123])			// "[object Array]"
Object.prototype.toString.call(null)			// "[object Null]"
Object.prototype.toString.call(true)			// "[object Boolean]"
Object.prototype.toString.call(undefined)	// "[object Undefined]"
```
虽然Null和undefined这样的原声构造函数不存在，但是内部Class属性值仍然是Null和Undefined。基本类型值被各自的封装对象自动包装，所以他们的内部[[Class]]属性值为Boolean。
#### 封装对象包装
```
var a = "abc";
console.log(a);		// "abc"
a.length 					// "3"
var b = new String("abc")
console.log(b)		// String {[[PrimitiveValue]]: "abc"} 0:"a" 1:"b" 2:"c" length:3 __proto__:String [[PrimitiveValue]]:"abc"
```
只是创建字面量基本值的时候，并没有其他的方法。当在使用其对象方法时，需要通过封装对象才能访问，此时js会自动为基本类型值包装(box或者wrap)一个封装对象。
但是为经常用到的.length方法直接new一个对象也不是一个好办法，因为浏览器对.length这样的常见情况做了优化，直接使用封装对象来“提前优化”反而会降低执行效率。

#### 封装对象的释疑
例如：
```
var a = new Boolean(false);
if (!a){
	console.log(...)			// 执行不到这里
}
```
因为建立一个a之后，这个对象得到的是真值，得到的结果和使用false相反

自行封装可以使用Object
```
var a = "abc"
var b = new String (a);
var c = Object(a);
typeof a 				// "stirng"
typeof b				// "object"
typeof c				// "object"
b instanceof String 	// true
c instanceof String 	// true
Object.prototype.toString.call(b);		// "[object String]"
Object.prototype.toString.call(c);		// "[object String]"
```
一般不直接使用封装对象，但是他们偶尔也会派上用场
#### 拆封
如果想得到封装对象里面的值，可以使用valueOf函数，隐式拆封也是调用了valueOf函数：
```
var a = new String("abc")
var b = new Number(11)
var c = new Boolean(true)
a.valueOf()	// "abc"
b.valueOf()	// 11
c.valueOf()	// true
var d = a + "";
console.log(d)				// "abc"
typeof a 			// "object"
typeof d 			// "string"

```
#### 原生函数作为构造函数
四种方式创建应该尽量避免构造函数，除非十分必要
* array 数组
* object 对象
* function 函数
* RegExp 正则表达式
### ARRAY(..)
调用Array构造函数时，可以不需要加上new，效果一致。）且Array构造函数纸袋一个数字作为参数的时候，这个参数会当作数组的预设长度，而不是充当其中的一个元素
```
// 效果一致
var a = new Array(1,2,3);
a			// [1,2,3]
var b = Array(1,2,3)
b 		// [1,2,3]
var c = [1,2,3]
c 		// [1,2,3]
// 不同方式创建出来空数组效果不一致
var d = new Array(3);
console.log(d)			// chrome上： (3) [empty × 3]
d.length						// 3
var e = [undefined,undefined,undefined];
console.log(e)			// (3) [undefined, undefined, undefined]
var f = []					
f.length = 3;
console.log(f);			// chrome上： (3) [empty × 3]
// 直接以，创建。虽然长度是3令人费解，但是可以更好的复制粘贴
var g = [,,,]
console.log(g)			// chrome上： (3) [empty × 3]

```
由于创建方式不同，导致在chrome下不一致的显示，但是更难过的是，他们有时相同，有时呵呵
```
var a = new Array(3)
var b = [undefined,undefined,undefined]
a.join("-")			// "--"
b.join("-")			// "--"
a.map(function(v,i){return i})		// (3) [empty × 3]
a.map(function(v,i){return i})		// [0, 1, 2]
```
a.map之所以执行失败，是因为a中是没有元素的，而b里面有undefied。
**而join首先假定数组不为空，然后通过length属性值来便利其中的元素，而map并不做这种假定**
可以通过这种方式来创建包含undefined单元的数组
```
var a = Array.apply(null, {length:3});
console.log(a)			// (3) [undefined, undefined, undefined]
```
_PS:永远不要创建和使用空单元数组_

#### OBJECT、FUNCTION、REGEXP
**除非玩不得已，尽量不要使用他们**
```
var c = new Object();
c.foo = "bar";
c				// {foo:"bar"}
var d = {foo:"bar"}
d				// {foo:"bar"}
var e = new Function("a","return a * 2");
var f = function(a){return a*2};
function g(a){return a*2}
var h = new RegExp("^a*b+","g");
var i = /^a*b+/g
```
javascript对常量形式的代码会对他们进行预编译和缓存！
#### DATE、ERROR
相较于其他原生构造函数，Date、Error的用处比其他的更多，因为没有其他对用的常量形式来作为他们的替代
引入生成当前时间戳，使用
```
Date.now()
// 使用new来生成时间
new Date()
// Thu Jan 04 2018 06:47:59 GMT+0800 (CST)

```
错误对象通常与throw一起使用
```
function foo(x){
	if(!x){
		throw new Error("///");
	}
	// -
}
```
#### SYMBOL
Symbol可作为私有属性是一种简单标量基本类型

### 强制类型转换
#### 抽象值操作
如果对象有自己的toString()方法，字符串化就会调用该方法并使用其返回值。
数组的默认toString方法经过了重新定义
```
var a = [1,2,3]
a.toString()		// "1,2,3"

```
#### JSON 字符串化
JSON.stringify(42) // “42”
JSON.stringify(“42”) // “”42””
JSON.stringify(null) // “null”
JSON.stringify(true) // “true”

_JSON.stringify()在对象中遇到undefined、function和symbol时会自动将其忽略，在数组中则会返回null_
```
JSON.stringify(undefined)			// undefined
JSON.stringify(function(){})	// undefined
JSON.stringify([1,undefined, function(){},4])	// "[1,null,null,4]"
JSON.stringify({a:2, b: function(){}})				// "{"a":2}"
```
循环引用会出错
```
var o = {};
var a = {
	b:42,
	c:o,
	d:function(){}
}
o.e = a
JSON.stringify(a)
a.toJSON=function(){
	return {b:this.b}
}
JSON.stringify(a)
# Uncaught TypeError: Converting circular structure to JSON
#     at JSON.stringify (<anonymous>)
#     at <anonymous>:8:6
```