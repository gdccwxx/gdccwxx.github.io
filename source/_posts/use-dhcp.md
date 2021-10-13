---
title: DPCH (DPCHCD)服务器的搭建与应用
date: 2017-10-21 20:53:10
tags: linux
dir: linux
keywords:
  - linux
  - DPCH
---
### 什么是DHCP？
#### 1.DHCP简介
DHCP(Dynamic Host Configuration Protocol),动态主机配置协议，是一个应用层协议。当我们将客户主机ip地址设置为动态获取方式时，DHCP服务器就会根据DHCP协议给客户端分配IP，使得客户机能够利用这个IP上网。
#### 2.为什么要使用DHCP？
DHCP（Dynamic Host Configuration Protocol，动态主机配置协议）通常被应用在大型的局域网络环境中，主要作用是集中的管理、分配IP地址，使网络环境中的主机动态的获得IP地址、Gateway地址、DNS服务器地址等信息，并能够提升地址的使用率。
#### 3.DHCP实现
![dhcp_client](dhcp_client.png)
DHCP的实现分为4步，分别是：
第一步：Client端在局域网内发起一个DHCP　Discover包，目的是想发现能够给它提供IP的DHCP Server。
第二步：可用的DHCP Server接收到Discover包之后，通过发送DHCP Offer包给予Client端应答，意在告诉Client端它可以提供IP地址。
第三步：Client端接收到Offer包之后，发送DHCP Request包请求分配IP。
第四步：DHCP Server发送ACK数据包，确认信息。
####　4.安装DHCP服务器
由于我使用的系统是archlinux，因此在我bash中之存在dhcpcd，当然他们是同名。
使用如下命令安装
```
pacman -S dhcpcd

```
检测是否安装成功,键入如下命令
```
dhcpcd --version
//显示如下。。。代表安装成功
dhcpcd 6.11.5
Copyright (c) 2006-2016 Roy Marples
Compiled in features: INET IPv4LL INET6 DHCPv6 AUTH

```
#### 5.DHCP服务器的一般配置
##### dhcp服务器一般配置步骤
1、dhcp服务器住配置文件dhcpd.conf，制定ip作用域，制定分配一个或多个ip地址范围
2、建立租约数据库文件
3、重新加载配置文件或重启dhcp服务器

##### dhcp的工作流程
在翻阅其他人的博客中，发现这个哥们的博客写的很好，因此[引用](http://www.zyops.com/dhcp-working-procedure)过来

##### 配置文件DHCPD.CONF
由于我的系统是archlinux，因此自动生成了一个dhcpd.conf文件在/etc目录之下。下面看一个完整的dhcpcd.conf：
```
vim /etc/dhcpd.conf 
# dhcpd.conf
#
# Sample configuration file for ISC dhcpd
#
# option definitions common to all supported networks...
option domain-name "example.org";
option domain-name-servers ns1.example.org, ns2.example.org;
default-lease-time 600;
max-lease-time 7200;
# Use this to enble / disable dynamic dns updates globally.
#ddns-update-style none;
# If this DHCP server is the official DHCP server for the local
# network, the authoritative directive should be uncommented.
#authoritative;
# Use this to send dhcp log messages to a different log file (you also
# have to hack syslog.conf to complete the redirection).
log-facility local7;
# No service will be given on this subnet, but declaring it helps the 
# DHCP server to understand the network topology.
subnet 10.152.187.0 netmask 255.255.255.0 {
}
# This is a very basic subnet declaration.
subnet 10.254.239.0 netmask 255.255.255.224 {
  range 10.254.239.10 10.254.239.20;
  option routers rtr-239-0-1.example.org, rtr-239-0-2.example.org;
}
# This declaration allows BOOTP clients to get dynamic addresses,
# which we don't really recommend.
subnet 10.254.239.32 netmask 255.255.255.224 {
  range dynamic-bootp 10.254.239.40 10.254.239.60;
  option broadcast-address 10.254.239.31;
  option routers rtr-239-32-1.example.org;
}
# A slightly different configuration for an internal subnet.
subnet 10.5.5.0 netmask 255.255.255.224 {
  range 10.5.5.26 10.5.5.30;
  option domain-name-servers ns1.internal.example.org;
  option domain-name "internal.example.org";
  option routers 10.5.5.1;
  option broadcast-address 10.5.5.31;
  default-lease-time 600;
  max-lease-time 7200;
}
# Hosts which require special configuration options can be listed in
# host statements.   If no address is specified, the address will be
# allocated dynamically (if possible), but the host-specific information
# will still come from the host declaration.
host passacaglia {
  hardware ethernet 0:0:c0:5d:bd:95;
  filename "vmunix.passacaglia";
  server-name "toccata.example.com";
}
# Fixed IP addresses can also be specified for hosts.   These addresses
# should not also be listed as being available for dynamic assignment.
# Hosts for which fixed IP addresses have been specified can boot using
# BOOTP or DHCP.   Hosts for which no fixed address is specified can only
# be booted with DHCP, unless there is an address range on the subnet
# to which a BOOTP client is connected which has the dynamic-bootp flag
# set.
host fantasia {
  hardware ethernet 08:00:07:26:c0:a5;
  fixed-address fantasia.example.com;
}
# You can declare a class of clients and then do address allocation
# based on that.   The example below shows a case where all clients
# in a certain class get addresses on the 10.17.224/24 subnet, and all
# other clients get addresses on the 10.0.29/24 subnet.
class "foo" {
  match if substring (option vendor-class-identifier, 0, 4) = "SUNW";
}
shared-network 224-29 {
  subnet 10.17.224.0 netmask 255.255.255.0 {
    option routers rtr-224.example.org;
  }
  subnet 10.0.29.0 netmask 255.255.255.0 {
    option routers rtr-29.example.org;
  }
  pool {
    allow members of "foo";
    range 10.17.224.10 10.17.224.250;
  }
  pool {
    deny members of "foo";
    range 10.0.29.10 10.0.29.230;
  }
}
```
可以看到如上默认配置
配置格式如下
```
# 全局配置
参数或选项			// 全局生效
#局部配置
声明 {
	参数或选项	  // 局部生效
}
```
##### 常用参数介绍
我在[其他人博客](http://www.zyops.com/dhcp-working-procedure)看到常用参数说明，于是就拷贝下来
![dhcp_config1](dhcp_config1.gif)
![dhcp_config2](dhcp_config2.gif)
![dhcp_config3](dhcp_config3.gif)

##### 配置实例
某单位销售部有80台计算机所使用的IP地址段为
192.168.1.1-192.168.1.254,子网掩码为255.22.255.0，网关为
192.168.1.1,192.168.1.2-192.168.1.30给各服务器使用，客户
端仅可以使用192.168.1.100-192.168.1.200。剩余IP地址保留。
```
subnet 198.168.1.0 netmask 255.255.255.0 {
	option routers 192.168.1.1;
	option subnet-mask 255.255.255.0;
	option nis-domain				"domain.org";
	option domain-name				"domain.org";
	option domain-name-servers 	192.168.1.2;
	option time-offset 		-18000;
	option netbios-node-type 		2;
	range dynamic-bootp	198.168.1.100 192.168.1.200;
	default-lease-time 	43200;
	host ns {
		next-server archlinux.org;
		hardware ethernet ...;
		fixed-address ...;
	}
}
```
##### 开启服务器
```
systemctl start dhcpcd

```
##### 关闭服务器
```
systemctl stop dhcpcd
```