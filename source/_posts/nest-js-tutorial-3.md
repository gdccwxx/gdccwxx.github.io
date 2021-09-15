---
title: NestJs 入门教程之三：数据库
date: 2021-09-12 17:16:56
tags:
    - Javascript
    - Typescript
    - NestJs
dir: nestJs
keywords: NestJs 教程
---
![nestjs](./nestjs.png)

这个系列的{% post_link nest-js-tutorial-2 上一篇 %}文章，实现了 `Post` 接口和对接口的基础操作。

本篇主要讲的是和数据库连接，使用数据库联表查询和操作记录。使用数据库将数据记录，就是一个完整的后台服务了。

完整示例可以在 [github](https://github.com/gdccwxx/nest-test) 找到。


本篇使用 `mysql` 作为数据库连接。使用 `NestJs` 内置的[数据库连接](https://docs.nestjs.com/techniques/database) `typeorm`，可在 [这里](https://typeorm.io/) 查阅 typeorm 详细文档

# 一、开发准备
1. [下载](https://dev.mysql.com/downloads/mysql/)并安装 Mysql
2. 创建 school 库
```bash
create database school;
```
3. 安装 @nestjs/typeorm typeorm mysql2
```bash
npm install --save @nestjs/typeorm typeorm mysql2
```

# 二、数据库连接
```typescript
// app.module.ts
import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { StudentsController } from './students/students.controller';
import { TypeOrmModule } from '@nestjs/typeorm';

@Module({
  imports: [
    StudentsModule,
    TypeOrmModule.forRoot({
      type: 'mysql',
      host: '127.0.0.1',
      port: 3306,
      username: 'root',
      password: '1qaz2wsx',
      database: 'school',
      autoLoadEntities: true,
      synchronize: true, // 数据库自动同步 entity 文件修改
    }),
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}

```
初始化数据库连接。

`autoLoadEntities` 自动化 load entity 文件, 所有在 Module 中引用的 Entity 文件会被自动加载。自动加载设置为 true 即可。

`synchronize` 自动化同步表，本地可自动打开，线上数据库不建议打开。

# 三、定义表结构
```typescript
import {
    Entity,
    Column,
    PrimaryGeneratedColumn,
    UpdateDateColumn,
    CreateDateColumn,
} from 'typeorm';

@Entity()
export class Student {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar' })
  name: string;

  @UpdateDateColumn()
  updateDate: Date;

  @CreateDateColumn()
  createDate: Date;
}
```

- `@Entity` 注解代表是数据库入口文件；
- `@Column` 是基础列文件，使用 `type` 字段定义在数据库实际存储
- `@PrimaryGeneratedColumn` 代表单调递增的主键
- `@UpdateDateColumn` 当记录修改时会修改时间
- `@CreateDateColumn` 当记录新增时会写入时间

# 四、引用表
```typescript
// students.module.ts
import { Module } from '@nestjs/common';
import { Student } from './entities/students.entity';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StudentsController } from './students.controller';
import { StudentsService } from './students.service';

@Module({
    imports: [TypeOrmModule.forFeature([Student])],
    providers: [StudentsService, Student],
    controllers: [StudentsController],
})
export class StudentsModule {}
```
- `imports` 引用 typeorm 模块， entity 才可以在 service 中使用
- `providers` service 的 constructor 需要引用哪些模块
- `controllers` 模块的 controller

```typescript
// students.service.ts
import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Student } from './entities/students.entity';

@Injectable()
export class StudentsService {
    constructor(
        @InjectRepository(Student)
        private readonly studentRepository: Repository<Student>,
    ) {}
}
```

这样会在 db 中建立 students 新表。

使用 `show create table` 能看表的详细信息。

```mysql
use school;

show tables;

// => | student | CREATE TABLE `student` (
//  `id` int NOT NULL AUTO_INCREMENT,
//  `updateDate` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
//  `createDate` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
//  `name` varchar(255) NOT NULL,
//  PRIMARY KEY (`id`)
// ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci |
```

# 五、与数据库交互
到这一步，终于可以和数据库进行交互了。基本上和数据库交互的部分都会放在 service 层，因此 `新增` 和 `查询` 都放在 service 层。

其中包括了

- `getStudentName` 的改造
- `setStudent` 函数的新增

```ts
// students.service.ts
// import ...

@Injectable()
export class StudentsService {
    // logger, constructor ImStudent getStudentName ...

    async getStudentName(id: number) {
        this.logger.log(`get student id is ${id}`);
        const results = await this.studentRepository.find({ id });

        return results ?? 'not found';
    }

    async setStudent(name: string) {
        const results = this.studentRepository.create({ name });
        return results;
    }
}

```

通过使用 `find` 和 `create` 对学生查询和创建。结果也是异步的。

下面对 `controller` 进行改造，使得函数调用串起来。

```ts
// students.controller.ts
// import ...
@Controller('students')
export class StudentsController {
    // constructor whoAreYou whoAreYouPost whoIsReq ..

    @Get('get-name-by-id')
    getNameById(@Query('id', ParseIntPipe) id: number) {
        return this.studentsService.getStudentName(id);
    }

    @Post('set-student-name')
    setStudentName(@User() user: string) {
        return this.studentsService.setStudent(user);
    }
}
```
通过对 `service` 的调用, 再经 `controller` 调用产生如下结果

```bash
// ✅ 命令行访问
curl -X POST http://127.0.0.1:3000/students/set-student-name -H 'Content-Type: application/json' -d '{"user": "gdccwxx"}'
// => {"name":"gdccwxx","id":1,"updateDate":"2021-09-12T15:57:14.599Z","createDate":"2021-09-12T15:57:14.599Z"}%

// ✅ 浏览器访问
http://localhost:3000/students/get-name-by-id?id=1

// => [{
//  id: 1,
//  name: "gdccwxx",
//  updateDate: "2021-09-12T15:57:14.599Z",
//  createDate: "2021-09-12T15:57:14.599Z"
// }]
```

通过对 `service` 的 save、find 调用，就能将数据完整存入数据库了。

# 六、联表查询
我们准备新建课程表`class`，每个班级可以有多个学生，一个学生隶属一个班级。

这样`学生`和`班级`就构成了 `n:1` 的关系。

为了方便展示，在学生模块下直接新增 `class.entity.ts` 文件。并通过 `@OneToMany` 关联 `students`。

```ts
// classes.entity.ts
import { Entity, Column, PrimaryGeneratedColumn, UpdateDateColumn, CreateDateColumn, OneToMany } from 'typeorm';
import { Student } from './students.entity';

@Entity()
export class Classes {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar' })
  className: string;

  @OneToMany(() => Student, student => student.class)
  students: Student[]

  @UpdateDateColumn()
  updateDate: Date;

  @CreateDateColumn()
  createDate: Date;
}
```

同时修改 `students.entity.ts`, 通过 `@ManyToOne` 引入 `Classes` 修改

```ts
// students.entity.ts
import {
    ManyToOne,
    // Entity...
} from 'typeorm';
import { Classes } from './classes.entity';

@Entity()
export class Student {
  // id name updateDate, createDate...
  @ManyToOne(() => Classes, classes => classes.students)
  class: Classes;
}
```

注意：`classes` 表引用 `students` 是通过新建字段(`students\class`)进行关联。

引用会最终在数据库变成`外键`连接。

```bash
show create table student;
// =>  CREATE TABLE `student` (
//   `id` int NOT NULL AUTO_INCREMENT,
//   `name` varchar(255) NOT NULL,
//   `updateDate` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
//   `createDate` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
//   `classId` int DEFAULT NULL,    // 👈 注意这里
//   PRIMARY KEY (`id`),
//   KEY `FK_bd5c8f2ef67394162384a484ba1` (`classId`), // 👈 注意这里
//   CONSTRAINT `FK_bd5c8f2ef67394162384a484ba1` FOREIGN KEY (`classId`) REFERENCES `classes` (`id`) // 👈 注意这里
// ) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci


// 而 classes 表并无链接
show create table classes;
// CREATE TABLE `classes` (
//   `id` int NOT NULL AUTO_INCREMENT,
//   `className` varchar(255) NOT NULL,
//   `updateDate` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
//   `createDate` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
//   PRIMARY KEY (`id`)
// ) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
```

再引入表，详细操作可看第四步。


`students.module.ts` 引入表
```ts
// students.module.ts
import { Classes } from './entities/classes.entity';
// ...

@Module({
    imports: [TypeOrmModule.forFeature([Student, Classes])],
    providers: [StudentsService, Student, Classes],
    // ..
})
export class StudentsModule {}

```


`students.service.ts` 引入表, 并实现 `setClass`, `getClass` 方法

```ts
import { Classes } from './entities/classes.entity';

@Injectable()
export class StudentsService {
    constructor(
        @InjectRepository(Student)
        private readonly studentRepository: Repository<Student>,
        @InjectRepository(Classes)
        private readonly classRepository: Repository<Classes>,
    ) {}
    // ...
     async setClass(name: string, studentIds: number[]) {
        const students = await this.studentRepository.find({ where: studentIds });
        const result = await this.classRepository.save({
            className: name,
            students: students, // 此处直接保存students 的实例，即直接从数据库取出来的数据
        })
        return result;
    }
    async findClass(id: number) {
        const result = await this.classRepository.find({
            where: { id },
            relations: ['students']
        });
        return result;
    }
}
```

新增 `ClassesDto`
```ts
// classes.dto.ts
import { IsNotEmpty, IsString } from 'class-validator';

export class ClassesDto {
    @IsNotEmpty()
    @IsString()
    className: string;

    students: number[]
}
```


`students.controller.ts` 修改
```typescript
// students.controller.ts
// import ...
export class StudentsController {
    // constructor ...

    @Get('get-class')
    getClass(@Query('id', ParseIntPipe) id: number) {
        return this.studentsService.findClass(id);
    }

    @Post('set-class')
    setClass(@Body() classes: ClassesDto) {
        return this.studentsService.setClass(classes.className, classes.students);
    }
}

```

`调用接口`，先插入数据再查询数据。

```bash
// 再新增一条数据
curl -X POST http://127.0.0.1:3000/students/set-student-name -H 'Content-Type: application/json' -d '{"user": "gdccwxx1"}'

// 插入 classes 数据
curl -X POST http://127.0.0.1:3000/students/set-class -H 'Content-Type: application/json' -d '{"className": "blog", "students": [1,2]}'

// ✅ 通过浏览器，查询长啥样
http://localhost:3000/students/get-class?id=1
// => [{
//  id: 1,
    className: "blog",
    updateDate: "2021-09-15T01:05:38.055Z",
    createDate: "2021-09-15T01:05:38.055Z",
    students: [{
        id: 1,
        name: "gdccwxx",
        updateDate: "2021-09-15T01:05:38.000Z",
        createDate: "2021-09-15T01:05:23.988Z"
    },{
        id: 2,
        name: "gdccwxx1",
        updateDate: "2021-09-15T01:05:38.000Z",
        createDate: "2021-09-15T01:05:28.084Z"
    }]
}]
```


# 七、简单回顾
再回顾下本章：
- 使用 `typeorm` 和 `mysql` 建立连接
- 使用 `entity` 文件创建数据库表
- `service` 使用对数据库的简单调用，包括`写入`和`读取`
- 使用关系查询，将 `student` 和 `classes` 连接写入和查询

至此，我们使用 `typeorm` 和 `mysql` 连接数据库就完成了。

完整示例可以在 [github](https://github.com/gdccwxx/nest-test) 找到。

下章我们将主要讲 `NestJs` 的高级用法，包括 `管道`、`守卫`和`拦截器`。期待你的阅读。
