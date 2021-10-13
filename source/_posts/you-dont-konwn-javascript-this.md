---
title: 你不知道的javascript————this和对象原型
date: 2017-09-06 20:29:15
tags: javascript
dir: javascript
keywords: 你不知道的javascript————this和对象原型
---
### this误解
从字面意思来看,this貌似是指向自身的.因此出现各种各样的误解.

##### 指向自身
先看一个demo
```
function foo(num) {
	console.log("foo: " + num);
	this.count++;
}
foo.count = 0;
var i;
for (i = 0; i < 10; i++) {
	if(i > 5) {
		foo(i)
	}
}
// foo: 6
// foo: 7
// foo: 8
// foo: 9
console.log(this.count)	// NaN
```
从上述例子中,可以很清楚的看到函数被调用了四次,而为什么打印出来的this.count是NaN呢?显然this指向的count并不是函数的count.的确在foo.count=0的时候给对象foo加了一个count,但是内部代码this.count却不是指向的那个函数对象.从第二章的理解当中,不难发现,其创建了一个全局count,并且它是NaN.

### this是什么?
this是在运行时绑定的,并不是在编写时绑定的.他的上下文取决于函数调用时的各种条件,this绑定和函数声明没有任何关系,取决于函数的调用方式.

当一个函数被调用时,会创建一个活动记录(有时候称之为上下文).这个记录会包含函数在哪里被调用(调用栈)、函数的调用方式、传入的参数信息,而this就是这个记录的一个属性。会在函数执行过程中用到。

_PS:说白了，THIS实际上是在函数调用时发生的绑定，他指向什么完全取决于函数在哪里被调用。_

##### 调用位置
```
function baz() {
	// 当前作用栈是： baz
	// 因此调用位置是全局作用域
	console.log("baz")
	bar()			// <-- bar的调用位置
}
function bar() {
	// 当前调用栈是baz -> bar
	// 因此调用位置是baz中
	console.log("bar")
	foo();		// <-- foo的调用位置
}
function foo() {
	// 当前调用栈是baz -> bar -> foo
	// 当前调用位置在bar中
	console.log("foo")
}
baz()    // <-- baz的调用位置
```
从上述调用栈，可以分析出真正的调用位置，他决定了this的绑定
### 四种绑定规则
##### 默认绑定
```
function foo() {
	console.log(this.a)
}
var a = 2;
foo();	// 2
///////////////////////
function foo2() {
	"use strict"
	console.log(this.a)
}
var a =2
foo2() 		// typeerror
////////////////////////
function foo3() {
	console.log(this.a)
}
var a =2
(function () {
	"use strict"
	foo3()		// 2
})()

```
在非严格模式下，foo的调用默认指向调用位置，例子中是全局，而在严格模式下会抛出异常，在严格模式调用其他位置的this，也可以调用。

##### 隐式绑定
```
function foo() {
	console.log(this.a)
}
var obj = {
	a : 2,
	foo : foo
}
obj.foo 	// 2

```
在代码中，foo默认是绑定在obj的foo的属性上，因此隐式的把foo中的this绑定在obj之上，调用的也是obj中的a
```
function foo() {
	console.log(this.a)
}
var obj2 = {
	a:42,
	foo:foo
}
var obj1 = {
	a: 2,
	obj2: obj2
}
obj1.obj2.foo() 	// 42

```
在上面的代码中，经过多层的调用，但是最终结果还是指向的是最后一层调用的位置。因此可以的出结论。在对象属性引用链中只有上一层或者说最后一层在调用位置中起作用。
##### 隐式丢失
```
// 隐式丢失，成为默认绑定
function foo() {
	console.log(this.a)
}
var obj = {
	a:2,
	foo: foo
}
var bar = obj.foo
var a = "this is global"
bar()			// this is global
////////////////////////////////////////
// 回调的隐式丢失
function foo() {
	console.log(this.a)
}
function doFoo(fn) {
	// fn其实引用的是foo
	fn()		// 调用位置
}
var obj = {
	a: 2,
	foo: foo
}
var a = "this is global"
doFoo(obj.foo)	// this is global

```
虽然bar是obj.foo的一个引用，但实际上，它引用的是foo函数本身，因此此时的bar()其实是一个不带任何修饰的函数调用，因此引用了默认绑定。
第二种情况也是如此，在回调时的隐式丢失导致的问题
这也导致setTimeout中的隐式丢失，常用方法是将this绑定到一个变量中，这样就不会导致隐式丢失

##### 显式绑定
使用call，和apply方法绑定。
**1、硬绑定**
```
function foo() {
	console.log(this.a)
}
var obj = {
	a:2
}
var bar = function () {
	foo.call(obj)
}
bar()		// 2
setTimeout(bar, 100)	// 2
bar.call(window)	// 2

```
无论是强制显示调用window，他都是2.因为在bar这个函数中调用了foo.call(obj)，最终都会绑定到obj上。为了硬绑定的应用，ES5中有bind方法，专门用于绑定。

**API调用的“上下文”**
和bind一样，他的作用是保证回调
```
function foo(el) {
	console.log(el, this.id)
}
var obj = {
	id: "awesome"
}
[1, 2, 3].forEach(foo, obj) 	// 调用时将this绑定到obj上
```
**new 绑定**
使用new来调用函数，会自动执行以下操作：
1、创建一个全新的对象
2、这个新对象会被执行[[Prototype]]连接
3、这个新对象会绑定到函数调用的this
4、如果函数没有返回其他对象，那么new表达式中的函数中会自动调用这个对象
```
function foo(a){
	this.a = a
}
var bar = new foo(2)
console.log(bar.a)		// 2
``` 
_ps：优先级------>new绑定>显示绑定>隐式绑定>默认绑定_
### 判断this
1、函数是否在new中调用(new绑定)？如果是的话this绑定是新的对象
2、函数是否通过call、apply(显示绑定)或者硬绑定的调用？如果是的话this绑定的是制定对象
3、函数是否在某个上下文对象中调用(隐式绑定)？如果是的话，this绑定到那个上下文对象中
4、如果都不是的话，使用默认绑定，在严格模式下，就绑定到undefined上，否则绑定到全局对象上。
##### 例外
```bash
function foo(){
	console.log(this.a)
}
var a = 2
foo.call(null)	// 默认绑定
///////////////////////////////////
// 科里化
function foo(a, b) {
	console.log("a:" + a +" , b: " + b)
}
foo.apply(null, [2,3])	// a:2,b:3
var bar = foo.bind(null, 2)
bar(3)
///////////////////////////////////
// 间接引用
function foo() {
	console.log(this.a)
}
var a = 2
var o = {a:3, foo: foo}
var p = {a:4}
o.foo() 	// 3
(p.foo = o.foo)() 	// 2
// 复制表达式p.foo = o.foo的返回值是目标函数的引用，因此调用位置是foo()而不是p.foo或者o.foo
```
### 对象
在string中，本身的字符串“I am a string”并不是一个对象，而是一个字面量，在使用了对象的方法之后，javascript会自动将其转换成一个string对象
null和undefined没有对应的构造函数，他们只有文字形式。相反，Date只有构造函数，没有文字形式。
对于Object，Array，Function和RegExp来说，无论是文字形式还是构造形式，他们都是对象不是字面量。