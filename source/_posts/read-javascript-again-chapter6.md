---
title: JavaScript高级程序设计重读---6章
date: 2017-07-13 15:43:38
tags: JavaScript
dir: JavaScript
keywords: JavaScript高级程序设计
---
### 面向对象的程序设计
#### 属性类型
ECMAScript中有两种属性，数据属性和访问器属性
##### 数据属性
[[Configurable]] : 表示能否通过 delete 删除属性从而重新定义属性，能否修改属性的特性，或者能否把属性修改为访问器属性。
[[Enumerable]] : 表示能否通过 for-in 循环返回属性。
[[Writable]] : 表示能否修改属性的值。
[[Value]] : 包含这个属性的数据值。读取属性值的时候，从这个位置读；写入属性值时，把新值保存在这个位置。默认值是 undefined。

_ps：将Configurable修改为false之后，除了Writable可修改之外，Configurable，Enumerable都不可再修改。_

**Object.defineProperty可以为对象添加属性**
##### 访问器属性
[[Configurable]]：表示能否通过 delete 删除属性从而重新定义属性，能否修改属性的特性，或者能否把属性修改为数据属性。
[[Enumerable]]：表示能否通过 for-in 循环返回属性。
[[Get]]：在读取属性时调用的函数。默认值为 undefined。
[[Set]]：在写入属性时调用的函数。默认值为 undefined。

**get,set方法**
有时候希望访问属性时能返回一个动态计算后的值, 或希望不通过使用明确的方法调用而显示内部变量的状态.在JavaScript中, 能通过使用 getter 实现. 尽管可能结合使用getter和setter创建一个伪属性,但不能既使用getter绑定到一个属性上,同时又用该属性真实的存储一个值.
```
var book = {
    _year : 2004,
    edition : 1
};
Object.defineProperty(book,"year",{ 
    get : function () {
        alert(this._year);
    },
    set : function (newValue) {
        if (newValue > 2004) {
            this._year = newValue;
            this.edition += newValue - 2004;
        }
    }
});
book.year;      // 弹出窗口，显示 2004
book.year = 2005;
console.log(book.edition);   // 2
```
get，set方法可以动态的关注对象中变量的变化，可以使其他变量随着变化而变化。因此在某些情况下非常适用
定义多个属性Object.defineProperties(obj, props)
将defineProperty改为复数形式defineProperties，并将参数改为一个对象
```
var obj = {};
Object.defineProperties(obj, {
  "property1": {
    value: true,
    writable: true
  },
  "property2": {
    value: "Hello",
    writable: false
  }
  // 等等.
});
console.log(obj); // Object {property1: true, property2: "Hello"}
```
读取给定属性的特性**Object.getOwnPropertyDescriptor(obj, prop)** 返回指定对象上一个自有属性对应的属性描述符。（自有属性指的是直接赋予该对象的属性，不需要从原型链上进行查找的属性）
```
var man = {name: "gdc"};
console.log(Object.getOwnPropertyDescriptor(man,"name"));
// Object {value: "gdc", writable: true, enumerable: true, configurable: true}
Object.defineProperties(man,{
  name:{
    writable: false
  },
  age:{
    writable: true,
    value: 22
  }
});
console.log(Object.getOwnPropertyDescriptor(man,"name"));
// Object {value: "gdc", writable: false, enumerable: true, configurable: true}
console.log(Object.getOwnPropertyDescriptor(man,"age"));
// Object {value: 22, writable: true, enumerable: false, configurable: false}
var descriptor = Object.getOwnPropertyDescriptor(man,"age");
console.log(descriptor.value);         // 22
console.log(descriptor.configurable);  // false
console.log(descriptor.writable);      // true
console.log(descriptor.get);           // undefined
console.log(descriptor.set);           // undefined
```
读取当前属性，返回获取数据形式

