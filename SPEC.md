# 单词记忆与竞技学习平台开发规范

Version: v0.3

## 1. 项目目标

本项目为软件课程设计，开发一个基于 Java Web 的单词学习平台。

系统核心功能包括：

- 用户注册、登录、退出
- 单词学习
- 单词复习
- 熟练度管理
- 自定义单词导入与管理
- 排行榜
- 点赞

系统名称中的“竞技”通过排行榜体现，不实现用户之间的实时或异步对战。

项目目标优先级：

1. 系统能够完整运行
2. 完成课程要求的全部功能与交付物
3. 实现与详细设计文档保持基本一致
4. 控制开发复杂度和时间成本
5. 不追求生产级架构和过度工程化

---

# 2. 系统角色

系统只包含两类角色。

## 2.1 游客

游客可以：

- 访问登录页面
- 访问注册页面
- 注册账户
- 登录系统

游客不能访问学习、复习、排行榜等受保护资源。

## 2.2 普通用户

普通用户可以：

- 退出登录
- 学习单词
- 复习单词
- 标记单词为不熟练
- 查看自定义单词
- 导入自定义单词
- 删除自己的自定义单词
- 查看排行榜
- 为其他用户点赞

所有普通用户权限一致。

系统不设置管理员角色。

系统内置单词通过 SQL 初始化脚本预置。

---

# 3. 功能模块

系统划分为三个一级业务模块。

```text
1. 用户模块
   ├── 用户注册
   ├── 用户登录
   └── 用户退出

2. 单词学习模块
   ├── 学习模式
   ├── 复习模式
   ├── 熟练度管理
   └── 自定义单词管理
       ├── 查看自定义单词
       ├── CSV 导入单词
       └── 删除自定义单词

3. 排行榜模块
   ├── 查看排行榜
   └── 点赞
```

当前不主动扩展新的一级业务模块。

---

# 4. 技术栈

## 4.1 后端

采用：

```text
Java
Spring Framework
Spring MVC
MyBatis
MyBatis-Spring
MySQL
Maven
Tomcat
```

项目采用传统 Spring MVC Web 工程。

不使用 Spring Boot。

Spring 主要负责：

- IoC / DI
- Controller 管理
- Service 管理
- 请求映射
- 参数绑定
- 事务管理

MyBatis 负责数据库访问。

MyBatis-Spring 负责 Spring 与 MyBatis 的集成。

---

## 4.2 前端

采用：

```text
JSP
HTML
CSS
Bootstrap
少量 JavaScript
```

Bootstrap 用于：

- 基础 UI 组件
- PC 端布局
- 移动端响应式适配

前端以能够完成课程演示为目标，不追求复杂视觉效果。

---

# 5. 系统架构

系统采用分层 MVC 架构。

```text
Browser
   ↓
JSP / Bootstrap
   ↓
Spring MVC Controller
   ↓
Service
   ↓
MyBatis Mapper
   ↓
MySQL
```

调用方向原则上保持：

```text
Controller → Service → Mapper
```

---

# 6. 各层职责

## 6.1 Controller

负责：

- HTTP 请求接收
- 参数绑定
- 基础参数检查
- Session 获取
- Service 调用
- Model 数据设置
- JSP 跳转
- Redirect

Controller 原则上不直接访问 Mapper。

---

## 6.2 Service

负责：

- 核心业务逻辑
- 用户注册和登录
- 密码处理
- 学习流程
- 复习流程
- 答题判断
- 熟练度更新
- 积分更新
- CSV 导入
- 点赞规则
- 事务控制

---

## 6.3 Mapper

负责：

- SQL 查询
- 数据新增
- 数据修改
- 数据删除
- Java 对象和数据库记录映射

Mapper 不承担主要业务规则。

---

## 6.4 View

JSP 页面负责：

- 页面展示
- 用户输入
- 表单提交
- Controller Model 数据展示
- 少量 JavaScript 交互

JSP 不直接访问数据库。

---

# 7. 核心 Java 模块

建议基础包结构：

```text
controller/
service/
mapper/
entity/
dto/
interceptor/
util/
```

主要 Controller：

```text
UserController
LearningController
RankingController
```

主要 Service：

```text
UserService
LearningService
RankingService
```

主要 Mapper：

```text
UserMapper
WordMapper
UserWordProgressMapper
LikeMapper
```

主要 Entity：

```text
User
Word
UserWordProgress
Like
```

DTO 仅在确有必要时创建，例如：

```text
RegisterRequest
AnswerRequest
```

不要求为所有接口机械创建 DTO。

---

# 8. 登录与权限

登录状态使用：

```text
HttpSession
```

登录成功后：

```java
session.setAttribute("userId", user.getUserId());
```

退出登录：

