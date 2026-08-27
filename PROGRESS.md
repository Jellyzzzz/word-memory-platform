# 项目进度清单

> 用途：标记单词记忆与竞技学习平台各部分的完成状态。业务规范以 `SPEC.md` 为准。
> 更新日期：2026-08-27

状态图例：

- `[x]` 已完成
- `[~]` 部分完成（后面注明缺什么）
- `[ ]` 未开始

---

## 总览

| 层级 | 完成度 | 说明 |
| --- | --- | --- |
| 基础设施 / 工程配置 | ✅ 100% | 构建、Spring/MyBatis、Web、SQL、文档全部就绪 |
| 业务代码（Java + JSP + Mapper XML） | ✅ 100% | 三层 + 拦截器 + 工具 + 6 个 JSP 全部实现 |
| **整体** | **约 95%** | 代码完整、`mvn clean package` 通过；待 DB 配置 + 部署联调 |

> 代码层面已完成：23 个 Java 源文件 + 4 个 Mapper XML + 6 个 JSP，`mvn clean package` BUILD SUCCESS。
> 剩余工作属于「运行环境」而非编码：建库建表、配置 `database.properties`、部署 Tomcat 9 联调。

---

## 一、基础设施与工程配置（✅ 已全部完成）

### 1. 构建配置
- [x] `pom.xml` — WAR 打包，`finalName=word-memory-platform`
- [x] 依赖齐全：Spring 5.3.39、Spring MVC、Spring JDBC/TX、MyBatis 3.5.19、MyBatis-Spring 2.1.2、MySQL 8.4.0、javax.servlet 4.0.1（provided）、JSTL 1.2
- [x] Java 17 字节码（`maven.compiler.release=17`）
- [x] `.gitignore` — 已忽略 `database.properties` 等本机配置

### 2. Spring / MyBatis 配置
- [x] `spring-mybatis.xml`（root 上下文）— dataSource、sqlSessionFactory、MapperScannerConfigurer、transactionManager、`<tx:annotation-driven>`
- [x] `mybatis-config.xml` — `mapUnderscoreToCamelCase=true`
- [x] `database.properties.example` — 模板（jdbc.url / username / password）

### 3. Web 配置
- [x] `web.xml` — ContextLoaderListener、DispatcherServlet、UTF-8 过滤器、multipart-config（文件上传）
- [x] `spring-mvc.xml`（MVC 上下文）— controller 组件扫描、annotation-driven、default-servlet-handler、JSP 视图解析、LoginInterceptor、multipartResolver

### 4. 数据库脚本
- [x] `sql/schema.sql` — 四张表 `users` / `words` / `user_word_progress` / `likes`，含 UNIQUE、CHECK、外键、`ON DELETE CASCADE`（幂等）
- [x] `sql/data.sql` — 12 个内置单词（幂等）

### 5. 文档与交付物
- [x] `README.md` / `SPEC.md` / `CLAUDE.md`
- [x] `docs/design/` — 详细设计说明书（含修正版）
- [x] `docs/diagrams/` — 11 张 PlantUML 源文件 + PNG 输出

---

## 二、Java 后端代码（✅ 全部完成）

包结构 `com.wordmemory.platform`：

### 1. Entity（实体）✅
- [x] `User` / `Word` / `UserWordProgress` / `Like`

### 2. DTO ✅
- [x] `LoginRequest` / `RegisterRequest` / `AnswerRequest`
- [x] `Question`（出题结果）/ `AnswerResult`（判题结果）/ `ImportResult`（导入结果）

### 3. Mapper 接口 + XML ✅
- [x] `UserMapper`（insertUser / findByUsername / findById / listRanking / incrTotalLikes / addScore）
- [x] `WordMapper`（findAllBuiltin / findById / insertWord / listCustomWords / deleteCustomWord / findRandomWords）
- [x] `UserWordProgressMapper`（insertProgress / findByUserAndWord / findWordsByUserAndStatus / updateProgress）
- [x] `LikeMapper`（insertLike / checkLike / findLikedUserIds）

### 4. Service ✅
- [x] `UserService` — 注册（密码 SHA-256+盐、进度初始化）、登录、用户名查重
- [x] `LearningService` — 学习/复习出题、判题、熟练度/积分更新、CSV 导入、自定义单词删除、标记不熟练
- [x] `RankingService` — 排行榜查询、点赞（事务）

### 5. Controller ✅
- [x] `UserController` — 注册 / 登录 / 退出
- [x] `LearningController` — 学习 / 复习 / 自定义单词导入与删除
- [x] `RankingController` — 排行榜 / 点赞

### 6. 工具与拦截器 ✅
- [x] `LoginInterceptor` — 未登录重定向 `redirect:/login`，session key `userId`
- [x] `util/PasswordUtil` — SHA-256 + 随机盐哈希
- [x] `util/CsvUtil` — CSV 逐行解析

---

## 三、前端 JSP 与静态资源（✅ 全部完成）

### JSP 页面（`/WEB-INF/views/`）
- [x] `login.jsp` / `register.jsp`
- [x] `home.jsp`（合并自定义单词管理）
- [x] `learning.jsp` / `review.jsp`
- [x] `ranking.jsp`

### 静态资源
- [x] `static/css/style.css` — 自定义样式（Bootstrap 通过 CDN 引入）

---

## 四、业务功能清单（✅ 全部实现）

| 模块 | 功能 | 状态 | 对应 SPEC 章节 |
| --- | --- | --- | --- |
| 用户模块 | 注册（密码校验、进度初始化） | [x] | §9、§11 |
| 用户模块 | 登录 / 退出 | [x] | §8 |
| 单词学习 | 学习模式（status=learning） | [x] | §14、§16 |
| 单词学习 | 复习模式（status=mastered） | [x] | §15、§16 |
| 单词学习 | 选择题（4 选 1，随机干扰项） | [x] | §16.1 |
| 单词学习 | 填空题（忽略大小写/首尾空格） | [x] | §16.2 |
| 熟练度 | proficiency 0–5 更新、mastered 判定 | [x] | §12 |
| 积分 | score 累加 | [x] | §13 |
| 自定义单词 | CSV 导入（UTF-8，词性可选） | [x] | §17 |
| 自定义单词 | 查看 / 删除（仅自己的 custom） | [x] | §17 |
| 排行榜 | 按 score→total_likes→created_at 排序 | [x] | §18 |
| 点赞 | 去重、禁自赞、total_likes+1（事务） | [x] | §19 |

---

## 五、剩余待办（运行环境与联调，非编码）

1. [ ] 启动 MySQL，执行 `SOURCE sql/schema.sql; SOURCE sql/data.sql;` 建库建表
2. [ ] 复制 `database.properties.example` → `database.properties`，填写本机 `jdbc.url` / `jdbc.username` / `jdbc.password`
3. [ ] 将 `target/word-memory-platform.war` 部署到 Tomcat 9，启动应用
4. [ ] 端到端联调：注册 → 登录 → 学习 → 复习 → 导入 CSV → 排行榜 → 点赞
5. [ ] （可选）`main` 分支只收已验证代码，功能开发走 `feat/<name>` 分支
