# 在win10home docker中安装gym环境

## 1、环境搭建
### 1、docker安装

win10中已经安装好docker，命令行运行下列

    docker run -ti -p 10000:8888 -e DISPLAY=host.docker.internal:0.0 -e GRANT_SUDO=yes --user root jupyter/scipy-notebook:33add21fab64

在win 浏览器下进入127.0.0.1：10000，启动terminal和notebook进行以下设置

### 2、换源

conda 换源
在cmd终端，分别输入如下三行命令：

    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
    conda config --set show_channel_urls yes

conda常用命令

    conda list             // 显示已安装的python包，如果是通过pip安装的包，不会显示
    conda search xxx       // 搜索python包
    conda install xxx=1.2  // 安装指定安装包版本
    conda install D:xxx    // 安装本地python包（绝对路径）
    conda env list         // 查看当前存在哪些虚拟环境
    conda create -n pytorch python=3.7 // 创建虚拟环境pytorch，python版本为3.7
    conda activate pytorch         // 启用虚拟环境
    conda deactivate               // 退出当前虚拟环境
    conda remove -n pytorch --all  // 删除虚拟环境
    conda info                     // 显示相关信息
    conda update conda             // 更新conda

pip换源一行命令

    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

### 3、依赖安装

mujoco需要的包

    sudo apt install libosmesa6-dev libgl1-mesa-glx libglfw3 libglew-dev -y


## 2、mujoco安装

### 1、mujoco下载
    
    wget https://www.roboti.us/download/mujoco200_linux.zip
    wget https://www.roboti.us/download/mjpro150_linux.zip
    unzip mujoco200_linux.zip
    unzip mjpro150_linux.zip
    mkdir .mujoco

在notebook下修改目录为`mujoco200`和`mjpro150`并放在`.mujoco\`下

### 2、环境变量修改

~/.bashrc修改，打开后添加以下

    export MUJOCO_KEY_PATH=~/.mujoco${MUJOCO_KEY_PATH}
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/jovyan/.mujoco/mjpro150/bin
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/jovyan/.mujoco/mujoco200/bin

或者下面代码

    export LD_LIBRARY_PATH=~/.mujoco/mujoco200/bin${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
    export MUJOCO_KEY_PATH=~/.mujoco${MUJOCO_KEY_PATH}

运行以下代码，激活

    source ~/.bashrc

### 3、GUI设置显示

windows 10中安装VcXsrv用于显示图像，安装启动后其他设置默认，取消Native opengl的选择，否则测试时出现出现libGL错误，pybullet同样问题。

### 4、测试能否成功

    cd ~/.mujoco/mujoco200/bin
    ./simulate ../model/humanoid.xml

或许需要以下命令才能运行    

    cd ~/.mujoco/mujoco200/bin
    LD_LIBRARY_PATH=. ./simulate ../model/humanoid.xml

## 3、安装mujoco_py

### 1、下载解压

    conda activate gym
    wget https://github.com/openai/mujoco-py/archive/refs/tags/1.50.1.0.zip
    unzip 1.50.1.0.zip

### 2、安装所需包

    cd ~/mujoco-py-1.50.1.0/
    pip install -r requirements.txt
    pip install -r requirements.dev.txt

### 3、编译安装

    cd ~/mujoco-py-1.50.1.0/
    python -c "import mujoco_py"
    pip install -e .

### 4、测试环境
    
    cd ~/mujoco-py-1.50.1.0/
    python ./examples/setting_state.py

## 4、安装box2d-py
 
 需要安装`swig`包，这里用`conda`安装，也可以用`apt-get`安装

    conda install swig
    pip install box2d-py

测试代码
```python
import Box2D
```
没有出现错误

```python
import gym
env = gym.make('CarRacing-v0')
env.reset()
for _ in range(1000):
    env.render()
    env.step(env.action_space.sample())
```

可以看到有游戏界面出现

## 5、安装atari_py

### 1、下载并编译atari_py

    git clone https://github.com/openai/atari-py.git
    sudo apt-get install cmake zlib1g zlib1g-dev
    cd atari_py
    pip install -e .
    pip install -U gym[atari]

可能需要重启下docker

### 2、下载ROM，装载

    wget http://www.atarimania.com/roms/Roms.rar
    rar e Roms.rar ~/Roms/
    python -m atari_py.import_roms ~/Roms

### 3、测试

```python
import atari_py
```

没有出现错误

```python
 import gym
 env = gym.make('SpaceInvaders-v0')
```

```python
import gym
env = gym.make('SpaceInvaders-v0')
status = env.reset()

for step in range(1000):
    env.render()
    thisstep = 1
    status, reward, done, info = env.step(thisstep)
    jpgname = './pic-%d.jpg' % step
    print(reward)
    if done:
        print('dead in %d steps' % step)
        break
env.close()
```

游戏窗口出现，正常应该设置完成。