```java
session.invalidate();
```

使用：

```text
LoginInterceptor
```

统一拦截需要登录才能访问的资源。

Session 中不存在有效 `userId` 时：

```text
redirect:/login
```

不使用：

```text
JWT
Spring Security
OAuth
```

---

# 9. 密码规则

密码不允许明文存储。

采用：

```text
SHA-256 + 随机盐
```

注册：

```text
生成随机 salt
↓
SHA-256(salt + password)
↓
保存 password_hash + salt
```

登录时使用相同算法重新计算并比较。

密码最低长度：

```text
6
```

该实现仅满足课程项目需要，不作为生产级安全方案。

---

# 10. 数据模型

系统采用四张核心业务表。

## 10.1 users

主要字段：

```text
user_id
username
password_hash
salt
score
total_likes
created_at
```

约束：

```text
username UNIQUE
```

---

## 10.2 words

主要字段：

```text
word_id
english
chinese
part_of_speech
source
owner_id
```

source：

```text
builtin
custom
```

内置单词：

```text
owner_id = NULL
```

自定义单词：

```text
owner_id = 当前用户 ID
```

---

## 10.3 user_word_progress

主要字段：

```text
id
user_id
word_id
proficiency
status
```

约束：

```text
UNIQUE(user_id, word_id)
```

status：

```text
learning
mastered
```

该表表示：

> 某个用户对某个单词的学习状态。

`proficiency` 和 `status` 不属于 `words` 表。

---

## 10.4 likes

主要字段：

```text
id
from_user_id
to_user_id
created_at
```

约束：

```text
UNIQUE(from_user_id, to_user_id)
```

同一用户只能给另一用户点赞一次。

不允许用户给自己点赞。

---

# 11. 用户注册数据初始化

用户注册成功后：

```text
创建 User
↓
获取 user_id
↓
读取全部 builtin Word
↓
为每个 Word 创建 UserWordProgress
↓
proficiency = 0
status = learning
```

注册和学习进度初始化属于同一注册业务过程。

---

# 12. 熟练度规则

熟练度范围：

```text
0 ~ 5
```

初始：

```text
proficiency = 0
status = learning
```

学习模式：

```text
答对 → proficiency + 1
答错 → proficiency 不变
```

当：

```text
proficiency >= 3
```

时：

```text
status = mastered
```

复习模式：

```text
答对 → proficiency + 1，上限 5
答错 → proficiency - 1
```

当：

```text
proficiency < 3
```

时：

```text
status = learning
```

手动标记不熟练：

```text
proficiency = 0
status = learning
```

---

# 13. 积分规则

`score` 与 `proficiency` 为两个不同概念。

```text
proficiency
→ 表示某用户对某个单词的掌握情况

score
→ 表示排行榜积分
```

每次学习或复习：

```text
答对 → score + 1
答错 → score 不变
```

---

# 14. 学习模式

学习模式只使用：

```text
status = learning
```

的单词。

查询由：

```text
UserWordProgressMapper
```

负责。

推荐接口：

```java
List<Word> findWordsByUserAndStatus(
    Integer userId,
    String status
);
```

SQL 通过：

```text
user_word_progress JOIN words
```

查询当前用户对应状态的单词。

---

# 15. 复习模式

复习模式只使用：

```text
status = mastered
```

的单词。

复用学习模块的：

```text
generateQuestion()
judgeAnswer()
updateProgress()
```

通过 mode 或调用上下文区分 learning / review。

---

# 16. 出题规则

支持两种题型。

## 16.1 选择题

题干：

```text
英文 → 选择正确中文
```

包含：

```text
1 个正确答案
3 个其他单词的中文释义作为干扰项
```

选项随机排列。

---

## 16.2 填空题

题干：

```text
中文 → 输入英文
```

答案判断：

- 忽略大小写
- 忽略首尾空格

---

# 17. 自定义单词

只支持：

```text
CSV
```

格式：

```csv
english,chinese,part_of_speech
apple,苹果,n.
```

其中 `part_of_speech` 可选。

编码：

```text
UTF-8
```

使用 JDK IO 完成基础解析。

暂不要求引入 CSV 第三方库。

导入成功后：

```text
insert Word
↓
source = custom
owner_id = 当前用户
↓
insert UserWordProgress
↓
proficiency = 0
status = learning
```

用户只能删除自己的 custom 单词。

删除自定义单词时，应同步删除相关 `UserWordProgress`。

可以通过数据库：

```text
ON DELETE CASCADE
```

实现。

---

# 18. 排行榜

排行榜排序：

```sql
ORDER BY
    score DESC,
    total_likes DESC,
    created_at ASC
```

页面至少展示：

```text
排名
用户名
积分
获赞数
点赞操作
```

---

