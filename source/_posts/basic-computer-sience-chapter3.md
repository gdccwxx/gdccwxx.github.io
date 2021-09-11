---
title: 计算机系统基础－－第三章(程序的转换及机器级表示)
date: 2017-05-23 16:41:08
tags: 计算机系统基础
dir: 计算机系统基础
keywords: 计算机系统基础－－第三章(程序的转换及机器级表示)
---
### 生成机器代码的过程
1、预处理。：例如，在C语言中有程序以#开头的语句，在源程序中插入所有用的#include命令指定的文件和用#define申明的宏
```
cc -E prog1.c -o prog1.i  //对prog1.c进行预处理，预处理结果位prog1.i
```
2、编译。将预处理后的源程序文件编译产生相应的汇编语言程序
```
gcc -S prog1.i -o prog1.s或gcc -S prog1.c -o prog1.s    //对prog1.i或者prog1.c进行编译，生成汇编代码文件prog1.s
```
3、汇编。由汇编程序将汇编语言程序文件转换位可重定位的机器语言目标代码文件
```
gcc -c prog1.s -o prog1.o //对prog1.s进行汇编，生成可重定位目标文件prog1.o
```
3、汇编。由汇编程序将汇编语言程序文件转换位可重定位的机器语言目标代码文件
```
gcc prog1.o prog2.o -o prog     //将两个可重定位目标文件prog1.o prog2.o链接起来，生成可执行文件prog
```
### 可以使用gdb来进行调试
在Linux中自带GNU调试工具gdb调试和跟踪。
在生成.o文件后使用objdump -d test.o来进行反汇编查看代码
```
// test.c
int add(int i,int j){
	int x = i+j;
	return x;
}
// test.o
0000000000000000 <add>:
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	89 7d ec             	mov    %edi,-0x14(%rbp)
   7:	89 75 e8             	mov    %esi,-0x18(%rbp)
   a:	8b 55 ec             	mov    -0x14(%rbp),%edx
   d:	8b 45 e8             	mov    -0x18(%rbp),%eax
  10:	01 d0                	add    %edx,%eax
  12:	89 45 fc             	mov    %eax,-0x4(%rbp)
  15:	8b 45 fc             	mov    -0x4(%rbp),%eax
  18:	5d                   	pop    %rbp
  19:	c3                   	retq
```
MASM采用的是Intel格式的汇编代码
```	
MOV [BX+DI-6],CL   //其对大小写不明感，且目的操作数在做，而源操作数在右
```
AT&T方式(教材使用方式)
```
mov %ecx,(%ebx,%edi,-6)  // R[ecx] <- R[ebx]+M[R[edi]-6]
```
寄存器组织和寻址方式

通用寄存器（General Pupose Regesters，32位，8个）

段寄存器（Segment Registers，16位，6个）

程序状态与控制寄存器（Program Status and Control Register，32位，1个）

指令指针寄存器（Instruction Pointer，32位，1个）
#### 1.通用寄存器
EAX：累加器（Accumulator，针对操作数和结果数据的）

EBX：基址寄存器（Base，DS段中的数据指针）

ECX：计数器（Count，字符串和循环操作的）

EDX：数据寄存器（Data，I/O指针）

以上4个寄存器主要用在算术运算指令中，常常用来保存常量与变量的值。

EBP：扩展基质指针寄存器（Base Pointer，SS段中栈内数据指针）

ESI：源变址寄存器（Source Index，字符串操作源指针）

EDI：目的变址寄存器（Destination Index，字符串操作目标指针）

ESP：栈指针寄存器（Stack Pointer，SS段中栈指针）

以上4个寄存器主要用作保存内存地址的指针。
#### 2.段寄存器
CS：代码段寄存器（Code Segment）

SS：栈段寄存器（Stack Segment）

DS：数据段寄存器（Data Segment）

ES：附加数据段寄存器（Extra Data Segment）

FS：数据段寄存器（Data Segment）

GS：数据段寄存器（Data Segment）

CS寄存器用于存放应用程序代码所在段的段基址，SS寄存器用于存放栈段的段基址，DS寄存器用于存放数据段的段基址。ES、FS、GS寄存器用来存放程序使用的附加数据段的段基址。

![purposeRegiesters](purposeRegisters.jpg)
![sliceRegiester](sliceRegister.jpg)


#### 3.程序状态与控制寄存器
EFLAGS：Flag Register，标志寄存器
![标志寄存器](flagRegister.gif)
![eflag](eflagRegister.png)
##### 运算结果标志位