#### 创建对象
##### 1、工厂模式：
为了解决多个类似对象声明的问题，我们可以使用一种叫做 工厂模式的方法，这种方法就是为了解决实例化对象产生大量重复的问题。
```
function createObject(name,age,profession){//集中实例化的函数
        var obj = new Object();
        obj.name = name;
        obj.age = age;
        obj.profession = profession;
        obj.move = function () {
            return this.name + ' at ' + this.age + ' engaged in ' + this.profession;
        };
        return obj;
    }
    var test1 = createObject('trigkit4',22,'programmer');//第一个实例
    var test2 = createObject('mike',25,'engineer');//第二个实例
    alert(test1.move());
    alert(test2.move());
```
**利:**
主要好处就是可以消除对象间的耦合，通过使用工程方法而不是new关键字。将所有实例化的代码集中在一个位置防止代码重复

**弊:**
大多数类最好使用new关键字和构造函数，可以让代码更加简单易读。而不必去查看工厂方法来知道。

**何时使用？**
1、当对象或组件涉及高复杂性时
2、当需要根据所在的不同环境轻松生成对象的不同实例时
3、当处理很多共享相同属性的小型对象或组件时

##### Constructor(构造器)模式
ECMAScript 中可以采用构造函数(构造方法)可用来创建特定的对象。 该模式正好可以解决以上的工厂模式无法识别对象实例的问题。
```
function Car(model,year,miles){//构造函数模式
    this.model = model;
    this.year = year;
    this.miles = miles;
    this.run = function () {
        return this.model + " has done " + this.miles + "miles";
    }
}
var Benz = new Car('Benz',2014,20000);
var BMW = new Car("BMW",2013,12000);
alert(Benz instanceof Car); //很清晰的识别他从属于 Car,true
console.log(Benz.run());
console.log(BMW.run());
```
**和工厂模式相比：**
1.构造函数方法没有显示的创建对象 (new Object());
2.直接将属性和方法赋值给 this 对象;
3.没有 renturn 语句。

##### 原型模式
```
function Person(){}
Person.prototype.name = "gdccwxx";  
Person.prototype.age =23;  
Person.prototype.sayName = function(){  
    console.log(this.name)  
};  
var person1 = new Person();  
person1.sayName()     // gdccwxx
var person2 = new Person();
person2.sayName()     // gdccwxx
person1.sayName == person2.sayName  // true

```
**Person类与构造函数，原型存在如下关系**