# 19. 点赞

流程：

```text
当前用户
↓
选择排行榜目标用户
↓
检查是否为自己
↓
检查是否已点赞
↓
insert likes
↓
target.total_likes + 1
```

`insertLike` 与 `total_likes + 1` 应作为同一业务操作处理。

可使用 Spring Transaction 保证一致性。

---

# 20. 页面范围

当前主要页面：

```text
login.jsp
register.jsp
home.jsp
learning.jsp
review.jsp
ranking.jsp
library.jsp
```

`home.jsp` 作为各功能模式的入口页，导航到学习、复习、词库管理、排行榜。

自定义单词管理（查看、CSV 导入、删除）与内置词库查看合并至独立的：

```text
library.jsp
```

页面顶部导航仅保留品牌入口、用户名与退出，各模式入口统一放在 `home.jsp`。

---

# 21. AI 辅助开发规则

本项目允许并预期使用 AI Agent 辅助编码。

## 21.1 技术栈变更必须说明

如果 AI 准备新增：

- Maven dependency
- Java 第三方库
- Spring 模块
- 前端库
- 数据库组件
- 构建工具
- 基础设施

必须先明确说明：

1. 新增什么
2. 为什么需要
3. 用于什么功能
4. 影响哪些模块
5. 是否修改 `pom.xml`
6. 是否增加配置
7. 是否影响另一成员环境

简单问题优先使用现有技术栈解决。

---

## 21.2 不主动增加复杂基础设施

除非明确需要，不主动加入：

```text
Spring Boot
Spring Security
JWT
Redis
MQ
WebSocket
JPA
Hibernate
MapStruct
Docker
微服务
```

---

## 21.3 控制修改范围

一次任务应围绕一个明确功能进行。

例如：

```text
实现用户登录
```

允许修改：

```text
UserController
UserService
UserMapper
login.jsp
User
相关配置
```

不得无关地重构其他模块。

---

## 21.4 公共契约修改必须说明

以下内容属于公共契约：

```text
数据库表结构
Entity 字段
Controller URL
Service 方法
Mapper 方法
Session key
业务状态常量
pom.xml
Spring 配置
MyBatis 配置
```

修改前必须明确：

```text
修改原因
影响模块
需要同步修改的文件
```

---

## 21.5 不做无关重构

如果现有代码：

```text
可以运行
逻辑正确
不会阻塞开发
```

则不因为：

```text
更现代
更优雅
最佳实践
```

而进行大规模重构。

---

# 22. Git 协作约定

主分支：

```text
main
```

`main` 只保存已经完成基本验证的代码。

功能开发使用：

```text
feat/<feature-name>
```

例如：

```text
feat/project-setup
feat/user-auth
feat/learning
feat/ranking
```

Bug 修复使用：

```text
fix/<issue-name>
```

禁止：

```text
git push --force
```

原则上不直接在 `main` 上进行长期开发。

---

# 23. Commit 规范

使用：

```text
feat:
fix:
refactor:
docs:
style:
chore:
```

例如：

```text
chore: initialize project structure

feat: implement user login

feat: implement learning mode

fix: correct proficiency update
```

一个 commit 尽量对应一个明确逻辑修改。

---

# 24. 工程目录建议

```text
word-memory-platform/
├── README.md
├── SPEC.md
├── pom.xml
├── .gitignore
│
├── docs/
│   ├── design/
│   └── diagrams/
│
├── sql/
│   ├── schema.sql
│   └── data.sql
│
└── src/
    └── main/
        ├── java/
        │   └── <base-package>/
        │       ├── controller/
        │       ├── service/
        │       ├── mapper/
        │       ├── entity/
        │       ├── dto/
        │       ├── interceptor/
        │       └── util/
        │
        ├── resources/
        │   ├── mapper/
        │   └── ...
        │
        └── webapp/
            ├── WEB-INF/
            │   └── views/
            └── static/
                ├── css/
                └── js/
```

---

# 25. 本地配置

数据库用户名、密码等本机配置不得直接写入公共仓库。

例如：

```text
database.properties
```

加入 `.gitignore`。

仓库提供：

```text
database.properties.example
```

作为配置模板。

---

# 26. 当前待确定事项

以下内容在项目初始化阶段确定：

```text
JDK 版本
Spring Framework 版本
MyBatis 版本
MyBatis-Spring 版本
Tomcat 版本
MySQL 最终版本
base package 名称
```

确定后应固定在项目配置中，避免两名成员使用不同技术版本。

---

# 27. 开发原则

本课程项目遵循：

> Simple > Complete > Elegant

优先保证：

```text
能编译
能启动
能运行
能演示
两人代码能合并
与课程文档基本一致
```

在上述目标满足之前，不主动增加额外技术复杂度。
