# 介绍

参考SianHH/gostc-open，这是基于Frp开发的内网穿透管理平台，支持多用户、多节点，支持速率，中心化配置，通过网页修改配置，实时生效。


.[GOSTC开源地址](https://github.com/SianHH/gostc-open)
## 一键安装脚本
### 服务端安装

国外网络环境
```shell
curl -sSL https://raw.githubusercontent.com/SianHH/gostc-open/main/install.sh | bash -s -- server
```

国内网络环境
```shell
curl -sSL https://alist.sian.one/direct/gostc/gostc-open/install.sh | bash -s -- server
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


### 客户端/节点安装

国外网络环境
```shell
curl -sSL https://raw.githubusercontent.com/SianHH/gostc-open/main/install.sh | bash -s -- gostc
```

国内网络环境
```shell
curl -sSL https://alist.sian.one/direct/gostc/gostc-open/install.sh | bash -s -- gostc
```

文件目录：**/usr/local/bin/gostc**

### 客户端/节点卸载
```shell
rm -rf /usr/local/bin/gostc
```

### 将客户端/节点注册为服务
```shell
gostc install --tls=false -addr 127.0.0.1:8080 -key ****** # 客户端
gostc install --tls=false -addr 127.0.0.1:8080 -s -key ****** # 节点
# install后，需要systemctl start gostc启动服务
```
--tls：根据实际的情况设置

-addr：根据实际的情况设置

-key：启动客户端或节点的连接密钥

注册为服务后，可以通过以下命令管理服务
```shell
systemctl start gostc # 启动
systemctl stop gostc # 停止
systemctl restart gostc # 重启
systemctl status gostc # 查看状态
```
如需更换密钥，需要先卸载服务，然后重新注册
```shell
gostc uninstall
gostc install --tls=false -addr 127.0.0.1:8080 -s -key ****** # 重新注册
```

**注意：由于服务名称重复，无法同时运行多个客户端/节点，如需启动多个客户端和节点，请将程序通过pm2、supervisor类似的进程管理工具启动**

## Docker部署

### 服务端

```yaml
version: "3"
services:
  client1:
    image: sianhh/gostc-admin:latest
    restart: always
    network_mode: host # 服务端根据情况配置网络情况，默认端口8080，可以修改配置文件更改
    container_name: gostc-admin
    volumes:
      - ./data:/app/data # 数据目录，包含配置文件，日志文件
    command:
      - -d # 开发者模式，用于将日志输出到控制台
      - --log-level # 日志级别
      - info
```

### 客户端/节点

参数`--tls`根据服务端是否使用SSL设置

参数`-addr`是服务端的访问地址

节点：
```yaml
version: "3"
services:
  client1:
    image: sianhh/gostc:latest
    restart: always
    network_mode: host # 客户端推荐网络使用host模式
    container_name: gostc
    command:
      - --tls=true
      - -addr
      - gost.sian.one
      - -s
      - -key
      - ****** # 替换为节点密钥
```

客户端：
```yaml
version: "3"
services:
  client1:
    image: sianhh/gostc:latest
    restart: always
    network_mode: host # 客户端推荐网络使用host模式
    container_name: gostc
    command:
      - --tls=true
      - -addr
      - gost.sian.one
      - -key
      - ****** # 替换为客户端密钥
```

### 网关服务

```yaml
version: "3"
services:
  client1:
    image: sianhh/gostc-proxy:latest
    restart: always
    network_mode: host # 推荐host，容器网络一定要与节点网络互通，确认节点可以访问到网关服务的API接口
    container_name: gostc-proxy
    volumes:
      - ./data:/app/data # 数据目录，包含配置文件，日志文件
    command:
      - -d # 开发者模式，用于将日志输出到控制台
      - --log-level # 日志级别
      - info
```

## 目录结构
```text
-- /
    -- server   // 后端项目代码
    -- web      // 前端项目代码
    -- client   // 节点和客户端项目代码
    -- proxy    // 网关服务，主要实现自定义域名功能
```

