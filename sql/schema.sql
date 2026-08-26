CREATE DATABASE IF NOT EXISTS word_memory_platform
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE word_memory_platform;

CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(64) NOT NULL,
    salt VARCHAR(32) NOT NULL,
    score INT NOT NULL DEFAULT 0,
    total_likes INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_users_username UNIQUE (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

CREATE TABLE IF NOT EXISTS words (
    word_id INT AUTO_INCREMENT PRIMARY KEY,
    english VARCHAR(100) NOT NULL,
    chinese VARCHAR(200) NOT NULL,
    part_of_speech VARCHAR(20) DEFAULT NULL,
    source VARCHAR(10) NOT NULL,
    owner_id INT DEFAULT NULL,
    CONSTRAINT chk_words_source CHECK (source IN ('builtin', 'custom')),
    CONSTRAINT fk_words_owner FOREIGN KEY (owner_id) REFERENCES users (user_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='单词表';

CREATE TABLE IF NOT EXISTS user_word_progress (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    word_id INT NOT NULL,
    proficiency INT NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'learning',
    CONSTRAINT uk_progress_user_word UNIQUE (user_id, word_id),
    CONSTRAINT chk_progress_proficiency CHECK (proficiency BETWEEN 0 AND 5),
    CONSTRAINT chk_progress_status CHECK (status IN ('learning', 'mastered')),
    CONSTRAINT fk_progress_user FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_progress_word FOREIGN KEY (word_id) REFERENCES words (word_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户单词学习进度表';

CREATE TABLE IF NOT EXISTS likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    from_user_id INT NOT NULL,
    to_user_id INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_likes_from_to UNIQUE (from_user_id, to_user_id),
    CONSTRAINT chk_likes_not_self CHECK (from_user_id <> to_user_id),
    CONSTRAINT fk_likes_from_user FOREIGN KEY (from_user_id) REFERENCES users (user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_likes_to_user FOREIGN KEY (to_user_id) REFERENCES users (user_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='点赞记录表';
