# 记录强化学习

## 环境搭建 [Mujoco_py](./mujoco_py.md)安装

## 在[win10下docker gym](./gymdocker.md)环境安装

## 定制自己的openai docker环境
已完成dockerfile，本人使用Windows10，通过VScode 链接使用。

使用方式：
下载[dockerfile](./dockerfile)文件，需要的话自行修改，放在空文件夹下，运行
  docker build -t openai .
镜像完成后，运行以下命令生成容器
  docker run -ti -p 20000:8888 -e DISPLAY=host.docker.internal:0.0 -e GRANT_SUDO=yes openai

端口开好，可自己在容器内添加jupyter，本人使用vscode就没安装了

Windows中安装好VcXsrv，启动时勾选掉 Native Opengl，不然显示可能有问题。




