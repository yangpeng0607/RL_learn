# hyper-v 设置

## 安装
win10 没有hyper-v组件
下列命令存成hyper-v.cmd，运行

```
pushd "%~dp0"

dir /b %SystemRoot%\servicing\Packages\*Hyper-V*.mum >hyper-v.txt

for /f %%i in ('findstr /i . hyper-v.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i"

del hyper-v.txt

Dism /online /enable-feature /featurename:Microsoft-Hyper-V-All /LimitAccess /ALL
```

## 卸载
```
Dism /online /disable-feature /featurename:Microsoft-Hyper-V-All /Remove
```
有效的彻底关闭Hyper
```
bcdedit /set hypervisorlaunchtype off
bcdedit /enum
```
如果关闭了会看到最后一行显示
```
hypervisorlaunchtype Off
```
win+r，输入 
```
services.msc
```
找到HV主机服务，禁用，然后关闭重启电脑即可。
清理网络设置
```
netcfg -d
```
如需打开
```
bcdedit /set hypervisorlaunchtype auto
```
检查
```
Dism /Online /Cleanup-Image /RestoreHealth
Dism.exe /online /Cleanup-Image /StartComponentCleanup
sfc /scannow
```
检查
```
Dism /Online /Cleanup-Image /ScanHealth
Dism /Online /Cleanup-Image /CheckHealth
DISM /Online /Cleanup-image /RestoreHealth
```
## 设置NAT网络
win10只能设置一个NAT

创建虚拟交换机，等同于在Hyper-V管理器界面中新建虚拟网络交换机
```
New-VMSwitch -SwitchName "NAT-VM" -SwitchType Internal
```
查看 NAT-VM 的 ifindex
```
Get-NetAdapter
```
创建ip，InterfaceIndex参数自行调整为上一步获取到的ifindex。这一步等同于在 控制面版-网卡属性 中设置ip
```
New-NetIPAddress -IPAddress 192.168.60.1 -PrefixLength 24 -InterfaceIndex 6（注意修改IFindex）
```
创建nat网络，这一步是教程中的关键命令，24为子网掩码位数，即：255.255.255.0
```
New-NetNat -Name NAT-VM -InternalIPInterfaceAddressPrefix 192.168.60.0/24
Get-NetNat #确认获取到的nat只有一个且是你想要删除的
Get-NetNat | Remove-NetNat #删除nat网络
```
## 安装虚拟机

虚拟机选择网络NAT-VM
Ubuntu server 安装时选择安装ssh，
ip地址设置 
192.168.60.2
网关 192.168.60.1
DNS 8.8.8.8 223.5.5.5

安装后在win10的terminal可用通过
```
ssh user@192.168.60.2
```
进入server
远程桌面
安装 lxde和xrdp
```
sudo apt-get update
sudo apt-get install --no-install-recommends lxde
sudo apt-get install xrdp
```
可用在windows搜索mstsc.exe启动远程桌面
计算机填
```
192.168.60.2:3389
```
用用户名和密码登录

## 安装中文
安装区域设置 (locales)
Ubuntu 一般是预装了的, Kali Linux 和 Debian可能没有,就需要安装
更新索引
```
sudo apt update
```
安装locales
```
sudo apt install locales
```
区域设置
```
sudo dpkg-reconfigure locales
```
向下翻,在靠近末尾的位置找到 zh_CN.UTF-8 UTF-8 , 用 空格键 选中前面会添上 * ,然后回车键

再次选择 zh_CN.UTF-8 , 然后回车完成设置
重启后,如果有发现本该显示中文的地方出现了方块乱码,则还需要安装字体来支持中文
```
sudo apt install ttf-wqy-microhei ttf-wqy-zenhei xfonts-intl-chinese
```
## 安装docker
更新软件包索引，并且安装必要的依赖软件，来添加一个新的 HTTPS 软件源
```
sudo apt update
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
```
使用下面的 curl 导入源仓库的 GPG key：
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
将 Docker APT 软件源添加到系统：
```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```
安装 Docker 最新版本
```
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
```
一旦安装完成，Docker 服务将会自动启动。你可以输入下面的命令，验证它：
```
sudo systemctl status docker
```
以非 Root 用户身份执行 Docker
```
sudo usermod -aG docker $USER
```
卸载 Docker

在卸载 Docker 之前，你最好 移除所有的容器，镜像，卷和网络。

