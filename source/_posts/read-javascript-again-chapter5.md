---
title: JavaScript高级程序设计重读---5章
date: 2017-07-12 12:01:33
tags: JavaScript
dir: JavaScript
---
### 引用类型
#### Object类型
1、JavaScript会将对象的属性自动转换成字符串
```
var person = {
    "name":'dechen',
    "age": 29,
    5:true
}
全等于
var person = {
    "name":'dechen',
    "age": 29,
    "5": true
}
```
_ps:最后一个属性后面是不添加逗号的，如果添加，在IE7即更早之前版本和Opera出现错误_

2、两种访问对象的方法。

(1)在对象后面使用.来访问对象的属性
(2)使用['']来访问对象的属性
```
var person = {
    "name":'dechen',
    "age": 29
}
person.name         // dechen
person['name']      // dechen
```
第二种方法有好处，在对象的属性有空格的时候，只能用第二种
#### Array类型
数组是一组按序排列的值，相对地，对象的属性名称是无序的。从本质上讲，数组是按次序排列的一组值，数组是一种特殊的对象。
```
var arr = ['a', 'b', 'c'];
Object.keys(arr);// ["0", "1", "2"]
```
JavaScript的数据类型分为：值类型和引用类型(地址值)；而常见的引用类型有Object和Array／数组的存储模型中，如果是诸如Number,String之类的类型数据会被直接压入栈中，而引用类型只会压入对该值的一个索引（即C中所说的保存了数据的指针）。这些数据时储存在堆中的某块区间中，堆栈并不是独立的，栈中也可以在堆中存放。
##### 数组的创建
var arrayObj = new Array();　//创建一个数组
var arrayObj = new Array(size);　//创建一个数组并指定长度，注意不是上限，是长度
var arrayObj = new Array([element0[, element1[, ...[, elementN]]]]);　//创建一个数组并赋值
var arrayObj = []
##### 数组的检测
value instanceof Array  // true or false
Array.isArray(value)    // true or false
##### 转换方法
调用Array.prototype.toString()方法，将Array转换成字符串
##### 数组的几种操作方法

| 方法 | 解释 |
|---|---|
|shift |获取数组的第一项并返回，减少数组的length值|
|unshift |在数组前端添加任意个项并返回新数组的长度|
|pop |从数组某位移除最后一项，减少数组的length值|
|push |接受任意个参数，把他们逐个添加到数组末尾，病返回修改后数组的长度|
|reverse |不接受参数，将数组项的顺序翻转|
|sort |调用每个数组项的toString()转型方法，然后比较的到字符串，已确定如何重排，其返回值和reverse都是排序后的数组|
|concat |创建一个数组副本，将参数添加到副本之后。接受一个或多个参数，返回连接后的数组|
|slice |接受一个或两个参数，即要返回项的起始位置和结束位置，只有一个参数返回从指定位置到末尾项所有元项|
|splice |(1)删除：指定两个参数，要删除的第一项的位置和要删除的项数(2)插入：指定三个参数，起始位置，0(要删除的项数)和要插入的个项。如果要插入多项，则传入多个参数(3)替换：指定三个参数：起始位置、要删除的项数和要插入的任一项。插入和删除的项数不必相等|
|indexOf |从数组的开头位置(0)开始向后查找，没找到返回-1|
|lastIndexOf |从数组的最后位置(length-1)开始向前查找，没找到返回-1|
|every |对数组的每一项都运行给定函数，如果该数组的每一项都返回true，则返回true|
|filiter |对数组的每一项运行给定函数，返回该函数会返回true的项组成的数组|
|forEach |对数组的每一项运行给定的函数，这个方法没有返回值|
|map |对数组的每一项运行给定函数，返回每次函数调用的结果组成的数组|
|some |对数组中的每一项运行给定函数，任意一项返回true，则返回true|
|reduce |从数组的第一项开始，逐个遍历到最后|
|reduceRight |从数组的最后一项开始，逐个遍历到第一个|

