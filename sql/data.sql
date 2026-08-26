-- 单词记忆与竞技学习平台：内置单词初始化数据
-- 使用 NOT EXISTS 保证脚本重复执行时不会重复插入相同内置单词。

USE word_memory_platform;

INSERT INTO words (english, chinese, part_of_speech, source, owner_id)
SELECT seed.english, seed.chinese, seed.part_of_speech, 'builtin', NULL
FROM (
    SELECT 'apple' AS english, '苹果' AS chinese, 'n.' AS part_of_speech
    UNION ALL SELECT 'book', '书', 'n.'
    UNION ALL SELECT 'computer', '计算机', 'n.'
    UNION ALL SELECT 'friend', '朋友', 'n.'
    UNION ALL SELECT 'language', '语言', 'n.'
    UNION ALL SELECT 'learn', '学习', 'v.'
    UNION ALL SELECT 'memory', '记忆', 'n.'
    UNION ALL SELECT 'practice', '练习', 'v.'
    UNION ALL SELECT 'review', '复习', 'v.'
    UNION ALL SELECT 'school', '学校', 'n.'
    UNION ALL SELECT 'student', '学生', 'n.'
    UNION ALL SELECT 'word', '单词', 'n.'
) AS seed
WHERE NOT EXISTS (
    SELECT 1
    FROM words existing
    WHERE existing.english = seed.english
      AND existing.source = 'builtin'
);
