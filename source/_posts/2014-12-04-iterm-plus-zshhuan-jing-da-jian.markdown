---
layout: post
title: "iTerm + Zsh环境搭建"
date: 2014-12-04 18:07:47 +0800
comments: true
categories: 
---
##1. iTerm
iTerm2官方网址 [http://iterm2.com/index.html](http://iterm2.com/index.html)
##2. Zsh
Mac系统默认安装了`Zsh`，路径是`/bin/zsh`，但是系统默认的`Shell`还是`Bash`。通过以下命令可以看到Mac系统下的所有`Shell`:

```
cat /ect/shells
```
显示如下:

```
/bin/bash
/bin/csh
/bin/ksh
/bin/sh
/bin/tcsh
/bin/zsh
```
把Zsh设置为当前用户的默认Shell:

```
chsh -s /bin/zsh
```
###2.1 安装配置工具oh-my-zsh
`oh-my-zsh`可以让我们快速的配置Zsh，话说最开始Zsh乏人问津的原因就是配置过于复杂，`oh-my-zsh`的网址是[https://github.com/robbyrussell/oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)，安装`oh-my-zsh`只需要一条命令:

```
curl -L http://install.ohmyz.sh | sh
```
###2.2 配置别名
`zsh`的配置主要集中在用户当前目录的`.zshrc(~/.zshrc)`里。我主要进行了一下配置:

```
alias cls='clear'
alias ll='ls -l'
alias la='ls -a'
alias vi='vim'
```
###2.2 配置颜色
在`.zshrc`里找到`ZSH_THEME`，就可以设置主题了，默认主题是:

```
ZSH_THEME=”robbyrussell”
```
`oh-my-zsh`提供了数十种主题，相关文件在`~/.oh-my-zsh/themes`目录下，你可以随意选择，我采用了默认主题`robbyrussell`，不过做了一点小小的改动:

```
PROMPT='%{$fg_bold[red]%}➜ %{$fg_bold[green]%}%p%{$fg[cyan]%}%d %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}% %{$reset_color%}>>'
#PROMPT='%{$fg_bold[red]%}➜ %{$fg_bold[green]%}%p %{$fg[cyan]%}%c %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}'
```
对照原来的版本，我把c改为d，c表示当前目录，d表示绝对路径，另外在末尾增加了一个「>>」。
###2.2 配置插件
`oh-my-zsh`项目提供了完善的插件体系，相关的文件在`~/.oh-my-zsh/plugins`目录下，默认提供了100多种，大家可以根据自己的实际学习和工作环境采用，想了解每个插件的功能，只要打开相关目录下的`zsh`文件看一下就知道了。插件也是在`.zshrc`里配置，找到`plugins`关键字，你就可以加载自己的插件了，系统默认加载`git`，我的插件配置如下:

```
plugins=(git osx sudo python audojump)
```
下面简单介绍几个插件:

- git : 当你处于一个`git`受控的目录下时，`Shell`会明确显示`git`和`branch`，另外对`git`很多命令进行了简化，例如`gco=’git checkout’、gd=’git diff’、gst=’git status’、g=’git’`等等，熟练使用可以大大减少 git 的命令长度，命令内容可以参考`~/.oh-my-zsh/plugins/git/git.plugin.zsh`。
- osx : `tab`增强，`quick-look filename`可以直接预览文件，`man-preview grep`可以生成`grep`手册的`pdf`版本等。
- autojump : `zsh`和`autojump`的组合形成了`zsh`下最强悍的插件，`autojump`会帮助我们快速的跳到我们访问过的路径，无论我们在哪里。通过以下命令安装:

    ```
    brew install autojump
    ```
然后在`.zshrc`中添加一行代码:

    ```
    [[ -s ~/.autojump/etc/profile.d/autojump.sh ]] && . ~/.autojump/etc/profile.d/autojump.sh
    ```

##3. Vim
###3.1 颜色配置
话说最好的Vim配色方案是[molokai](https://github.com/tomasr/molokai)

- 下载`molokai.vim`，拷贝到`~/.vim/colors`目录下，如果没有这个目录就创建这个目录。
- 在`~/.vimrc`中添加如下代码():

    ```
colorscheme molokai
let g:molokai_original = 0
let g:rehash256 = 1
    ```

我自己的`.vimrc`在这里[https://github.com/Joywii/TerminalCon](https://github.com/Joywii/TerminalCon)。