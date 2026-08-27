package com.wordmemory.platform.util;

import com.wordmemory.platform.entity.Word;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class CsvUtilTest {

    @Test
    void parsesSimpleAndQuotedFields() {
        Word simple = CsvUtil.parseLine("apple,苹果,n.");
        assertNotNull(simple);
        assertEquals("apple", simple.getEnglish());
        assertEquals("苹果", simple.getChinese());
        assertEquals("n.", simple.getPartOfSpeech());

        Word quoted = CsvUtil.parseLine("\"take, off\",\"起飞, 脱下\",\"v.\"");
        assertNotNull(quoted);
        assertEquals("take, off", quoted.getEnglish());
        assertEquals("起飞, 脱下", quoted.getChinese());
    }

    @Test
    void acceptsBomHeaderWithoutImportingItAsAWord() {
        assertTrue(CsvUtil.isHeader("\uFEFFenglish,chinese,part_of_speech"));
        assertTrue(CsvUtil.isBlankLine("\uFEFF  "));
    }

    @Test
    void rejectsMalformedOrOutOfRangeRows() {
        assertNull(CsvUtil.parseLine("only-one-column"));
        assertNull(CsvUtil.parseLine("a,b,c,d"));
        assertNull(CsvUtil.parseLine("\"unclosed,b"));
        assertNull(CsvUtil.parseLine("a,b," + "x".repeat(21)));
        assertNull(CsvUtil.parseLine("a,bad\u0000value"));
    }
}