运行下面的命令停止所有正在运行的容器，并且移除所有的 docker 对象：
```
docker container stop $(docker container ls -aq)
docker system prune -a --volumes
```
现在你可以使用apt像卸载其他软件包一样来卸载 Docker：
```
sudo apt purge docker-ce
sudo apt autoremove
```
## 安装filebrowser，交换文件
版本根据情况更换
```
wget https://github.com/filebrowser/filebrowser/releases/download/v2.17.2/linux-amd64-filebrowser.tar.gz
```
或者
```
curl -fsSL https://filebrowser.xyz/get.sh | bash
```
设置命令

创建配置数据库：
```
filebrowser -d /etc/filebrowser.db config init
```
设置监听地址：
```
filebrowser -d /etc/filebrowser.db config set --address 0.0.0.0
```
设置监听端口：
```
filebrowser -d /etc/filebrowser.db config set --port 8088
```
设置语言环境：
```
filebrowser -d /etc/filebrowser.db config set --locale zh-cn
```
设置日志位置：
```
filebrowser -d /etc/filebrowser.db config set --log /var/log/filebrowser.log
```
添加一个用户：
```
filebrowser -d /etc/filebrowser.db users add root password --perm.admin
```
配置 SSL：
```
filebrowser -d /etc/filebrowser.db config set --cert example.com.crt --key example.com.key
```
取消 SSL：
```
filebrowser -d /etc/filebrowser.db config set --cert "" --key ""
```

## 外网访问
有公网ip
本地物理电脑设置
端口转发
```
netsh interface portproxy add v4tov4 listenport=8080 listenaddress=192.168.2.2 connectaddress=192.168.60.2 connectport=8080
```
端口显示
```
netsh interface portproxy show all
```
端口删除
```
netsh interface portproxy delete v4tov4 listenaddress=192.168.2.2 listenport=8000
```
端口重置
```
netsh interface portproxy reset
```
有时候外网连不上，需要重置再设就行，不知道为什么

## 防火墙

搜索运行 WF.msc

点‘入站规则’ 后右栏点‘新建规则’，再点端口，开放所需端口
```
filebrowser -d filebrowser.db config set --cert ~/ca/server.crt --key ~/ca/server.key
```
## 挂载数据盘
临时挂载
```
mkdir ~/data
sudo mount -t ntfs-3g /dev/sda2 ~/data/
```
启动挂载
```
sudo vim /etc/fstab
```
添加以下
```
/dev/sda2 /home/$user/data  ntfs-3g  defaults  0  0 
```
user根据需要自己替换
## linux下openssl生成 签名的步骤：（链接：https://www.jianshu.com/p/dbb86e77fdb9 ）

x509证书一般会用到三类文，key，csr，crt。

Key是私用密钥openssl格，通常是rsa算法。

Csr是证书请求文件，用于申请证书。在制作csr文件的时，必须使用自己的私钥来签署申，还可以设定一个密钥。

crt是CA认证后的证书文，（windows下面的，其实是crt），签署人用自己的key给你签署的凭证。 
### 1.key的生成 
```
openssl genrsa -des3 -out server.key 2048 
```
这样是生成rsa私钥，des3算法，openssl格式，2048位强度。server.key是密钥文件名。为了生成这样的密钥，需要一个至少四位的密码。可以通过以下方法生成没有密码的key:
```
openssl rsa -in server.key -out server.key 
```
server.key就是没有密码的版本了。 
### 2.生成CA的crt
```
openssl req -new -x509 -key server.key -out ca.crt -days 3650 
```
生成的ca.crt文件是用来签署下面的server.csr文件。 
### 3.csr的生成方法
```
openssl req -new -key server.key -out server.csr 
```
需要依次输入国家，地区，组织，email。最重要的是有一个common name，可以写你的名字或者域名。如果为了https申请，这个必须和域名吻合，否则会引发浏览器警报。生成的csr文件交给CA签名后形成服务端自己的证书。 
### 4.crt生成方法
CSR文件必须有CA的签名才可形成证书，可将此文件发送到verisign等地方由它验证，要交一大笔钱，何不自己做CA呢。
```
openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey server.key -CAcreateserial -out server.crt
```
输入key的密钥后，完成证书生成。-CA选项指明用于被签名的csr证书，-CAkey选项指明用于签名的密钥，-CAserial指明序列号文件，而-CAcreateserial指明文件不存在时自动生成。

最后生成了私用密钥：server.key和自己认证的SSL证书：server.crt

### 证书合并：
```
cat server.key server.crt > server.pem
```