1、进位标志CF(Carry Flag)
进位标志CF主要用来反映运算是否产生进位或借位。如果运算结果的最高位产生了一个进位或借位，那么，其值为1，否则其值为0。
使用该标志位的情况有：多字(字节)数的加减运算，无符号数的大小比较运算，移位操作，字(字节)之间移位，专门改变CF值的指令等。
2、奇偶标志PF(Parity Flag)
奇偶标志PF用于反映运算结果中“1”的个数的奇偶性。如果“1”的个数为偶数，则PF的值为1，否则其值为0。
利用PF可进行奇偶校验检查，或产生奇偶校验位。在数据传送过程中，为了提供传送的可靠性，如果采用奇偶校验的方法，就可使用该标志位。
3、辅助进位标志AF(Auxiliary Carry Flag)
在发生下列情况时，辅助进位标志AF的值被置为1，否则其值为0：
(1)、在字操作时，发生低字节向高字节进位或借位时；
(2)、在字节操作时，发生低4位向高4位进位或借位时。
对以上6个运算结果标志位，在一般编程情况下，标志位CF、ZF、SF和OF的使用频率较高，而标志位PF和AF的使用频率较低。
4、零标志ZF(Zero Flag)
零标志ZF用来反映运算结果是否为0。如果运算结果为0，则其值为1，否则其值为0。在判断运算结果是否为0时，可使用此标志位。
5、符号标志SF(Sign Flag)
符号标志SF用来反映运算结果的符号位，它与运算结果的最高位相同。在微机系统中，有符号数采用补码表示法，所以，SF也就反映运算结果的正负号。运算结果为正数时，SF的值为0，否则其值为1。
6、溢出标志OF(Overflow Flag)
溢出标志OF用于反映有符号数加减运算所得结果是否溢出。如果运算结果超过当前运算位数所能表示的范围，则称为溢出，OF的值被置为1，否则，OF的值被清为0。
“溢出”和“进位”是两个不同含义的概念，不要混淆。

##### 状态控制标志位

状态控制标志位是用来控制CPU操作的，它们要通过专门的指令才能使之发生改变。
1、追踪标志TF(Trap Flag)
当追踪标志TF被置为1时，CPU进入单步执行方式，即每执行一条指令，产生一个单步中断请求。这种方式主要用于程序的调试。
指令系统中没有专门的指令来改变标志位TF的值，但程序员可用其它办法来改变其值。
2、中断允许标志IF(Interrupt-enable Flag)
中断允许标志IF是用来决定CPU是否响应CPU外部的可屏蔽中断发出的中断请求。但不管该标志为何值，CPU都必须响应CPU外部的不可屏蔽中断所发出的中断请求，以及CPU内部产生的中断请求。具体规定如下：
(1)、当IF=1时，CPU可以响应CPU外部的可屏蔽中断发出的中断请求；
(2)、当IF=0时，CPU不响应CPU外部的可屏蔽中断发出的中断请求。
CPU的指令系统中也有专门的指令来改变标志位IF的值。
3、方向标志DF(Direction Flag)
方向标志DF用来决定在串操作指令执行时有关指针寄存器发生调整的方向。在微机的指令系统中，还提供了专门的指令来改变标志位DF的值。

##### 32位标志寄存器增加的标志位
1、I/O特权标志IOPL(I/O Privilege Level)
I/O特权标志用两位二进制位来表示，也称为I/O特权级字段。该字段指定了要求执行I/O指令的特权级。如果当前的特权级别在数值上小于等于IOPL的值，那么，该I/O指令可执行，否则将发生一个保护异常。
2、嵌套任务标志NT(Nested Task)
嵌套任务标志NT用来控制中断返回指令IRET的执行。具体规定如下：
(1)、当NT=0，用堆栈中保存的值恢复EFLAGS、CS和EIP，执行常规的中断返回操作；
(2)、当NT=1，通过任务转换实现中断返回。
3、重启动标志RF(Restart Flag)
重启动标志RF用来控制是否接受调试故障。规定：RF=0时，表示“接受”调试故障，否则拒绝之。在成功执行完一条指令后，处理机把RF置为0，当接受到一个非调试故障时，处理机就把它置为1。
4、虚拟8086方式标志VM(Virtual 8086 Mode)
如果该标志的值为1，则表示处理机处于虚拟的8086方式下的工作状态，否则，处理机处于一般保护方式下的工作状态
#### 4.指令指针寄存器
EIP：指令指针寄存器（Instruction Pointer），存放下次将要执行的指令在代码段的偏移量。
### 七种寻址方式
![findWay](findWay.png)
定义以下几个类型
```
int x;
float a[100];
short b[4][4];

```
假设x的基址位100，每个int元素占4bit，则
a[i] = 104+i4 //比例变址
b[i][j] = 504+i8+j*2 //基址+比例变址+位移
x = 100 // 基址
![](stackValue.png)
### IA-32常用指令及其操作
### 传送指令
1、mov movb(比特), movw(字), movl(双字)
2、movs 符号扩展传送指令
3、movz 零扩展传送指令
4、xchg 数据交换指令
5、push 压栈
6、pop 退栈
7、lea 地址传送指令
8、in,out 输入输出I/O指令
9、pushf,popf 标志传送指令
##### 扩展
符号位扩展：
八位扩展为十六位
由 00001000 -> 1111111100001000
零扩展：
八位扩展为十六位
由 00001000 -> 0000000000001000
假设val 和ptr声明如下
**
val_type val;
contofptr_type *ptr;
已知上述类型val_type和contofptr_type是用typeof声明的数据类型，且val存储在累加器al/ax/eax中，ptr存储在edx中，现有以下两条C语言语句：
val= (val_type) * ptr;
*ptr = (contofptr_type) val;
写出以下组合类型的mov指令实现
**