Person的原型是person1和person2的原型。而Person.prototype.constructor右指回了Person
使用isPrototypeOf()判断对详见是否存在这种关系
```
Person.prototype.isPrototypeOf(person1) // true
Person.prototype.isPrototypeOf(person2) // true

```
虽然对象实例访问保存在原型中的值，却不能通过对象实例重写原型中的值。如果在对象里面添加一个属性，该属性只会存在于对象实例中，而屏蔽原型。即
```
function Person(){}
Person.prototype.name = "gdccwxx";  
Person.prototype.age =23;  
Person.prototype.sayName = function(){  
    console.log(this.name)  
};  
var person1 = new Person();  
person1.sayName()     // gdccwxx
var person2 = new Person();
person2.sayName()     // gdccwxx
person1.name = 'guo'
person1.name    // guo
person2.name    // gdccwxx
delete person1.name 
person1.name    // gdccwxx
```
对象搜索属性中，先在实例中搜索，实例中有，则直接返回，实例中没有，则到其原型中查找。若在原型中未找到，则返回undefined；若找到则返回。因此，对person1实例添加name属性后，就屏蔽了原型里面的name，删除实例后的属性之后，又去原型里查找。
_ps：原型属性不可被delete掉_
hasOwnProperty()确定属性是否在实例上的方法
原型与in操作符
in有两种操作，第一种是在for-in循环中使用，另一种是会在通过对象能够访问的给定属性时返回true
```
function Person(){}
Person.prototype.name = "gdccwxx";  
Person.prototype.age =23;  
Person.prototype.sayName = function(){  
    console.log(this.name)  
};  
var person1 = new Person();  
var person2 = new Person();
person1.hasOwnProperty('name')  // 在原型上，返回false
'name' in person1       //能够访问，true
person1.name = 'guo'
person1.name            // guo
person1.hasOwnProperty('name')  // true
'name' in person1       //能够访问，true
person2.name            // guo
person2.hasOwnProperty('name')  //false
'name' in person2       // true
delete person1.name
person1.name            // gdccwxx
person1.hasOwnProperty('name')  // 在原型上，返回false
'name' in person1       //能够访问，true
```
Object.keys()方法，获取对象所有可枚举实例属性
```
function Person(){}
Person.prototype.name = "gdccwxx";  
Person.prototype.age =23;  
Person.prototype.sayName = function(){  
    console.log(this.name)  
};  
var keys = Object.keys(Person.prototype)
keys            // name,age,sayName
var p1 = new Person();
p1.name = 'guo'
p1.age = '20'
var p1keys = Object.keys(p1)
p1keys  // 'name,age'
// 获得所有实例属性，无论是否可枚举，使用Object.getOwnPropertyNames()
var keys = Object.getOwnPropertyNames(Person.prototype)
keys    // ["constructor", "name", "age", "sayName"]
// 也可以使用另一种原型定义方法，字面量方法
function Person(){}
Person.prototype = {
    name : 'gdccwxx',
    age : 20,
    sayName: function(){
        //
    }
}
//如果constructor很重要，也可以特意设定
Person.prototype = {
    constructor: Person,
    name : 'gdccwxx',
    age : 20,
    sayName: function(){
        //
    }
}
//这种重设constructor会导致其Enumerable属性变为true。如果要重设，应使用defineProperty
Object.defineProperty(Person.prototype, 'constructor',{
    enumerable: false,
    value: Person
})
```
由于是person指针指向Person的prototype，因此在Person任意改变prototype的情况下，会导致所有子元素都改变。因此大多都很少单独使用原型模式
**组合使用构造函数模式和原型模式**
将函数使用prototype模式，其他基本类型使用构造函数.可以达到节省内存，又拥有实例和副本。
```
function Person(name,age,job){
    this.name = name;
    this.age = age;
    this.job = job;
    this.friend = ['a','b']
}
Person.prototype = {
    constructor: Person,
    sayName : function(){
        console.log(this.name)
    }
}
var person1 = new Person('gdccwxx', 20 ,'SoftWare')
var person2 = new Person('guo', 10 ,'Doctor')
person1.friends.push('van')
person1.friend      // a,b,van
person2.friend      // a,b
person1.friend === person2.friend   //false
person1.sayName === person2.sayName   //true
```
#### 继承
##### 原型链
原型链是JavaScript的主要实现继承方法
```
function SuperType(){
    this.property = true
}
SuperType.prototype.getSuperValue = function(){
    return this.property;
}
function SubType(){
    this.subproperty = false
}
Subtype.prototype = new SuperType()
SubType.prototype.getSubValue = function(){
    return this.subproperty;
}
var instance = new SubType();
var instance = new SubType()
instance.getSuperValue()    //true
```
instance的原型连集成了SuperType方法
##### 寄生组合式继承
```
function inheritPrototype(subType, superType){
    var prototype = object(superType.prototype) // 创建对象
    prototype.constructor = subType             // 增强对象
    subType.prototype = prototype               // 指定对象
}
function SuperType(name){
    this.name = name;
    this.colors = ['red','blue','green']
}
SuperType.prototype.sayName = function(){
    return this.name
}
function SubType(name, age){
    SuperType.call(this, name)      
    this.age = age
}
inheritPrototype(SubType, SuperType);
SubType.prototype.sayAge = function(){
    return this.age
}
```
通过上述继承方式，少用了一次构造函数，并且因此避免了在SuperType.prototype上的不必要创建、多余的属性
##### 小结
通过本章的学习，深入理解了原型以及原型链上继承的问题。之前没用用过的defineProperty和prototype，都逐渐明白了其用处以及用法。通过原型链，构造函数等学习，让我对JavaScript的理解更上一步。以及对对象的理解更加深刻。不仅仅是属性以及value那么简单。对内存的分配以及效率的使用更加深刻。