# 介绍

参考SianHH/gostc-open，这是基于Frp开发的内网穿透管理平台，支持多用户、多节点，支持速率，中心化配置，通过网页修改配置，实时生效。


.[GOSTC开源地址](https://github.com/SianHH/gostc-open)

目前只设置的服务端，其他还在编写中
## 一键安装脚本
### 服务端安装

国外网络环境
```shell
curl -sSL https://raw.githubusercontent.com/MAXXS2814/gostc-l/main/install.sh | bash -s -- server
```

国内网络环境
```shell
curl -sSL https://www.lfkj88.top:5002/gotsc-l/install.sh | bash -s -- server
```

install后，需要systemctl start gostc-admin启动服务

安装完成后通过以下命令管理
```shell
systemctl start gostc-admin # 启动
systemctl stop gostc-admin # 停止
systemctl restart gostc-admin # 重启
systemctl status gostc-admin # 查看状态
```

程序目录：**/usr/local/gostc-admin/**

数据目录：**/usr/local/gostc-admin/data/**

默认端口：8080

默认账号密码：admin/admin

### 服务端卸载
```shell
/usr/local/gostc-admin/server service uninstall
rm -rf /usr/local/gostc-admin/server
```
