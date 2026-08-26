USE word_memory_platform;

INSERT INTO words (english, chinese, part_of_speech, source, owner_id)
SELECT 'apple', '苹果', 'noun', 'builtin', NULL
WHERE NOT EXISTS (
    SELECT 1 FROM words WHERE english = 'apple' AND source = 'builtin'
);

INSERT INTO words (english, chinese, part_of_speech, source, owner_id)
SELECT 'learn', '学习', 'verb', 'builtin', NULL
WHERE NOT EXISTS (
    SELECT 1 FROM words WHERE english = 'learn' AND source = 'builtin'
);
