# mujoco_py在win10 home下安装方法
## 1、安装 Visual Studio 2019

https://visualstudio.microsoft.com/downloads/ 下载Visual Studio 2019社区版，选择C++ Build Tools安装。

## 2、安装和测试MuJoCo in Windows
### 1、下载 mujoco200 win64和mjpro150 win64
    
    https://www.roboti.us/index.html

###    2、安装
解压并放在 

    %USERPROFILE%\.mujoco\

文件夹下（自己创建）

解压文件夹命名和结构

    %USERPROFILE%\.mujoco\mjpro150\bin
    %USERPROFILE%\.mujoco\mujoco200\
    
###   3、下载 mjkey.txt和freelicense.txt
https://www.roboti.us/license.html

点击Activation key和License text获取

放在以下文件夹

    %USERPROFILE%\.mujoco\
    %USERPROFILE%\.mujoco\mjpro150\bin （不确定要不要放）
    %USERPROFILE%\.mujoco\mujoco200\bin （不确定要不要放）

###    4、环境变量设置
任务栏中搜索'env'出现‘编辑系统环境变量’点击‘环境变量’，在用户变量中新建和增加以下

    MUJOCO_PY_MJKEY_PATH=%USERPROFILE%\.mujoco\mjkey.txt
    MUJOCO_PY_MUJOCO_PATH=%USERPROFILE%\.mujoco\mujoco200\bin
    PATH=%USERPROFILE%\.mujoco\mujoco200\bin

<!--
同时添加vs环境变量，同样位置，点击系统变量新增以下，具体路径根据安装版本有所变化

    INCLUDE=C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\include;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\shared;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\ucrt;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\um;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\winrt;
    LIB=C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\ucrt\x64;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x64;C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\lib\x64;
    PATH=C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64
    VS140COMNTOOLS=C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\Common7\Tools
-->

###    5、运行测试：

    %USERPROFILE%\.mujoco\mjpro150\bin
    %USERPROFILE%\.mujoco\mujoco200\bin
    
在上面文件夹下都运行以下命令

    .\simulate.exe ..\model\humanoid.xml

可看到环境

## 3、安装miniconda和gym,链接下载Miniconda3 Windows 64-bit最新版，安装
    
    https://docs.conda.io/en/latest/miniconda.html

### 1、创建gym环境并激活，选择工作目录并进入命令行
    
    conda create -n gym
    conda activate gym

### 2、安装所需conda包

    conda install -c conda-forge pystan
    conda install -c conda-forge swig
    conda install -c conda-forge pyglet

### 3、安装pip包
    
    pip install gym Box2D atari-py cffi pygit2 glfw imageio

### 4、测试

运行http://gym.openai.com/docs/ 中的环境测试代码，代码存入工作目录中新建的test.py
```python
import gym
env = gym.make('CartPole-v0')
env.reset()
for _ in range(1000):
    env.render()
    env.step(env.action_space.sample()) # take a random action
env.close()
```

    python.exe .\test.py
    
可看到gym环境

## 4、安装mujoco_py
### 1、找到mujoco_pyv1.50.1.0版本，下载zip格式，不要最新版

    https://github.com/openai/mujoco-py/releases/tag/1.50.1.0

### 2、解压放在工作目录下，进入gym环境，进入

    cd .\mujoco-py-1.50.1.0\
    
编辑以下以下文件

    .\scripts\gen_wrappers.py
    .\mujoco_py\generated\wrappers.pxi

查找

    isinstance(addr, (int, np.int32, np.int64))

替换为

    hasattr(addr, '__int__')

    保存退出

### 3、当前目录下编译安装

    python -c "import mujoco_py"

会出很多信息，最后显示代码生成就好，

    pip install -e .

不要使用python setup.py install，会出问题，不知道为什么。

### 4、安装gym全部环境

    pip install gym[all]

### 5、测试，.\mujoco-py-1.50.1.0\目录下运行：
    
    python .\examples\setting_state.py
    
    
可以看见环境
