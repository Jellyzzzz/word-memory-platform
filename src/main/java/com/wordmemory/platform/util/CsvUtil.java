package com.wordmemory.platform.util;

import com.wordmemory.platform.entity.Word;

/**
 * CSV 解析工具，使用 JDK 自带 IO 手动解析，不引入第三方 CSV 库。
 * 每行一条：english,chinese[,part_of_speech]，UTF-8 编码。
 */
public final class CsvUtil {

    private CsvUtil() {
    }

    /**
     * 解析一行 CSV，返回填充了 english/chinese/partOfSpeech 的 Word；
     * 空行或格式错误（字段缺失）返回 null。source/ownerId 由调用方设置。
     */
    public static Word parseLine(String line) {
        if (line == null) {
            return null;
        }
        String trimmed = line.trim();
        if (trimmed.isEmpty()) {
            return null;
        }

        String[] parts = trimmed.split(",");
        if (parts.length < 2) {
            return null;
        }

        String english = parts[0].trim();
        String chinese = parts[1].trim();
        if (english.isEmpty() || chinese.isEmpty()) {
            return null;
        }

        Word word = new Word();
        word.setEnglish(english);
        word.setChinese(chinese);
        if (parts.length >= 3 && !parts[2].trim().isEmpty()) {
            word.setPartOfSpeech(parts[2].trim());
        }
        return word;
    }
}
