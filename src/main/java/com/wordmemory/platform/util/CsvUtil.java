package com.wordmemory.platform.util;

import com.wordmemory.platform.entity.Word;

import java.util.ArrayList;
import java.util.List;

/**
 * CSV 解析工具，使用 JDK 自带 IO 手动解析，不引入第三方 CSV 库。
 * 每行一条：english,chinese[,part_of_speech]，UTF-8 编码。
 */
public final class CsvUtil {

    private static final int MAX_ENGLISH_LENGTH = 100;
    private static final int MAX_CHINESE_LENGTH = 200;
    private static final int MAX_PART_OF_SPEECH_LENGTH = 20;

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
        String normalized = stripBom(line);
        String trimmed = normalized.trim();
        if (trimmed.isEmpty()) {
            return null;
        }

        List<String> parts = parseFields(trimmed);
        if (parts == null || parts.size() < 2 || parts.size() > 3) {
            return null;
        }

        String english = parts.get(0).trim();
        String chinese = parts.get(1).trim();
        String partOfSpeech = parts.size() == 3 ? parts.get(2).trim() : null;
        if (english.isEmpty() || chinese.isEmpty()
                || characterCount(english) > MAX_ENGLISH_LENGTH
                || characterCount(chinese) > MAX_CHINESE_LENGTH
                || partOfSpeech != null && characterCount(partOfSpeech) > MAX_PART_OF_SPEECH_LENGTH
                || containsUnsafeControlCharacter(english)
                || containsUnsafeControlCharacter(chinese)
                || containsUnsafeControlCharacter(partOfSpeech)) {
            return null;
        }

        Word word = new Word();
        word.setEnglish(english);
        word.setChinese(chinese);
        if (partOfSpeech != null && !partOfSpeech.isEmpty()) {
            word.setPartOfSpeech(partOfSpeech);
        }
        return word;
    }

    /** 允许 CSV 第一行包含 english,chinese[,part_of_speech] 表头。 */
    public static boolean isHeader(String line) {
        if (line == null) {
            return false;
        }
        List<String> parts = parseFields(stripBom(line).trim());
        if (parts == null || parts.size() < 2 || parts.size() > 3) {
            return false;
        }
        return "english".equalsIgnoreCase(parts.get(0).trim())
                && "chinese".equalsIgnoreCase(parts.get(1).trim());
    }

    public static boolean isBlankLine(String line) {
        return line == null || stripBom(line).trim().isEmpty();
    }

    private static List<String> parseFields(String line) {
        List<String> fields = new ArrayList<>();
        StringBuilder field = new StringBuilder();
        boolean inQuotes = false;
        boolean quoteClosed = false;

        for (int i = 0; i < line.length(); i++) {
            char ch = line.charAt(i);
            if (inQuotes) {
                if (ch == '"') {
                    if (i + 1 < line.length() && line.charAt(i + 1) == '"') {
                        field.append('"');
                        i++;
                    } else {
                        inQuotes = false;
                        quoteClosed = true;
                    }
                } else {
                    field.append(ch);
                }
                continue;
            }

            if (ch == ',') {
                fields.add(field.toString());
                field.setLength(0);
                quoteClosed = false;
            } else if (ch == '"') {
                if (quoteClosed || !field.toString().trim().isEmpty()) {
                    return null;
                }
                field.setLength(0);
                inQuotes = true;
            } else if (quoteClosed) {
                if (!Character.isWhitespace(ch)) {
                    return null;
                }
            } else {
                field.append(ch);
            }
        }

        if (inQuotes) {
            return null;
        }
        fields.add(field.toString());
        return fields;
    }

    private static String stripBom(String value) {
        return value.startsWith("\uFEFF") ? value.substring(1) : value;
    }

    private static boolean containsUnsafeControlCharacter(String value) {
        if (value == null) {
            return false;
        }
        for (int i = 0; i < value.length(); i++) {
            char ch = value.charAt(i);
            if (Character.isISOControl(ch) && ch != '\t') {
                return true;
            }
        }
        return false;
    }

    private static int characterCount(String value) {
        return value.codePointCount(0, value.length());
    }
}
