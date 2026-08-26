# 单词记忆与竞技学习平台

软件课程设计项目：用户注册登录、单词学习与复习、自定义词库、排行榜和点赞。

## 技术基线

- JDK 21 运行，Java 17 字节码
- Spring Framework 5.3 / Spring MVC
- MyBatis 3.5 / MyBatis-Spring 2.1
- MySQL 8、JSP/JSTL、Tomcat 9（`javax.servlet`）

## 新机器初始化与部署

准备 JDK 17+、Maven 3.9、MySQL 8 和 Tomcat 9，然后执行：

1. 克隆仓库并进入项目目录。
2. 登录 MySQL，依次执行数据库脚本：

   ```sql
   SOURCE D:/word-memory-platform/sql/schema.sql;
   SOURCE D:/word-memory-platform/sql/data.sql;
   ```

   `schema.sql` 创建数据库和四张业务表，`data.sql` 写入可重复执行的内置单词数据。请将路径替换为新机器上的实际绝对路径。

3. 创建仅供本机使用的数据库配置：

   ```powershell
   Copy-Item src/main/resources/database.properties.example `
       src/main/resources/database.properties
   ```

   编辑新文件中的 `jdbc.url`、`jdbc.username` 和 `jdbc.password`。`database.properties` 已被 Git 忽略，不会提交本机密码。

4. 构建并部署：

   ```powershell
   mvn clean package
   ```

   将 `target/word-memory-platform.war` 部署到 Tomcat 9。应用启动时只连接数据库，不会自动建表或写入初始化数据。

业务开发约定为 `Controller -> Service -> Mapper`。详细业务规范见 `SPEC.md — 单词记忆与竞技学习平台 v0.3.md`。
