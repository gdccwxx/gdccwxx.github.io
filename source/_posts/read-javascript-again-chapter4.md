---
title: JavaScript高级程序设计重读---4章
date: 2017-07-11 11:54:31
tags: JavaScript
dir: JavaScript
keywords: JavaScript高级程序设计
---
### 变量、作用域、和内存问题
#### 引用类型
Javascript不允许直接访问内存中的位置，意思位不能直接操作对象的内存空间。在操作对象时，实际上是在操作对象的引用而不是实际的对象。为此，引用类型的值是按引用访问的
```
var obj1 = new Object();
var obj2 = obj1;
obj1.name = 'gdccwxx'
obj2.name   // gdccwxx
```
对象是存在堆中，JavaScript只能引用堆中的Object。如图
![heap](heapObject.png)
而由于复制后的两个变量对象都指向堆内存中的一个Object，因此改变一个后，另一个也会随着改变
##### 函数在对象的传递是按值传递
```
unction setName(obj){
    obj.name = 'gdccwxx'
    obj = new Object();
    obj.name = 'guo'
}
var person = new Object();
setName(person)
person.name     // gdccwxx
```
解释：由于传入的person给obj复制了一份引用。因此一开始的时候是obj和person引用的是同一个。而第二段代码中，由于obj改变了新的引用。在改变之前，使person的name发生改变。而之后引用新的Object，因此person.name依然是gdccwxx。在函数执行之后，obj立即被销毁。
#### 检测类型
利用typeof检查五个基本类型，而对于对象的类型检测，则采用instanceof
result = variable instanceof constructor

```
person instanceof Object    //true
pattern instanceof  RegExp  //true
```
#### 作用域
通常来说，一段程序代码中所用到的名字并不总是有效/可用的，而限定这个名字的可用性的代码范围就是这个名字的作用域。
##### 延长作用域
利用with，以及try-catch语句中可以延长作用域
##### 没有块级作用域
```
if(true){
    var color = 'blue'
}
color // blue
for(var i = 0;i<10;i++){
    doSomething(i)
}
i // 10
```
从上面可以看出，在花括号中是不算作用域的。因此，在es5的下是没有块级作用域的
#### 垃圾收集
JavaScript是具有自动手机垃圾的机制的
##### 标记清除
当变量进入环境时(如在函数声明一个变量时)九江变量标记位’进入环境’。从逻辑上讲，永远不能释放进入环境变量所占用的内存。当变量离开环境时，则将其标记为’离开环境‘
##### 引用计数
引用一次，引用次数+1，引用另外一个值，引用-1，当到达0时，将其清除。
Bug：循环引用时，导致无法清除。多个引用存在时，导致内存消耗而崩溃。
#### 性能问题
IE6使用内存分配，就是256个变量，4096个对象(或数组)字面量和数组元素或者64KB字符串执行自动清理。由于频繁清理，导致严重性能问题
IE7的垃圾收集机制，初始值和IE6相等，如果垃圾手机里程回收的内存分配量低于15%，则变量、字面量和数组元素的临界值就会翻倍。如果历程回收了85%，则重回默认值
#### 内存管理
位确保占用最少的内存可以让页面获得更好的性能，优化内存的最佳方式。就是位执行的代码只保存必要的数据。一旦数据不在游泳，最好通过其值设为null来释放其引用。这叫接触引用。
#### 小结 
通过本章的学习，让我更理解了js这门语言的垃圾清理以及变量问题。采用简单的思路可以解决更好的问题。今后的coding会采用更简单，更高效的使用方法去解决问题