```
var color = ['red','green']
// shift
var item1 = color.shift()
item1       // 'red'   color = ['green']   color.length = 1
// unshift
var item2 = color.unshift('red','blue')
item2       // 3    color = ['red','blue','green']
// pop 
var item3 = color.pop()
item3       // green    color=['red','blue'] color.length = 2
// push
var item4 = color.push('gray')
item4       // 3    color = ['red','blue','gray']   color.length = 3
// reverse
color.reverse() //color = ['gray','blue','red']
// sort
function compare(value1,value2){
    if(value1 < value2){
        return 1;
    }else if(value1 > value2){
        return -1
    }else {
        return 0
    }
}
color.sort(compare)     //["red", "gray", "blue"]
// concat
var color2 = color.concat('red')
color2      //["red", "gray", "blue", "red"]
// slice
var removed1 = color.slice(1)
var removed2 = color.slice(1,3)
removed1    // "gray,blue,red"
removed2    // "gray,blue"
// splice
var removed3 = color.splice(0,1)    // 删除第一项
removed3    // 'red'
var removed4 = color.splice(1,0,'origin','pink')    // 从位置1插入两项
removed4    // 'red,origin,pink,gray,blue,red'
var removed5 = color.splice(1,1,'purple')           // 插入一项，删除一项
removed5    // 'red,purple,blue,red'
// indexOf
var item10 = color.indexOf('blue')
item10      // 2
// lastIndexOf
var item11 = color.indexOf('red')
item11      // 3
// every
var item12 = color.every(function(item, index, array)){     //参数为item，迭代到的元素
    return item == 'red'            // index,索引，array，数组本身
}
item12      // false
// filiter 
var item13 = color.filiter(function(item,index,array)){
    return (item == 'red')
}
item13      // red,red
// forEach 
color.forEach(function(item,index,array)){
    //执行某些操作
}
// map
var item15 = color.map(function(item,index,array)){
    return ('color is ' +item)
}
item15      // ["color is red", "color is gray", "color is blue", "color is red"]
// some
var item16 = color.some(function(item, index, array)){     //参数为item，迭代到的元素
    return item == 'red'            // index,索引，array，数组本身
}
item16      // true
// reduce()
var item17 = color.reduce(function(prev,cur,index,array)){
    return (prev + ' + ' cur)
}
item17      // "red + gray + blue + red"
var item18 = color.reduceRight(function(prev,cur,index,array)){
    return (prev + ' + ' cur)
}
item18      // "red + blue + gray + red"

```
#### Date类型
从国际时间1970年1月1日零时开始，可以精确到之后的100 000 000年
##### toString,toLocaleString
```
var date = new Date()
date
Wed Jul 12 2017 15:39:22 GMT+0800 (CST)
date.toLocaleString()
"7/12/2017, 3:39:22 PM"
date.toString()
"Wed Jul 12 2017 15:39:22 GMT+0800 (CST)"

```
如果是toString()，会直接返回标准的格式；
如果是toLocaleString()，先判断是否指定语言环境（locale），指定的话则返回当前语言环境下的格式设置（options）的格式化字符串；没有指定语言环境（locale），则返回一个使用默认语言环境和格式设置（options）的格式化字符串。
##### 日期格式的方法
| 方法 | 解释 |
|---|---|
|toDateString |特定显示的格式显示星期几，月，日，年|
|toTimeString |显示时，分，秒|
|toLocalDateString |显示地区的星期几，月，日，年|
|toLocalTimeString |显示地区的时，分，秒|
|toUTCString |显示完整格式的UTC日期|
|toLocaleString |区别如上|
|toString |区别如上|

```
var date = new Date()
date.toDateString()
"Wed Jul 12 2017"
date.toTimeString()
"15:49:48 GMT+0800 (CST)"
date.toLocaleDateString()
"7/12/2017"
date.toLocaleTimeString()
"3:49:48 PM"
date.toUTCString()
"Wed, 12 Jul 2017 07:49:48 GMT"

```

#### RegExp类型
##### 实例属性

| 方法 | 解释 |
|---|---|
|global |布尔值，表示是否设置了g|
|ignoreCase |布尔值，表示是否设置了i|
|lastIndex |整数，表示开始搜索下一个匹配的字符标志，从0算起|
|multiline |布尔值，表示是否设置了m标志|
|sorce |正则表达式的字符串表示|
##### 实例方法
exec —接受一个参数，即要应用模式的字符串，然后返回包含一个匹配信息的数组，或者没有匹配返回null
test —接受一个字符串参数，在该模式下匹配成功返回true，否则返回false(只要存在即返回true)
```
var text = 'cat, bat, sat, fat'
var pattern = /.at/;
var matches = pattern.exec(text)    
matches[0]      //cat
matches.index   // 0
var text = "456000-00-000123"
var pattern = /\d{3}-\d{2}-\d{2}/
pattern.test(text)      // true

```
#### Function类型
每个函数都是Function类型的实例，而且都有与其他引用类型一样具有属性和方法。由于函数是对象，因此函数名实际上也是一个指向函数的指针，不会与某个函数绑定。
既然函数名是一个指针，所以JavaScript没有重载。
**ps：访问函数指针时，应该不加圆括号**
##### 函数表达式和函数声明
由于JavaScript中有函数声明解析器，在所有函数执行前，会将函数声明提升至顶端。因此，函数表达式和函数声明会有一些区别
```
sum1(10,11)     //21
function sum1(num1,num2){
    return num1+num2
}
sum2(10,12) //Uncaught TypeError: sum2 is not a function
var sum2 = function (num1,num2){
    return num1+num2
}
```
其他无明显差别
##### callee caller
callee被调用者
caller调用者
mdn不建议使用
##### 函数的属性和方法
```
function F1(a,b){
    //
}
function F2(){
    //
}
F1.length // 2
F2.length // 0
```
函数的length属性代表参数的个数
##### call与apply
```
function sum(num1,num2){
    return num1+num2
}
function callSum(num1, num2){
    return sum.call(this,num1,num2)
}
callSum(10,10)  //20
function sum(num1,num2){
    return num1+num2
}
function callSum(num1, num2){
    return sum.call(this,arguments)
}
callSum(10,10)  //20
```
call和apply是两个非继承而来的方法，apply接受两个参数，一个是运行时函数的作用域，另一个是arguments对象或array实例；而call方法第一个参数是运行时函数作用域，其他参数是传入字面量。必须逐个列举出来
```
window.color = 'red'
var o = {
    color:'green'
}
function sayCOlor(){
    console.log(this.color)
}
sayCOlor.call(this)     //red
sayCOlor.call(window)   //red
sayCOlor.call(o)        //green
```
call,apply的最大好处是让其扩充作用域，且实现松耦合

