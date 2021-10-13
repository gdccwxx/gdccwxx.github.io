---
title: Decorator 最佳实践
date: 2021-09-05 20:22:01
tags: typescript
dir: typescript
keywords:
  - typescript
  - javascript
  - decorator
  - 装饰器
---
## 前言
很多语言和方法都有 AOP 编程。AOP 的好处是只需要写一次函数检查，在函数调用前只做引用即可。极大的减少了重复代码的编写。

试想一下：在函数入参检查类型时需要反复用 `typeof parameter === '类型'` 来做检查时一件非常痛苦的事情。虽然用了 `Typescript`，但只是解决了编码时候的类型校验，而运行时的校验依旧需要编码来做检查。

本篇介绍的 `Decorator` 用法，就是为了解决这一困扰而出现的。它不仅一行代码解决了运行时的入参类型检查；还能用一行代码做函数权限检查，只让有权限的人调用；更能一行代码解决入参和结果的日志打印。让代码更容易维护的同时，也更专注于业务的实现。

如果您对例子感兴趣，可以直接到[使用举例](#使用举例)


### 啥是 Decorator?
Decorator 是 ES6 中的提案之一，它实际上是个 wrapper，可以为类、属性或函数提供额外功能。举个🌰：
```ts
function f(key: string): any {
  console.log("evaluate: ", key);
  return function () {
    console.log("call: ", key);
  };
}

@f("Class Decorator")
class A {
  constructor(@f("Constructor Parameter") foo) {}

  @f("Instance Method") // 1
  method(@f("Instance Method Parameter") foo) {} // 2

  @f("Instance Property")
  prop?: number;
}

// 基本上，装饰器会的行为就是下面这样：

@f()
class A

// 等同于
A = f(A) || A
```

## 使用前的准备
虽然 Decorator 只是一个提案，但可通过工具来使用它：

### Babel:
> babel-plugin-syntax-decorators
> babel-plugin-transform-decorators-legacy

### Typescript:
命令行：
```bash
tsc --target ES5 --experimentalDecorators
```
tsconfig.json:
```json
{
  "compilerOptions": {
    "target": "ES5",
    "experimentalDecorators": true
  }
}
```



## 定义
![decorators](xmind.png)
### 类装饰器
📌 参数：
- `target`: 类的 `构造器（constructor）`

⬅️ 返回值: undefined | 替代原有构造器

因此，类装饰器适合用于继承一个现有类并添加一些属性和方法。
```ts
function rewirteClassConstructor<T extends { new (...args: any[]): {} }>(constructor: T) {
  return class extends constructor {
    words = "rewrite constructor";
  };
}
 
@rewirteClassConstructor
class Speak {
  words: string;
 
  constructor(t: string) {
    this.words = t;
  }
}
 
const say = new Speak("hello world");
console.log(say.words) // rewrite constructor
```

### 属性装饰器

📌 参数: 
- `target`: 对于静态成员来说是类的构造器，对于实例成员来说是类的原型链
- `propertyKey`: 属性名称

⬅️ 返回值: 返回的结果将被忽略

除了用于收集信息外，属性装饰器也可以用来给类添加额外的方法和属性。 例如我们可以写一个装饰器来给某些属性添加监听器。
```ts
import "reflect-metadata";

function capitalizeFirstLetter(str: string) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

function observable(target: any, key: string): any {
  // prop -> onPropChange
  const targetKey = "on" + capitalizeFirstLetter(key) + "Change";

  target[targetKey] = function (fn: (prev: any, next: any) => void) {
      let prev = this[key];
      // tsconfig.json target to ES6
      Reflect.defineProperty(this, key, {
        set(next) {
          fn(prev, next);
          prev = next;
        }
      })
    };
}

class C {
  
  @observable
  foo = -1;

  onFooChange(arg0: (prev: any, next: any) => void) {}
}

const c = new C();

c.onFooChange((prev, next) => console.log(`prev: ${prev}, next: ${next}`))

c.foo = 100; // -> prev: -1, next: 100
c.foo = -3.14; // -> prev: 100, next: -3.14
```


### 方法装饰器
📌 参数：
- `target`: 对于静态成员来说是类的构造器，对于实例成员来说是类的原型链
- `propertyKey`: 属性名称
- `descriptor`: 属性的 [描述器](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Object/getOwnPropertyDescriptor)

⬅️ 返回值：undefined | 替代属性的描述器。

方法装饰器`descriptor`的key为：
```
value
writable
enumerable
configurable
```

通过这个参数我们可以修改方法原本的实现，添加一些共用逻辑。 例如我们可以给一些方法添加打印输入与输出的能力:
```ts
function logger(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const original = descriptor.value;

  descriptor.value = function (...args) {
    console.log('params: ', ...args);
    const result = original.call(this, ...args);
    console.log('result: ', result);
    return result;
  }
}

class C {
  @logger
  add(x: number, y:number ) {
    return x + y;
  }
}

const c = new C();
c.add(1, 2);
// -> params: 1, 2
// -> result: 3
```

### 访问器装饰器
📌 参数：
- `target`: 对于静态成员来说是类的构造器，对于实例成员来说是类的原型链
- `propertyKey`: 属性名称
- `descriptor`: 属性的 [描述器](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Object/getOwnPropertyDescriptor)

⬅️ 返回值：undefined | 替代属性的描述器。


访问器装饰器`descriptor`的key为：
```
get
set
enumerable
configurable
```

访问器装饰器总体上讲和方法装饰器很接近，唯一的区别在于描述器中有的key不同例如，我们可以将某个属性设为不可变值：
```ts
function immutable(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const original = descriptor.set;

  descriptor.set = function (value: any) {
    return original.call(this, { ...value })
  }
}

class C {
  private _point = { x: 0, y: 0 }

  @immutable
  set point(value: { x: number, y: number }) {
    this._point = value;
  }

  get point() {
    return this._point;
  }
}

const c = new C();
const point = { x: 1, y: 1 }
c.point = point;

console.log(c.point === point)
// -> false
```

### 参数装饰器
📌 参数：
- `target`: 对于静态成员来说是类的构造器，对于实例成员来说是类的原型链
- `propertyKey`: 属性的名称(注意是方法的名称，而不是参数的名称)
- `paramerterIndex`: 参数在方法中所处的位置的下标

⬅️ 返回值：返回的值将会被忽略。

单独的参数装饰器能做的事情很有限，它一般都被用于记录可被其它装饰器使用的信息。
```ts
// parameter.ts
import "reflect-metadata";

function required(target: Object, propertyKey: string | symbol, parameterIndex: number) {
    let existingRequiredParameters: number[] = Reflect.getOwnMetadata('required', target, propertyKey) || [];
    existingRequiredParameters.push(parameterIndex);
    Reflect.defineMetadata('required', existingRequiredParameters, target, propertyKey);
}

function validate(target: any, propertyName: string, descriptor: TypedPropertyDescriptor<Function>) {
    let method = descriptor.value!;
   
    descriptor.value = function () {
      let requiredParameters: number[] = Reflect.getOwnMetadata('required', target, propertyName);
      if (requiredParameters) {
        for (let parameterIndex of requiredParameters) {
          if (parameterIndex >= arguments.length || arguments[parameterIndex] === undefined) {
            throw new Error("Missing required argument.");
          }
        }
      }
      return method.apply(this, arguments);
    };
  }

class BugReport {
    type = "report";
    title: string;
   
    constructor(t: string) {
      this.title = t;
    }
   
    @validate
    print(@required verbose: boolean) {
      if (verbose) {
        return `type: ${this.type}\ntitle: ${this.title}`;
      } else {
       return this.title; 
      }
    }
  }

export const report = new BugReport('mode error');
```

```js
// test.js

const { report } = require('./paramerter.js');
console.log(report.print()); // Error: Missing required argument.
```

## 执行顺序
不同类型的装饰器执行顺序是明确的：
1、 实例成员：参数装饰器 -> 方法/访问器/属性 装饰器
2、 静态成员：参数装饰器 -> 方法/访问器/属性 装饰器
3、 构造函数：参数装饰器
4、 类装饰器
例如：

```ts
function f(key: string): any {
  console.log("evaluate: ", key);
  return function () {
    console.log("call: ", key);
  };
}

@f("Class Decorator")
class A {
  @f("Static Property")
  static prop?: number;

  @f("Static Method")
  static method(@f("Static Method Parameter") foo) {}

  constructor(@f("Constructor Parameter") foo) {}

  @f("Instance Method")
  method(@f("Instance Method Parameter") foo) {}

  @f("Instance Property")
  prop?: number;
}

// 执行顺序
evaluate:  Instance Method
evaluate:  Instance Method Parameter
call:  Instance Method Parameter
call:  Instance Method
evaluate:  Instance Property
call:  Instance Property
evaluate:  Static Property
call:  Static Property
evaluate:  Static Method
evaluate:  Static Method Parameter
call:  Static Method Parameter
call:  Static Method
evaluate:  Class Decorator
evaluate:  Constructor Parameter
call:  Constructor Parameter
call:  Class Decorator
```

然而，在同一方法中的不同参数构造器顺序是相反的，最后参数回的装饰器会先被执行：
```ts

function f(key: string): any {
  console.log("evaluate: ", key);
  return function () {
    console.log("call: ", key);
  };
}

class B {
  @f('first')
  @f('second')
  method() {}
}

// 执行顺序
evaluate:  first
evaluate:  second
call:  second
call:  first
```


## 使用场景
- Before/After钩子。
- 监听属性改变或者方法调用。
- 对方法的参数做转换。
- 添加额外的方法和属性。
- 运行时类型检查。
- 自动编解码。
- 依赖注入。

### 使用举例
- 日志打印
```ts
function f(): any {
  return function (target, key, descriptor) {
    let method = descriptor.value;
    descriptor.value = function () {
      console.log('param: ', Array.from(arguments));
      const value = method.apply(this, arguments);
      console.log('result: ', value);
      return value
    };
  };
}

class B {
  @f()
  say(name: string) {
      return `name is ${name}`;
  }
}
```
- 鉴权:
```ts
function auth(user) {
  return function(target, key, descriptor) {
    var originalMethod = descriptor.value; // 保留原有函数
    if (!user.isAuth) {
      descriptor.value = function() { // 未登录将返回提示
        console.log('当前未登录，请登录!');
      }
    } else {
      descriptor.value = function (...args) { // 已登录将原有函数
        originalMethod.apply(this, args);
      }
    }
    return descriptor;
  }
}

@auth(app.user)
function handleStar(new) {
  new.like++;
}
```

- 类型检查
```ts
import "reflect-metadata";
const stringMetaDataTag = "IsString";
 
function IsString(target: Object, propertyKey: string | symbol, parameterIndex: number) {
  let existingRequiredParameters: number[] = Reflect.getOwnMetadata(stringMetaDataTag, target, propertyKey) || [];
  existingRequiredParameters.push(parameterIndex);
  Reflect.defineMetadata( stringMetaDataTag, existingRequiredParameters, target, propertyKey);
}
 
function validate(target: any, propertyName: string, descriptor: TypedPropertyDescriptor<Function>) {
  let method = descriptor.value!;
 
  descriptor.value = function () {
    let stringMetaTags: number[] = Reflect.getOwnMetadata(stringMetaDataTag, target, propertyName);
    if (stringMetaTags) {
      for (let parameterIndex of stringMetaTags) {
        const value = arguments[parameterIndex];
        if (!(value instanceof String || typeof value === 'string')) {
            throw new Error('not string');
        }
      }
    }
    return method.apply(this, arguments);
  };
}


export class A {
    a: string = '123';
    
    @validate
    value (@IsString value: string) {
        console.log(value);
        this.a = value;
    }
}
```

## 写在最后
笔者在 后台接口、Js Bridge、React 项目上都有实践过。不得不说，装饰器模式在面向切面编程(AOP)几乎是 “最佳实践”，极大的提升了编程效率。也希望这篇文章能帮助到你😊


### npm 包
[class-validator](https://github.com/typestack/class-validator)
[core-decorators](https://github.com/jayphelps/core-decorators)
[Nest 后台框架](https://github.com/nestjs/nest)

### 参考链接
[tc39-proposal](https://github.com/tc39/proposal-decorators)
[typescript](https://www.typescriptlang.org/docs/handbook/decorators.html)
[a-complete-guide-to-typescript-decorator](https://saul-mirone.github.io/a-complete-guide-to-typescript-decorator/)

