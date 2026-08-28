# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

`word-memory-platform` (单词记忆与竞技学习平台) is a course-design Java Web app for word learning: registration/login, word learning & review, proficiency management, custom word import (CSV), ranking, and likes. "Competitive" is expressed through the leaderboard only — there is no real-time/async player-versus-player.

Two roles only: guest (register/login) and regular user (everything else). No admin role; built-in words are seeded via SQL.

This is a **traditional Spring MVC WAR project, not Spring Boot**. The repository is currently scaffolded (build config, Spring/MyBatis config, SQL schema/seed, and docs are present); `src/main/java` is empty — controllers/services/mappers/entities have not been written yet.

Authoritative docs: `README.md` (setup/deploy) and `SPEC.md` (full business + coding spec). Read `SPEC.md` before implementing any feature — it defines the rules below in detail.

## Commands

```bash
mvn clean package        # compile, run tests, package WAR -> target/word-memory-platform.war
```

Tests use **JUnit 5 + Mockito** (in `src/test/java`) and run automatically during `mvn clean package`; they are pure unit tests with mocked dependencies (no DB or servlet container required). Deploy the WAR for end-to-end verification.

**Database setup (one-time per machine):** from the repo root, run the MySQL client and source the scripts:

```sql
SOURCE sql/schema.sql;
SOURCE sql/data.sql;
```

`schema.sql` creates the `word_memory_platform` DB and four tables (idempotent, `IF NOT EXISTS`); `data.sql` seeds built-in words (idempotent, `NOT EXISTS`). Both are safe to re-run.

**Local credentials:** copy `src/main/resources/database.properties.example` → `database.properties`, then set `jdbc.url` / `jdbc.username` / `jdbc.password`. `database.properties` is git-ignored.

**Deploy:** build, then deploy `target/word-memory-platform.war` to Tomcat 9. The app connects to the DB on startup; it does not create tables or seed data itself.

## Tech stack

- JDK 21 runtime, **Java 17 bytecode** (`maven.compiler.release=17`)
- Spring Framework **5.3** / Spring MVC (XML-configured, no `@EnableWebMvc` in Java config)
- MyBatis 3.5 + MyBatis-Spring 2.1
- MySQL 8 (`mysql-connector-j` 8.4)
- JSP + JSTL, Tomcat 9 — **`javax.servlet`, NOT `jakarta.servlet`** (the API dep is `provided` scope)
- Maven WAR packaging (`<finalName>word-memory-platform</finalName>`)

## Architecture

Layered MVC, strict call direction **Controller → Service → Mapper**:

```
Browser → JSP/Bootstrap → Spring MVC Controller → Service → MyBatis Mapper → MySQL
```

Base package is **`com.wordmemory.platform`** (confirmed in the Spring XML configs). Suggested sub-packages: `controller/`, `service/`, `mapper/`, `entity/`, `dto/`, `interceptor/`, `util/`.

### Two Spring contexts (important)

The app is split into a **root context** and an **MVC child context**, wired in `src/main/webapp/WEB-INF/web.xml`:

- **Root context** (`classpath:spring-mybatis.xml`, loaded by `ContextLoaderListener`): `dataSource`, `sqlSessionFactory`, `transactionManager`, and `@Service` components (component-scan `com.wordmemory.platform.service`). Declares `<tx:annotation-driven>` for `@Transactional`.
- **MVC context** (`/WEB-INF/spring-mvc.xml`, loaded by `DispatcherServlet`): `@Controller` components (component-scan `com.wordmemory.platform.controller`), `<mvc:annotation-driven>`, `<mvc:default-servlet-handler>` (Tomcat serves static assets), and the JSP `InternalResourceViewResolver` (prefix `/WEB-INF/views/`, suffix `.jsp`).

Put `@Service`/`@Repository` beans in the root context package, `@Controller` in the MVC context package. Services must not be component-scanned by the MVC context.

### MyBatis

- `mybatis-config.xml` sets `mapUnderscoreToCamelCase=true` — DB `snake_case` columns map to camelCase entity fields automatically.
- Mapper interfaces live in `com.wordmemory.platform.mapper` and are discovered by `MapperScannerConfigurer`; mapper XML files must go under `classpath*:mapper/*.xml` (i.e. `src/main/resources/mapper/`).

### Config files

- `src/main/resources/spring-mybatis.xml` — root context (DB, transactions, service scan)
- `src/main/resources/mybatis-config.xml` — MyBatis settings
- `src/main/resources/database.properties` — local credentials (ignored; template is `database.properties.example`)
- `src/main/webapp/WEB-INF/web.xml` — servlet/filter/listener wiring, UTF-8 filter
- `src/main/webapp/WEB-INF/spring-mvc.xml` — MVC context

## Data model

Four tables, defined in `sql/schema.sql` (this file is the source of truth — column names, `CHECK` constraints, and FKs all live here):

- `users` — `user_id`, `username` (UNIQUE), `password_hash` (SHA-256 hex), `salt`, `score`, `total_likes`, `created_at`
- `words` — `word_id`, `english`, `chinese`, `part_of_speech`, `source` (`builtin`/`custom`), `owner_id` (NULL for builtin; FK to `users`)
- `user_word_progress` — per-user per-word state: `proficiency` (0–5), `status` (`learning`/`mastered`), UNIQUE(`user_id`,`word_id`)
- `likes` — `from_user_id`/`to_user_id`, UNIQUE pair, `CHECK` prevents self-like

Deleting a custom word cascades to its `user_word_progress` rows via `ON DELETE CASCADE`.

## Key conventions (enforced in SPEC.md)

- **Do not add new infrastructure** — no Spring Boot, Spring Security, JWT, Redis, MQ, WebSocket, JPA/Hibernate, MapStruct, Docker, or microservices. Any new Maven dependency/library/Spring module must be explicitly justified (what, why, which feature, which modules it affects, whether `pom.xml`/config changes) before adding it.
- **No unrelated refactoring** — one task = one feature. If existing code compiles/runs and isn't blocking, do not "modernize" or "clean up" it. Priority is `Simple > Complete > Elegant`.
- **Public contract** — DB schema, entity fields, controller URLs, service/mapper methods, session keys, business-status constants, `pom.xml`, and Spring/MyBatis config are shared contract; explain the reason and the set of files to change before touching any of them.
- **Auth** — `HttpSession` key `userId`; `LoginInterceptor` redirects unauthenticated requests to `redirect:/login`. No JWT/Spring Security.
- **Passwords** — SHA-256 with a random salt, stored as `password_hash` + `salt`; minimum length 6.
- **Layering** — controllers never call mappers directly; JSP never touches the DB.

## Git conventions

- `main` holds only verified code; do long-term work on `feat/<name>` / `fix/<name>` branches.
- Conventional commit prefixes: `feat:`, `fix:`, `refactor:`, `docs:`, `style:`, `chore:`; one commit = one logical change.
- Never `git push --force`.
