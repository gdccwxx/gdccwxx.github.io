---
title: JavaScript高级程序设计重读---7章
date: 2017-07-13 16:01:13
tags: JavaScript
dir: JavaScript
---
### 函数表达式
函数表达式和函数声明中，有以下因为函数声明有函数声明提升器，因此大多数用函数声明，但是函数表达式也有其运用场景
```
// 这种情况可能造成意想不到的情况
if(condition){
    function sayHi(){
        alert('hi')
    }
}else {
    function sayHi(){
        alert('hello')
    }
}
// 应该这样
var sayHi
if(condition){
    sayHi = function (){
        alert('hi')
    }
}else {
    sayHi = function (){
        alert('hello')
    }
}

```
#### 递归
```
function factorial(num){
    if(num <= 1){        
        return 1
    }else {
        return num* factorial(num-1)
    }
}
// 但是以下情况会出错
var another = factorial
factorial = null
alert(another(4))   // 出错，因为factorial变量设置位null，结果现在factorial已经不再是函数
//通过以下一种情况解决
function factorial(num){
    if(num <= 1){        
        return 1
    }else {
        return num* arguments.callee(num-1)
    }
}
// 上种情况在严格模式下有问题。这种情况可以代替函数名，在严格模式下依然可以生效
var factorail = (function f(num){
    if(num <= 1){
        return 1
    }else{
        return num * f(num -1)
    }
})
```
#### 闭包
闭包（closure）是Javascript语言的一个难点，也是它的特色，很多高级应用都要依靠闭包实现。
首先理解活动对象。活动对象是c语言里面称之为形参。在内存中，形参往往是在当前环境作用域的首位，其次是上一个环境，以此类推。因此其作用域链是由当前环境依次向上。
正常函数是执行完成之后，函数内参数和变量将会清除。因此无法访问该变量。闭包是一种将当前函数返回，导致当前活动对象无法被销毁，到函数外即可取到变量。上代码
```
function create(){
    var result = new Array();
    for(var i = 0;i < 10; i++){
        result[i] = function (num){
            return function(){
                return num
            }
        }(i)
    }
    return result
}
```
此函数可以获取到i的值。通过访问不同的result函数以达到目的
因此可以模仿块级作用域。
```
(function(){
// 这里是块级作用域
}())
```
#### 小结
通过这章学习，还是不明白几个模式。但是对闭包有了很大的了解，知道闭包的原理。也明白了闭包的大多数应用场景。对今后的学习更加自信了。