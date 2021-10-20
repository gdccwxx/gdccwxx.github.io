---
title: NestJs 入门教程之二：处理请求
date: 2021-09-12 10:06:06
tags:
    - javascript
    - typescript
    - nestJs
dir: nestJs
keywords: NestJs 教程
description: 这个系列的上一篇文章，教大家写了 hello world 和 新建 students 模块。但是，那只是很干的 Get 请求；即没有 Post 请求，也没有给参数做检查；更没有日志的使用。本篇接着往下讲，通过 NestJs 的原生能力，来实现 Post 请求，并做参数检查，最后利用原生日志模块实现标准化日志。
---
![nestjs](nestjs.png)

这个系列的{% post_link nest-js-tutorial-1 上一篇 %}文章，教大家写了 hello world 和 新建 students 模块。

但是，那只是很干的 Get 请求；即没有 Post 请求，也没有给参数做检查；更没有日志的使用。

本篇接着往下讲，通过 NestJs 的原生能力，来实现 Post 请求，并做参数检查，最后利用原生日志模块实现标准化日志。

完整示例可以在 [github](https://github.com/gdccwxx/nest-test) 找到。


# 一、Post 请求
经过上篇的介绍，总体请求先会经过 students.controller.ts -> 再到 students.service.ts。

在 students.service.ts 上新增 `Post` 方法
```typescript
// students.service.ts
import { Controller, Get, Post } from '@nestjs/common';

// ...
@Controller('students')
export class StudentsController {
    constructor(private readonly studentsService: StudentsService) {}
  
    // @Get('who-are-you') ...

    @Post('who-are-you')
    whoAreYouPost() {
        return this.studentsService.ImStudent();
    }
}
```

通过 curl 访问地址
```bash
// ✅
curl -X POST  http://127.0.0.1:3000/students/who-are-you
// => Im student%
```

通过替换装饰器，就可以快速实现 `Post` 请求。

# 二、请求参数
正常请求都会加上参数，`Get` 和 `Post` 方法加参数略有不同。

先看 Get 请求

## Get 请求参数
Get 请求的参数一般会放在 URL 上，这是 `@Query` 装饰器就派上用场了。

先改造 controller


```typescript
// students.controller.ts
import { Controller, Get, Post, Query } from '@nestjs/common';
// ...
@Controller('students')
export class StudentsController {
    constructor(private readonly studentsService: StudentsService) {}
  
    @Get('who-are-you')
    whoAreYou(@Query('name') name: string) {
        return this.studentsService.ImStudent(name);
    }
}
```

再改造 service

```typescript
// students.service.ts
import { Injectable } from '@nestjs/common';

@Injectable()
export class StudentsService {
    ImStudent(name?: string) {
        return 'Im student ' + name;
    }
}
```

通过浏览器访问 url
```url
// ✅
http://localhost:3000/students/who-are-you?name=gdccwxx
// => Im student gdccwxx
```
这样 Get 请求就能获取到 name 参数了

## Post 参数
Post 参数有些不同，会用到 [DTO](https://baike.baidu.com/item/DTO/16016821) 的传输。因为数据通过 HTTP 传输是文本类型，因此需要将文本类型转化成代码可识别的变量。

新建 students.dto.ts
```typescript
// src/students/dtos/students.dto.ts
export class StudentDto {
    name: string;
}
```

编辑 students.controller.ts
```typescript
// students.controller.ts
import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { StudentDto } from './dtos/students.dto';
import { StudentsService } from './students.service';

@Controller('students')
export class StudentsController {
    constructor(private readonly studentsService: StudentsService) {}
  
    // @Get('who-are-you') ...

    @Post('who-are-you')
    whoAreYouPost(@Body() student: StudentDto) {
        return this.studentsService.ImStudent(student.name);
    }
}
```

命令行访问
```
// ✅
curl -X POST -d"name=gdccwxx"  http://127.0.0.1:3000/students/who-are-you
// => Im student gdccwxx%
```
post 方法传递的参数是通过请求 body 给到后台的。需要通过 `@Body` 装饰器解析 Body 中的数据。


# 三、参数限制与转换
这部分其实用到了 [管道](https://docs.nestjs.com/pipes) 的概念，我们用基础管道来实现，更高阶用法将会放在{% post_link nest-js-tutorial-4 第四章 %}中

## Get 请求
get 请求需要用到 `ParseIntPipe`, 更多的内置管道列表可查看[这里](https://docs.nestjs.com/pipes#built-in-pipes)

浏览器访问的 url 默认是 string 类型，`ParseIntPipe` 管道能将 string 类型转化成 number 类型


这次我们实现的是通过 id 查找学生姓名。

修改 students.service.ts
```typescript
// students.service.ts
import { Injectable } from '@nestjs/common';

@Injectable()
export class StudentsService {
    // ImStudent...

    getStudentName(id: number) {
        const ID_NAME_MAP = {
            1: 'gdccwxx',
        };

        return ID_NAME_MAP[id] ?? 'not found';
    }
}

```

修改 students.controller.ts
```typescript
import { Body, Controller, Get, Post, Query, ParseIntPipe } from '@nestjs/common';
// ... 

@Controller('students')
export class StudentsController {
    constructor(private readonly studentsService: StudentsService) {}
  
    // @Get('who-are-you') ..

    // @Post('who-are-you') ...

    @Get('get-name-by-id')
    getNameById(@Query('id', ParseIntPipe) id: number) {
        return this.studentsService.getStudentName(id);
    }
}

```

浏览器使用参数访问
```
// ❌
http://localhost:3000/students/get-name-by-id?id=gdccwxx
// => {
//     statusCode: 400,
//     message: "Validation failed (numeric string is expected)",
//     error: "Bad Request"
// } 

// ✅
http://localhost:3000/students/get-name-by-id?id=1
// => gdccwxx  
```

当使用非法请求，导致无法转换时，NestJs 会将请求报错处理，而正确参数则会转换后调用调用相应函数。通过简单的装饰器引用， NestJs 框架就可以自动做了参数检查与转换了

## Post 请求
Post 请求略微有些不一样，要用到 class-validator

安装 class-validator
```bash
npm i --save class-validator class-transformer
```

修改 main.ts
```typescript
// main.ts
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';


async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe());
  await app.listen(3000);
}
bootstrap();
```

修改 student.dto.ts
```typescript
import { IsNotEmpty, IsString } from 'class-validator';

export class StudentDto {
    @IsNotEmpty()
    @IsString()
    name: string;
}

```

通过命令行访问
```
// ❌
curl -X POST  http://127.0.0.1:3000/students/who-are-you
// => {"statusCode":400,"message":["name must be a string","name should not be empty"],"error":"Bad Request"}%

// ❌
curl -X POST http://127.0.0.1:3000/students/who-are-you -H 'Content-Type: application/json' -d '{"name": 1}'
// => {"statusCode":400,"message":["name must be a string"],"error":"Bad Request"}% 

// ✅
curl -X POST http://127.0.0.1:3000/students/who-are-you -H 'Content-Type: application/json' -d '{"name": "gdccwxx"}'
// => Im student gdccwxx% 
```

到此，参数校验部分也就完成。

# 四、自定义装饰器
在 post 请求用到了大量的装饰器，系统装饰器能满足大部分场景，但是有些特定需求时，需要自定义装饰器。

例如这样一个场景：每个请求都会带上 `user` 字段。代表是谁做的请求，每次在代码里 getUser 是非常难受的事情，这时自定义装饰器就派上了用场。

新建 src/common/decorators.ts
```typescript
// src/common/decorators.ts
import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export const User = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest(); // 拿到请求
    return request.body.user;
  },
);
```

修改 students.controller.ts
```typescript
import { Body, Controller, Get, Post, Query, ParseIntPipe } from '@nestjs/common';
import { StudentsService } from './students.service';
import { User } from '../common/decorators';

@Controller('students')
export class StudentsController {
    constructor(private readonly studentsService: StudentsService) {}
    // @Get('who-are-you') ...
    // @Post('who-are-you') ...
    // @Get('get-name-by-id')...

    @Post('who-is-request')
    whoIsReq(@User() user: string) {
        return user;
    }
}

```

命令行访问
```bash
// ✅
curl -X POST http://127.0.0.1:3000/students/who-is-request -H 'Content-Type: application/json' -d '{"user": "gdccwxx"}'
// => gdccwxx% 
```

通过自定义装饰器，并将其挂在函数上，代码就能优雅的获取是谁请求的借口。

# 五、日志
后台接口请求常伴随日志产生，日志对后台查问题至关重要。NestJs 框架也集成了日志，开箱即用。

使用日志分为三步:
- main.ts 引入 `Logger`
- 模块引入日志组建: `private readonly logger = new Logger(StudentsService.name)`;
- 在需要打印的地方引入: this.logger.log(\`student name is ${name}\`);


修改main.ts
```typescript
// main.ts
import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: new Logger(),
  });
  // ...
}
// ...
```

引用 Logger 组建
```ts
import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class StudentsService {
    private readonly logger = new Logger(StudentsService.name);

    ImStudent(name?: string) {
        this.logger.log(`student name is ${name}`);
        return 'Im student ' + name;
    }

    getStudentName(id: number) {
        this.logger.log(`get student id is ${id}`);
        const ID_NAME_MAP = {
            1: 'gdccwxx',
        };

        return ID_NAME_MAP[id] ?? 'not found';
    }
}
```

访问接口，控制台输出
```
curl -X POST http://127.0.0.1:3000/students/who-are-you -H 'Content-Type: application/json' -d '{"name": "gdccwxx"}'
```
![logger](log.png)

完整示例可以在 [github](https://github.com/gdccwxx/nest-test) 找到。

处理请求的基本方法就讲到这里，{% post_link nest-js-tutorial-3 下一篇 %}会讲解如何连接数据库并使用
