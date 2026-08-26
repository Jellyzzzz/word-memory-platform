-- 单词记忆与竞技学习平台：MySQL 8 数据库结构
-- 可在空数据库环境重复执行，不会删除或覆盖已有业务数据。

CREATE DATABASE IF NOT EXISTS word_memory_platform
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE word_memory_platform;

CREATE TABLE IF NOT EXISTS users (
    user_id       INT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
    username      VARCHAR(50) NOT NULL COMMENT '用户名',
    password_hash VARCHAR(64) NOT NULL COMMENT 'SHA-256十六进制密码摘要',
    salt          VARCHAR(32) NOT NULL COMMENT '随机盐',
    score         INT NOT NULL DEFAULT 0 COMMENT '排行榜积分',
    total_likes   INT NOT NULL DEFAULT 0 COMMENT '获赞数',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',

    CONSTRAINT uk_users_username UNIQUE (username),
    CONSTRAINT chk_users_score CHECK (score >= 0),
    CONSTRAINT chk_users_total_likes CHECK (total_likes >= 0)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '用户表';

CREATE TABLE IF NOT EXISTS words (
    word_id        INT AUTO_INCREMENT PRIMARY KEY COMMENT '单词ID',
    english        VARCHAR(100) NOT NULL COMMENT '英文单词',
    chinese        VARCHAR(200) NOT NULL COMMENT '中文释义',
    part_of_speech VARCHAR(20) NULL COMMENT '词性',
    source         VARCHAR(10) NOT NULL COMMENT '来源：builtin/custom',
    owner_id       INT NULL COMMENT '自定义单词所属用户，内置单词为NULL',

    INDEX idx_words_source_owner (source, owner_id),
    CONSTRAINT chk_words_source CHECK (source IN ('builtin', 'custom')),
    CONSTRAINT chk_words_owner CHECK (
        (source = 'builtin' AND owner_id IS NULL)
        OR (source = 'custom' AND owner_id IS NOT NULL)
    ),
    CONSTRAINT fk_words_owner
        FOREIGN KEY (owner_id) REFERENCES users (user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '单词表';

CREATE TABLE IF NOT EXISTS user_word_progress (
    id          INT AUTO_INCREMENT PRIMARY KEY COMMENT '进度记录ID',
    user_id     INT NOT NULL COMMENT '用户ID',
    word_id     INT NOT NULL COMMENT '单词ID',
    proficiency INT NOT NULL DEFAULT 0 COMMENT '熟练度：0-5',
    status      VARCHAR(20) NOT NULL DEFAULT 'learning' COMMENT '状态：learning/mastered',

    CONSTRAINT uk_progress_user_word UNIQUE (user_id, word_id),
    INDEX idx_progress_user_status (user_id, status),
    INDEX idx_progress_word (word_id),
    CONSTRAINT chk_progress_proficiency CHECK (proficiency BETWEEN 0 AND 5),
    CONSTRAINT chk_progress_status CHECK (status IN ('learning', 'mastered')),
    CONSTRAINT fk_progress_user
        FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_progress_word
        FOREIGN KEY (word_id) REFERENCES words (word_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '用户单词学习进度表';

CREATE TABLE IF NOT EXISTS likes (
    id           INT AUTO_INCREMENT PRIMARY KEY COMMENT '点赞记录ID',
    from_user_id INT NOT NULL COMMENT '点赞用户ID',
    to_user_id   INT NOT NULL COMMENT '被点赞用户ID',
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',

    CONSTRAINT uk_likes_from_to UNIQUE (from_user_id, to_user_id),
    INDEX idx_likes_to_user (to_user_id),
    CONSTRAINT chk_likes_not_self CHECK (from_user_id <> to_user_id),
    CONSTRAINT fk_likes_from_user
        FOREIGN KEY (from_user_id) REFERENCES users (user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_likes_to_user
        FOREIGN KEY (to_user_id) REFERENCES users (user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '点赞记录表';