bind是创建一个实例，其this值会被绑定到传给bind函数的值
```
window.color = 'red'
var o = {
    color : 'blue'
}
function sayColor(){
    console.log(this.color)
}
var objectSayColor = sayColor.bind(o)
objectSayColor()    //blue
```

#### 基本包装类型
##### Boolean类型
```
var falseObject = new Boolean(false)
var result = falseObject  && true
result // true
var falseValue = false
result = falseValue && true
result // false
typeof falseObject  // object
typeof falseValue   // boolean
falseObject instanceof Boolean  //true
falseValue instanceof Boolean   //false

```
基本类型布尔值与Boolean对象有一定差别，书上建议永远不要使用Boolean对象
##### Number类型
```
var numberObject = new Number(10)
numberObject    // Number {[[PrimitiveValue]]: 10}
numberObject.toString() // "10"
numberObject.valueOf()  // 10
```
Number类型重写了valueOf(),toLocaleString(),toString()，重写后，valueOf返回基本类型值
基本类型的几个方法

1、toFixed // 有一个参数，代表保留几位小数
2、toExponential // 指数表示法，表示制定输出结果中小数位数
3、toPrecision // 接受一个参数，合理的调用toFixed和toExponential
4、toString // 接受一个参数，代表转换成几进制
```
var num = 10
num.toString()  //10
num.toString(1)  //1010
num.toFixed(2)  //10.00
num.toExponential(1)  //1.0e+1
var nums = 99
num.toPrecision(1)  //1e+2
num.toPrecision(2)  // 99
num.toPrecision(3)  // 99.0

```
##### String类型
1、字符方法
charAt —以单个字符串的形式返回给定位置的字符
charCodeAt —以单个字符串的形式返回给定位置的字符编码
```
var stringValue = 'hello world'
stringValue.charAt(1)       // e
stringValue.charCodeAt(1)   // 101
```
2、字符串方法
slice —接受两个参数，第一个是指定位置，第二个位结束位置，为负数从后往前切取
substr —接受两个参数，第一个是指定位置，第二个是结束位置，为负数从0往后开始
substring —接受两个参数，第一个是指定位置，第二个是字符个数，为负数从后往前切取
3、字符串位置
indexOf —接受两个参数，第一个是寻找字符，第二个是指定位置，默认从0开始往后
lastIndexOf —接受两个参数，第一个是寻找字符，第二个是指定位置，默认从后开始往前
4、trim
将字符串前后空格去除
5、大小写转换方法
toLowerCase //转换为小写
toUpperCase //转换为大写
toLocaleLowerCase
toLocaleUpperCase
6、replace
采用两个参数，第一个是匹配的正则表达式，第二个是替换内容
7、localeCompare方法
比较两个字符串，返回1,0，-1
8、fromCharCode方法
接受多个参数，将ASCII码转换成对应的字符
##### 单体内置对象
1、Global对象
URI编码方法
(1)encodeURI，将空格转换成%20
(2)encodeURIComponent,将所有非字符转换成对应编码
(3)decodeURI，将encodeURI转换的uri反编码
(4)decodeURIComponent，将encodeURIComponent转换的uri反编码
2、eval方法
只接受一个参数，将字符串解析成JavaScript代码
```
eval('console.log(123)')  // 123

```
#### 小结
通过本章学习，有许多细致的方法以前没有使用过的现在很多都理解了。还有数组的存储，以前只是一个黑匣子对于我而言。现在能够认清它的本质，能对以后的代码优化有更好的帮助。