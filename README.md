# emqx-mysql
emqx message save to mysql

emqx 消息持久化到mysql 插件

### 编译发布插件

1、clone emqx-rel 项目

> git clone https://github.com/emqx/emqx-rel.git


2.rebar.config 添加依赖

```erl
{deps,
   [ {emqx_mysql, {git, "https://github.com/luxingwen/emqx-mysql", {branch, "master"}}}
   , ....
   ....
   ]
}

```

3.rebar.config 中 relx 段落添加

```erl
{relx,
    [...
    , ...
    , {release, {emqx, git_describe},
       [
         {emqx_mysql, load},
       ]
      }
    ]
}
```
4.编译

> make

### config配置

File: etc/emqx_mysql.conf

```
# mysql 服务器
mysql.server = 127.0.0.1:3306

# 连接池数量
mysql.pool = 8

# mysql 用户名
mysql.username = easylinker

# mysql密码
mysql.password = 123456

# 数据库名
mysql.database = easylinker_v3

# 超时时间（秒）
mysql.query_timeout = 10

```

### 导入mqtt_msg.sql

导入mqtt_msg.sql 到你的数据库中

### 加载插件

> ./bin/emqx_ctl plugins load emqx_mysql

或者编辑

data/loaded_plugins

> 添加 {emqx_mysql, true}.

注意：这种方式适用emqx未启动之前

### 使用

此插件会把public发布的消息保存到mysql中，但并不是全部。

需要在发布消息的参数中 retain 值设置为 true。 这样这条消息才会被保存在mysql中

eg：

```json
{
  "topic": "test_topic",
  "payload": "hello",
  "qos": 1,
  "retain": true,
  "client_id": "mqttjs_ab9069449e"
}
```

### 最后

有什么问题或者功能需求都可以给我提issue，欢迎关注。

### License

Apache License Version 2.0
