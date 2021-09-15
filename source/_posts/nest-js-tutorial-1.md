---
title: NestJs 入门教程之一：初次上手
date: 2021-09-11 23:45:27
tags:
    - Javascript
    - Typescript
    - NestJs
dir: nestJs
keywords: NestJs 教程
---
自从 Node 出世以来，许多 Javascript 后端框架都曾处不穷，需求也十分庞大。

![nodejs](./nodejs.png)

Node 做后端已经成为前端的重要业务，随着前端业务的不断更迭，Node 也在前端领域也逐渐站稳脚跟，市场招聘需求逐渐旺盛，企业都抢着要。

尽管 Node 框架已经逐渐完善，但是国外非常火的框架 NestJs 教程却十分稀缺，国内教程也都良莠不齐，对初次上手者十分不友好。

本系列文章主要讲我在工作中遇到的问题与解决方案，并梳理成教程方式，希望对初学者有用。目标是经过此个系列文章，能搭建一套 NestJs 在日常编码过程中会用到的功能。

考虑到 NestJs 功能比较多，本教程会选较为常用的功能，分为四次次连载。

![nestjs](./nestjs.png)

# 一、NestJs 是啥
学习 NestJS 之前，先简单说一下，它到底是啥。

字面意思来讲，它是一个以 JS 代码的方式运行 JS 的框架。

从 [NestJs 官网](https://nestjs.com/) 来看，NestJS 是运行在服务端的一个 JS 框架。它运行时是 `JavaScript`，编程时使用`TypeScript`, 是结合灵活性、可扩展性的框架。并且结合了面向对象编程(OOP)、函数式编程(FP)和函数响应式编程(FRP)

它的特殊之处在于，以前使用 JS 方式写后台代码，现在通过写 TS, 再编译成 JS 运行。既包含了 JS 的灵活性，又有 TS 的约束。

# 二、NestJS 的优势
NestJS 最大的优势，是他基于 TypeScript。

后台接口需要清晰的入参和出参，需要对函数和接口强约束，维护时才能保证接口的可靠性。

而且，NestJs 的是基于 Express 的进行开发的，也就是说完美的复用成熟的生态，可以很方便的去市场找第三方包。

# 三、知识准备
由于 NestJs 是基于 Node 的环境，因此需要具备基础的知识。

- HTTP: 了解基本的 Get、Post 请求
- Node：基本明白接口请求，知道服务与接口关系即可
- Typescript：基本懂语法，能大致知道装饰器和 interface

最好之前用过 Node 相关服务，使用 Node 搭建过后台服务，但这不是必要的。

# 四、开发准备

1、安装 Node 环境：访问 [Node 下载地址](https://nodejs.org/en/download/). 下载安装后，Node >= 10.13.0 即可, 可通过命令行检查

```bash
node -v 
```

2、安装 NestJS cli

```bash
npm i -g @nestjs/cli
```

# 五、Hello World
## 创建 nest-test 项目
```
// step1
nest new nest-test

// step2 Which package manager would you
选择: npm
```

## 目录结构
这样就得到了 src/ 目录为这样的文件列表了
```
src
  |- app.controller.spec.ts // controller 的测试文件
  |- app.controller.ts      // controller，路由和预处理
  |- app.module.ts          // module，为模块注册用
  |- app.service.ts         // service 真正的逻辑
  |- main.ts                // 程序入口
```
NestJS 也主张的是 [MVC](https://zh.wikipedia.org/wiki/MVC) 的格式。

## module
![module](./module.png)

module 的作用是在程序运行时给模块处理依赖。好处是所有模块的依赖都可以在 module 中清晰明了的知道引用还是被引用

## controller
![controller](./controllers.png)

controller 的作用是处理请求，所有的请求会先到 controller，再经 controller 调用其他模块业务逻辑

## service
是真正处理业务逻辑的地方，所有的业务逻辑都会在这里处理。它可经过 module 引用其他模块的service，也可经过 module 暴露出去。


## hello-world
```
// step1: 进入目录
cd nest-test

// step2: 安装依赖或更新依赖
npm install

// step3: 运行程序
npm run start
```

最后浏览器访问url

```
// ✅
访问: http://localhost:3000/
// => Hello World!  
```
说明程序已经成功访问了！

# 六、生成新模块

## 执行命令
能访问新模块了，再进一步期望生成文件夹和文件夹的模块。NestJS cli 也支持用命令行形式来创建，这样就不需要做重复的创建文件的动作了。
```
nest g controller students
nest g service students
nest g module students
```

## 目录结构
再命令行分别执行以上三条命令，src/ 目录变成了如下样子
```
src
  |- app.controller.spec.ts
  |- app.controller.ts     
  |- app.module.ts         
  |- app.service.ts        
  |- main.ts               
  |- students/
        |- students.controller.spec.ts
        |- students.controller.ts     
        |- students.module.ts         
        |- students.service.spec.ts
        |- students.service.ts        
```

## 编辑文件
编辑如下文件:
```typescript
// students.service.ts
import { Injectable } from '@nestjs/common';

@Injectable()
export class StudentsService {
    ImStudent() {
        return 'Im student';
    }
}
```

```typescript
// students.controller.ts
import { Injectable } from '@nestjs/common';

@Injectable()
export class StudentsService {
    ImStudent() {
        return 'Im student';
    }
}
```

重启服务, 加上 dev 就能监听文件修改了。
```bash
npm run start:dev
```

最后浏览器访问url

```bash
// ✅
http://localhost:3000/students/who-are-you
// => Im student  
```

这样模块添加完成了

如果你看到了这里，说明你真的对 NestJS 很感兴趣。{% post_link nest-js-tutorial-2 下章 %}将会对接口再深入细化。

完整示例可以在 [github](https://github.com/gdccwxx/nest-test) 找到
