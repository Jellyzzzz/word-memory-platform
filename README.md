# 单词记忆与竞技学习平台

软件课程设计项目：用户注册登录、单词学习与复习、自定义词库、排行榜和点赞。

## 技术基线

- JDK 21 运行，Java 17 字节码
- Spring Framework 5.3 / Spring MVC
- MyBatis 3.5 / MyBatis-Spring 2.1
- MySQL 8、JSP/JSTL、Tomcat 9（`javax.servlet`）

## 本地启动

1. 执行 `sql/schema.sql`，再执行 `sql/data.sql`。
2. 将 `src/main/resources/database.properties.example` 复制为 `database.properties`，填写本机 MySQL 凭据（该文件已忽略）。
3. 运行 `mvn clean package`，将 `target/word-memory-platform.war` 部署到 Tomcat 9。

业务开发约定为 `Controller -> Service -> Mapper`。详细业务规范见 `SPEC.md — 单词记忆与竞技学习平台 v0.3.md`。
