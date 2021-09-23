ARG ROOT_CONTAINER=ubuntu:21.04
FROM $ROOT_CONTAINER
LABEL maintainer="openaigym docker <yangpeng0607@gmail.com>"
# 用户名 ID
ARG NB_USER="yang"
ARG NB_UID="1000"
ARG NB_GID="100"
# 给Ubuntu换源更新并安装国际化语言包以及中文字体、wget和sudo
RUN sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list && \ 
    apt-get clean && \
    apt-get update -y && \
    apt-get install -y locales wget sudo tini && \
    locale-gen zh_CN && \
    locale-gen zh_CN.utf8 && \
    apt-get install -y ttf-wqy-microhei ttf-wqy-zenhei xfonts-wqy
# 设置系统语言环境为中文UTF-8
USER root
# 基础环境和变量配置
ENV SHELL=/bin/bash \
    NB_USER="${NB_USER}" \
    NB_UID=${NB_UID} \
    NB_GID=${NB_GID} \
    LC_ALL=zh_CN.UTF-8 \
    LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN.UTF-8 \
    HOME="/home/${NB_USER}" 

EXPOSE 8888
# 安装所需软件包并添加非root用户
RUN apt-get install -y libosmesa6-dev libgl1-mesa-glx libglfw3 libglew-dev cmake zlib1g zlib1g-dev g++ libxrandr2 libxinerama1 libxcursor1 rar && \
    useradd -l -m -s /bin/bash -N -u "${NB_UID}" "${NB_USER}" 
# 切换用户，并安装conda，同时conda和pip换源。
USER ${NB_USER}
WORKDIR "${HOME}"
ENV PATH ${HOME}/miniconda3/bin:$PATH
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh && \
    bash Miniconda3-py39_4.10.3-Linux-x86_64.sh -b && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ && \
    conda config --set show_channel_urls yes && \
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple  && \
    conda update conda -y && \
    conda update --all -y
# 安装gym所需软件包
RUN pip install \
        gym \
        pyvirtualdisplay 
RUN conda install -y swig ipython ipykernel git unzip patchelf
# 安装 mujoco和mujoco_py、安装atari、box2d
RUN mkdir -p ~/.mujoco \
    && wget https://www.roboti.us/download/mujoco200_linux.zip -O mujoco.zip \
    && unzip mujoco.zip -d ~/.mujoco \
    && mv ~/.mujoco/mujoco200_linux ~/.mujoco/mujoco200 \
    && rm mujoco.zip
ADD --chown=${NB_USER}:${NB_GID} https://www.roboti.us/mjkey.txt ${HOME}/.mujoco/
ENV PATH ~/.mujoco:$PATH 
ENV PATH ~/.mujoco/mujoco200/bin:$PATH 
ENV LD_LIBRARY_PATH ${HOME}/.mujoco/mujoco200/bin:${LD_LIBRARY_PATH} 
RUN pip install imagehash ipdb Pillow pycparser pytest pytest-instafail scipy sphinx sphinx_rtd_theme numpydoc && \
    pip install glfw numpy Cython imageio && \
    pip install mujoco_py && \
    pip install gym[box2d] && \
    pip install atari_py && \
    pip install -U gym[atari] && \
    cp ~/.mujoco/mjkey.txt ~/.mujoco/mujoco200/bin/ && \
    wget http://www.atarimania.com/roms/Roms.rar && \
    rar e Roms.rar ~/Roms/ && \
    python -m atari_py.import_roms ~/Roms
# 设置用户和root密码及工作目录
USER root
RUN echo "root:root" | chpasswd &&\
    echo "${NB_USER}:${NB_USER}" | chpasswd &&\
    usermod -aG sudo "${NB_USER}"
USER ${NB_USER}
WORKDIR "${HOME}/work"
# ENTRYPOINT ["tini", "-g", "--"]
# echo $PATH 显示路径