| val_type | contofptr_type | 
| --- | --- |
| char | char |
| int | char |
| unsigned | int |
| int | unsigned char |
| unsigned | unsigned char |
| unsigned short | int |

答案：

|val_type        |contofptr_type|语句一对应的操作                        |       语句二对应的操作
----------------|--------------|-------------------------             |----
|char            | char         | movb  (%edx),%al //传送              |movb %al,(%edx)//传送|
|int             | char         | movsb (%edx),%eax // 符号位扩展，传送  |movb %al,(%edx)  //截断，传送|
|unsigned        | int          |movl (%edx),%eax //传送               |movl %eax,(%edx)  //传送|
|int             | unsigned char| movzbl (%edx),%eax // 零扩展，传送     | movb %al,(%edx)   //截断，传送|
|unsigned        | unsigned char|movzbl (%edx),%eax // 零扩展，传送      | movb %al,(%edx)   //截断，传送|
|unsigned short  | int          |movw (%edx),%ax // 截断，传送          | movzwl %ax,(%edx)   //零扩展，传送|

其在寄存器中以小端方式储存
**即|12345678H|-> |78H|56H|34H|12H|**
##### 按位运算指令
1、NOT单操作数每位取反
2、AND对双操作数按位逻辑“与”
3、OR对双操作数按位逻辑“或”
4、XOR对双操作数按位逻辑“异或”
5、TEST根据两个操作数相“与”的结果来设置条件标志
6、SHL逻辑左移，每左移一次，最高位送入cf，并在低位补0
7、SHR逻辑右移，每右移一次，最低位送入cf，并在高位补0
8、SAL算术左移，每左移一次，最高位送入cf，并在低位补0，若符号位发生变化，则of=1，表示左移溢出
9、SAR算术右移，每右移一次，最低位送入cf，并在高位补0
10、ROL循环左移，每左移一次，最高位移到最低位，并送入cf
11、ROR循环右移，每右移一次，最低位移到最高位，并送入cf
12、RCL带循环左移，将CF作为操作数的一部分循环左移
13、RCR带循环右移，将CF作为操作数的一部分循环右移
##### 控制转移指令JMP
##### 条件转移指令
##### 根据单个标志位的状态判断转移的指令
| 指令 | 转移条件 | 说明 |
| --- | --- | --- |
| JC DEST | CF=1 | 有进位/借位 |
| JNC DEST | CF=0 | 无进位/借位 |
| JE/JZ DEST | ZF=1 | 相等/等于零 |
| JNE/JNZ DEST | ZF=0 | 不相等/不等于零 |
| JS DEST | SF=1 | 是负数 |
| JNS DEST | SF=0 | 是正数 |
| JO DEST | OF=1 | 有溢出 |
| JNO DEST | OF=0 | 无溢出 |
| JP/JPE DEST | PF=1 | 有偶数个“1” |
| JNP/JPO DEST | PF=0 | 有奇数个“1” |
##### 根据两个无符号数的比较结果判断转移的指令
| 指令 | 转移条件 | 含义 |
| --- | --- | --- |
| JG/JNLE DEST | SF=OF AND ZF=0 | 有符号数A>B |
| JGE/JNL DEST | SF=OF OR ZF=1 | 有符号数A≥B |
| JL/JNGE DEST | SF≠OF AND ZF=0 | 有符号数A<B |
| JLE/JNG DEST | SF≠OF OR ZF=1 | 有符号数A≤B |
##### 根据两个有符号数的比较结果判断转移的指令
| 指令 | 转移条件 | 含义 |
| --- | --- | --- |
| JG/JNLE DEST | SF=OF AND ZF=0 | 有符号数A>B |
| JGE/JNL DEST | SF=OF OR ZF=1 | 有符号数A≥B |
| JL/JNGE DEST | SF≠OF AND ZF=0 | 有符号数A<B |
| JLE/JNG DEST | SF≠OF OR ZF=1 | 有符号数A≤B |
### IA-32的栈、栈帧及其结构
![static picture](stackBP.jpg)
##### 注：为保证其在内存中的整齐，一般的存在为16的倍数。


#### 小结：
本章至此也基本结束了，通过这章的学习，让我更清晰程序的内部工作原理，对优化程序也有了一定的见解。比如递归程序消耗内存，以及switch要查表才可以找到相应的选项。对汇编程序也有了一定的理解。虽然并不是那么深刻。但对以后思考代码的逻辑性以及效率性有了一定的帮助。