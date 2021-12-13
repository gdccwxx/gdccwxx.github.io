---
title: 为啥前端要容器技术（docker+k8s）？
date: 2021-12-12 13:39:15
tags: 
  - docker
  - web
dir: docker
keywords: 
  - docker
  - web
  - k8s
  - kubernetes
description: 随着前端发展逐渐成熟，前端 CD 也随着时间的迁移而变化。本文通过时间线的方式，简述前端 CD 的过去、现在和将来。
---
随着前端发展逐渐成熟，前端 CD 也随着时间的迁移而变化。本文通过时间线的方式，简述前端 CD 的过去、现在和将来。

# part1: 纯静态页面时代
前后端分离后，前端页面变成了静态资源页面。只需要将页面文件部署在服务器，再通过 nginx 反向代理，页面就能被顺利的访问到。
<div style="width: 70%; margin: 0 auto;text-align:center; margin-bottom: 0px;">![nginx访问](./nginx.png)<span>1. nginx 反向代理访问资源</span>
</div>

纯静态页面的发布，只需要将新的页面资源把旧的资源替换掉，就完成了升级。
<div style="width: 70%; margin: 0 auto;text-align:center; margin-bottom: 0px;">![（图2: 文件被替换完成升级）](./old-replace.png)<span>2. 静态资源替换进行更新</span></div>

为了屏蔽机器的操作细节，也为了更方便扩容，虚拟系统逐渐显现。
<div style="width: 70%; margin: 0 auto;text-align:center; margin-bottom: 0px;">![（图3: 配置困难）](./hard-for-conf.png)</div>

<div style="width: 70%; margin: 0 auto;text-align:center; margin-bottom: 0px;">![（图3.1: 虚拟系统逐渐出现，为了屏蔽机器系统差异，系统里面跑系统）](./virtual-system-conf.png)<span>3. 使用虚拟系统屏蔽系统差异</span></div>


因为系统里面跑系统，占用了更多的cpu、磁盘，这项技术一直没被广泛传播。
<div style="width: 70%; margin: 0 auto;text-align:center; margin-bottom: 0px;">![（图4: 系统消耗资源，未被广泛传播）](./virtual-system-wast.png)<span>4. 系统上面跑虚拟系统，消耗更多资源</span></div>


此时 Docker + k8s(Kubernetes) 出现了，因为先前使用虚拟操作系统并没有比较好的收益，这项技术在前端并没有被广泛使用。
<div style="width: 70%; margin: 0 auto;text-align:center; margin-bottom: 0px;">![（图5: 系统消耗资源，未被广泛传播）](./docker-first.png)<span>5. docker 初现</span></div>

# part2: SSR 的现在
此时因为受到静态资源加载后再发起请求，导致网页初始化很慢，大家逐渐想起来前后端分离前的快乐。
<div style="width: 70%; margin: 0 auto;text-align:center; margin-bottom: 0px;">![（图6: 页面性能很好，在服务端直接读取数据）](./slow-page.png)<span>6. CSR 方式: 先请求资源，再请求数据，页面有闪动</span></div>


前端开始逐渐往服务端渲染靠，开始逐渐做后台的工作
<div style="width: 70%; margin: 0 auto;text-align:center; margin-bottom: 0px;">![（图7: node的出现，服务端加载很舒服）](./ssr-fast.png)<span>7. SSR 方式: 一次请求，页面打开速度提升</span></div>


和静态资源不同，服务端渲染会有一定程度上的资源消耗，就需要更多的机器了。
<div style="width: 70%; margin: 0 auto;text-align:center; margin-bottom: 0px;">![（图8: 吃不住，要更多的机器，运维成本更高）](./more-resource.png)<span>8. SSR 方式: 消耗更多服务端资源</span></div>

需要操作机器更多，运维成本极限升高，开始寻求更低的运维成本。到底是serverless 还是 docker + k8s?
<div style="width: 70%; margin: 0 auto;text-align:center; margin-bottom: 0px;">![（图9: 选项出现）](./ssr-choice.png)<span>9. 是serverless 还是 docker + k8s?</span></div>


中大型网站需要灰度能力，因此docker + k8s 在中大型前端中逐渐胜出。
<div style="width: 70%; margin: 0 auto;text-align:center; margin-bottom: 0px;">![（图10: 能力不行，逐渐胜出）](./docker-win.png)<span>10. docker + k8s 能力强大，逐渐获胜</span></div>

# part3: 发布原子化的未来
随着发布节奏紧锣密鼓的进行，前端也受够了线上反馈的问题，希望发布系统能自动灰度；有问题可随时会滚。
<div style="width: 70%; margin: 0 auto;text-align:center; margin-bottom: 0px;">![（图11: 有啥办法？一键灰度，随时回滚）](./too-much-publish.png)<span>11. 前端发布速度快、多，如何减少发布风险？</span></div>

通过 docker + k8s, 根据用户id、IP进行自动灰度，能保证同一个用户命中相同资源。每次发布都会变成一次记录，发布和回滚只需要将域名流量切换，再也不需要提醒吊胆的发布了。

<div style="width: 70%; margin: 0 auto;text-align:center; margin-bottom: 0px;">![（图12: happy）](./conf-publish.png)<span>12. 发布原子化，修改配置实现灰度、升级、回滚</span></div>

# 结束语
资源替换、裸机 ssr 适合中小型的项目开发，发布频率不大；中大型前端追求发布平稳，灰度简单；每种形式各有优劣。本文以时间线的方式讲述了前端 CD 发展的痛点和动机。

当然，前端 CD 还在逐渐发展中，还有很多技术需要不断尝试和更迭，仅是对现有的技术和最新的 CD 流程做简述。

或许有一天开发者感知不到发布。只需要定好发布策略并随时提代码呢？希望这天提早到来～

感谢您看到这里～ 💗
