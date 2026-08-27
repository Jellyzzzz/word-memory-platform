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
| 业务代码（Java + JSP + Mapper XML） | ⬜ 0% | `src/main/java` 为空，无任何 JSP 页面与 Mapper XML |
| **整体** | **约 30%** | 脚手架完成，核心功能未动工 |

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
- [x] `web.xml` — ContextLoaderListener、DispatcherServlet、UTF-8 CharacterEncodingFilter
- [x] `spring-mvc.xml`（MVC 上下文）— controller 组件扫描、`<mvc:annotation-driven>`、`<mvc:default-servlet-handler>`、JSP `InternalResourceViewResolver`（`/WEB-INF/views/` + `.jsp`）

### 4. 数据库脚本
- [x] `sql/schema.sql` — 四张表 `users` / `words` / `user_word_progress` / `likes`，含 UNIQUE、CHECK、外键、`ON DELETE CASCADE`（幂等，`IF NOT EXISTS`）
- [x] `sql/data.sql` — 12 个内置单词（幂等，`NOT EXISTS`）

### 5. 文档与交付物
- [x] `README.md` — 初始化 / 部署说明
- [x] `SPEC.md` — 业务与编码规范 v0.3
- [x] `CLAUDE.md` — AI 协作约定
- [x] `docs/design/` — 详细设计说明书（含修正版）
- [x] `docs/diagrams/` — 11 张 PlantUML 源文件 + PNG 输出（角色/用例/序列/类/架构/部署/功能模块图）

---

## 二、Java 后端代码（⬜ 全部未开始）

`src/main/java/com/wordmemory/platform/` 目录为空，以下全部待实现。

### 1. Entity（实体）
- [ ] `User` — 对应 `users`
- [ ] `Word` — 对应 `words`
- [ ] `UserWordProgress` — 对应 `user_word_progress`
- [ ] `Like` — 对应 `likes`

### 2. DTO（仅在需要时创建）
- [ ] `RegisterRequest`
- [ ] `AnswerRequest`

### 3. Mapper 接口 + XML（`src/main/resources/mapper/*.xml`）
- [ ] `UserMapper`（+ XML）
- [ ] `WordMapper`（+ XML）
- [ ] `UserWordProgressMapper`（+ XML）— 含 `findWordsByUserAndStatus(userId, status)`
- [ ] `LikeMapper`（+ XML）

### 4. Service
- [ ] `UserService` — 注册（含密码 SHA-256+盐、进度初始化）、登录、退出
- [ ] `LearningService` — 学习/复习流程、出题 `generateQuestion()`、判题 `judgeAnswer()`、熟练度/积分更新 `updateProgress()`、CSV 导入、自定义单词删除
- [ ] `RankingService` — 排行榜查询、点赞规则（事务）

### 5. Controller
- [ ] `UserController` — 注册 / 登录 / 退出接口
- [ ] `LearningController` — 学习 / 复习 / 自定义单词接口
- [ ] `RankingController` — 排行榜 / 点赞接口

### 6. 工具与拦截器
- [ ] `LoginInterceptor` — 未登录重定向 `redirect:/login`，session key `userId`
- [ ] `util/` — 密码加盐哈希工具（SHA-256 + 随机盐，最短长度 6）

---

## 三、前端 JSP 与静态资源（⬜ 全部未开始）

`src/main/webapp/` 下暂无 `WEB-INF/views/` 与 `static/`。

### JSP 页面
- [ ] `login.jsp`
- [ ] `register.jsp`
- [ ] `home.jsp`（合并自定义单词管理）
- [ ] `learning.jsp`
- [ ] `review.jsp`
- [ ] `ranking.jsp`

### 静态资源
- [ ] `static/css/` — Bootstrap + 自定义样式
- [ ] `static/js/` — 少量交互脚本

---

## 四、业务功能清单（⬜ 全部未实现）

| 模块 | 功能 | 状态 | 对应 SPEC 章节 |
| --- | --- | --- | --- |
| 用户模块 | 注册 | [ ] | §9、§11 |
| 用户模块 | 登录 / 退出 | [ ] | §8 |
| 单词学习 | 学习模式（status=learning） | [ ] | §14、§16 |
| 单词学习 | 复习模式（status=mastered） | [ ] | §15、§16 |
| 单词学习 | 选择题（4 选 1，随机干扰项） | [ ] | §16.1 |
| 单词学习 | 填空题（忽略大小写/首尾空格） | [ ] | §16.2 |
| 熟练度 | proficiency 0–5 更新、mastered 判定 | [ ] | §12 |
| 积分 | score 累加 | [ ] | §13 |
| 自定义单词 | CSV 导入（UTF-8，词性可选） | [ ] | §17 |
| 自定义单词 | 查看 / 删除（仅自己的 custom） | [ ] | §17 |
| 排行榜 | 按 score→total_likes→created_at 排序 | [ ] | §18 |
| 点赞 | 去重、禁自赞、total_likes+1（事务） | [ ] | §19 |

---

## 五、未完成事项优先级建议

1. **Entity + Mapper 接口/XML**（数据访问基础，其余层依赖它）
2. **Service 层**（业务规则核心：密码、熟练度、积分、CSV、点赞事务）
3. **Controller + LoginInterceptor**（请求入口与权限拦截）
4. **JSP 页面 + 静态资源**（前端演示）
5. **端到端联调**：`mvn clean package` 构建 → 部署 Tomcat 9 → 全流程演示
6. **验证与合并**：`main` 分支只收已验证代码，功能走 `feat/<name>` 分支
