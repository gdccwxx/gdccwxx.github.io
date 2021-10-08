---
title: git —— 通过 rebase 合并 commit
date: 2021-10-08 12:41:58
tags:
    - git
dir: git
keywords:
    - 合并commit
    - git rebase 合并 commit
---
## 背景
在项目开发时候，经常会遇到明明是同一个修改，在一些不可抗拒因素下，导致本应该是一次提交的 commit 被多次提交。在开源社区往往对commit message 有着强迫症似的提交。

本篇的目的就是通过 rebase 合并 commit。

## 场景再现
分支: `master`
提交次数: `2次`
git log:
- 初始化: 第二次提交 (**当前最新commit**)
- 初始化: 第一次提交(需要合并)
- 初始化: init（不需要合并）

![git-log](./git-log.png)

### 期望场景
合并commit: `e4a5545b` 和 `1bc8133d` 
git log: `初始化文件`

## 操作步骤
### 压缩 commit 命令
命令：`git rebase -i [start point] [end point]` or `git rebase -i HEAD~[number]` 可使用任意一种

```bash
git rebase -i 03dcc16f // commit号是需要合并提交的前一次提交
// or 
git rebase -i 03dcc16f 1bc8133d
// or
git rebase -i HEAD~2
```

键入命令后，commit 信息由最开始到最近提交。即：最上面是最开始的提交，最下面是最近提交。
![git-rebase-pick](./git-rebase-pick.png)

### Rebase
#### 1. 命令解析：
- `pick`: 要执行这个 commit
- `squash` : 当前 commit 会被合并到前一个 commit
- ...

#### 2. 操作 rebase -i
- 将 `除了第一条` 的 `pick` 都改为 `squash` 或者 `s`
- vi `:wq` 保存退出


![git-rebase-s](./git-rebase-s.png)

#### 3. git rebase 基础操作(非必要无需此步)
git 会压缩提交历史，若有冲突，需要进行修改，修改的时候保留最新的历史记录。
- if 执行压缩：
```
git add .
git rebase --continue
```

- else 如果放弃此次压缩：
```
git rebase --abort
```

#### 4. 修改 commit message

若无冲突 or 冲突已 fix，则会出现一个 commit message 编辑页面。

修改 commit message， vi `:wq` 保存退出。

![modify-commit-message](./modify-commit-message.png)

#### 5. 查看修改后的内容
```bash
git log
```
![modified-git-log](./modified-git-log.png)

已经将 `e4a5545b` 和 `1bc8133d` 合并成一条 `510bfd34`  ✅

#### 6. 同步到远端
使用 `git push -f` or `git push --force` 强制推送。git 记录本地已经改动，和远端有冲突，需要用 `force push` 解决
```bash
git push -f
// or
git push --force
```

再看远端的仓库，记录已经改变～
