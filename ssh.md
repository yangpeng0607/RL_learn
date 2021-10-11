## SSH连接
win10 terminal启动ssh-keygen.exe 产生公钥和私钥，放在user\\.ssh\目录下，可用不用输密码
先用ssh进入Ubuntu后，在~目录下建立.ssh目录再建立authorized_keys，将id_rsa.pub公钥内容复制进authorized_keys文件，或使用下面命令
    scp .\\.ssh\id_rsa.pub user@192.168.60.2:.ssh/authorized_keys

IOS中，下载termius，产生key并导入公钥进虚拟机
进入虚拟机后
    sudo vim /etc/ssh/sshd_config
修改
    PasswordAuthentication no
禁止通过密码连接，保障安全

## SSH端口转发--物理机转发虚拟机

在hyper-v.md中由于win 10端口转发奇怪问题很多，重启后徐重置端口，再设才能连接，故改用ssh本地转发虚拟机
win10 terminal 使用以下命令
    ssh -L 0.0.0.0:22:localhost:22 user@192.168.60.2
将物理机的22端口转发到虚拟机，然后手机可以通过termius连接到虚拟机，有公网ip也可以设置路由器端口映射外网访问虚拟机。注意打开win10防火墙。

## SSH端口转发--手机访问虚拟机服务
ios使用termius，再建立端口转发，点击port forwarding，设置好端口转发就可以连接了，可以使用https，和远程桌面rdp等。
由于ios放后台会断开连接，在termius设置中打开 Save Localtion Data,就不会关闭连接了。
https://docs.termius.com/faq/troubleshooting/cant-run-in-the-background
这种方法相对简单和安全连接家庭网络，不用设置VPN。




