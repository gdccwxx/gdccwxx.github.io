---
title: NestJs 入门教程之四：高阶用法
date: 2021-09-15 21:19:29
tags:
    - Javascript
    - Typescript
    - NestJs
dir: nestJs
keywords: NestJs 教程
---
![nestjs](./nestjs.png)

{% post_link nest-js-tutorial-3 上篇 %}文章，实现了 `数据库` 基础操作 和联表查询。

本篇主要内容
- 使用 `guard` 和 `decorator` 实现数据校验核查
- 通过 `interceptor` 和 `decorator` 实现敏感操作录入
- 自定义 `pipes` 实现数据转化

完整示例可以在 [github](https://github.com/gdccwxx/nest-test) 找到。


# 使用守卫实现数据拦截

![guard](./guard.png)

在 `请求到达业务逻辑前` 会经过 guard，这样在接口前可以做同意处理。

例如：检查登陆态、检查权限 ...

需要在业务逻辑前 `统一检查` 的信息，都可以抽象成守卫。

在真实场景中，大多数的后台管理端会用 `JWT` 实现接口鉴权。`NestJs` 也提供了对应的[解决方案](https://docs.nestjs.com/security/authentication)。

由于较长且原理相通，本篇暂时用校验 `user` 字段做演示。

## 新建守卫

新建 `user.guard.ts` 文件
```ts
// src/common/user.guard.ts
import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { Observable } from 'rxjs';

@Injectable()
export class UserGuard implements CanActivate {
  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.body.user;

    if (user) {
        return true;
    }

    throw new UnauthorizedException('need user field');
  }
}
```

## 单个接口使用守卫

单个接口使用需要用 `@UseGuards` 作为引用。再将定义的 `UserGuard` 作为入参。

在 `student.controller.ts` 中使用
```ts
import {  UseGuards  /** ... **/} from '@nestjs/common';
import { UserGuard } from '../common/guard/user.guard';
// ...

@Controller('students')
export class StudentsController {
    constructor(private readonly studentsService: StudentsService) {}

    @UseGuards(UserGuard)
    @Post('who-are-you')
    whoAreYouPost(@Body() student: StudentDto) {
        return this.studentsService.ImStudent(student.name);
    }
    // ...
}

```

这样当访问 `who-are-you` 和 `who-is-request` 就起作用了
```bash
// ❌ 不使用 user
curl -X POST http://127.0.0.1:3000/students/who-are-you -H 'Content-Type: application/json' -d '{"name": "gdccwxx"}'
// => {"statusCode":401,"message":"need user to distinct","error":"Unauthorized"}%  

// ✅ 使用 user
// curl -X POST http://127.0.0.1:3000/students/who-are-you -H 'Content-Type: application/json' -d '{"user": "gdccwxx", "name": "gdccwxx"}'
// => Im student gdccwxx%
```

## 全局使用

全局使用仅需在 `app.module.ts` 的 `providers` 中引入。这样就对全局生效了
```ts
import { APP_GUARD } from '@nestjs/core';
import { UserGuard } from './common/guard/user.guard';
// ...

@Module({
  controllers: [AppController],
  providers: [
    {
      provide: APP_GUARD,
      useClass: UserGuard,
    },
      AppService
  ],
  // ...
})
export class AppModule {}

```

这时再访问 `get` 请求 `who-are-you` 和 `post` 请求 `who-is-request`
```bash
// ❌ get who-are-you
http://localhost:3000/students/who-are-you?name=gdccwxx
// => {
// statusCode: 401,
// message: "need user field",
// error: "Unauthorized"
// }

// ✅ post 
curl -X POST http://127.0.0.1:3000/students/who-is-request -H 'Content-Type: application/json' -d '{"user": "gdccwxx"}'
// => gdccwxx%
```

## 自定义装饰器过滤
总有些接口我们不需要有 `user` 字段，这时自定义 `decorator` 就出马了。

基本原理是：在接口前设置 MetaData, 在服务启动时把 MetaData 写入内存，这样在请求过来时判断有无 MetaData 标签。有则通过，无则校验。

顺便也将 `get` 请求类型过滤掉。

```ts
// common/decorators.ts
export const NoUser = () => SetMetadata('no-user', true);
```

`user.guard.ts` 改造

```ts
// user.guard.ts
import { Reflector } from '@nestjs/core';
// ..

@Injectable()
export class UserGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.body.user;

    if (request.method !== 'POST') {
        return true;
    }

    const noCheck = this.reflector.get<string[]>('no-user', context.getHandler());

    if (noCheck) {
        return true;
    }

    if (user) {
        return true;
    }

    throw new UnauthorizedException('need user field');
  }
}
```

`NoUser` 使用
```ts
// students.controller.ts
import { User, NoUser } from '../common/decorators';
// ..

@Controller('students')
export class StudentsController {
    // ...
    @NoUser()
    @Post('who-are-you')
    whoAreYouPost(@Body() student: StudentDto) {
        return this.studentsService.ImStudent(student.name);
    }
}

```

这样再调用时
```bash
// ✅
curl -X POST http://127.0.0.1:3000/students/who-are-you -H 'Content-Type: application/json' -d '{"name": "gdccwxx"}'
// => Im student gdccwxx%
```

// TODO: interceptor
// TODO: pipes