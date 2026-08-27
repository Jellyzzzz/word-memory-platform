package com.wordmemory.platform.dto;

import java.util.List;

/**
 * 出题结果。type 取值 choice（选择题）/ blank（填空题）。
 * 选择题展示 english 与 options；填空题展示 chinese 由用户输入英文。
 */
public class Question {

    private Integer wordId;
    private String type;
    private String english;
    private String chinese;
    private String partOfSpeech;
    private List<String> options;

    public Integer getWordId() {
        return wordId;
    }

    public void setWordId(Integer wordId) {
        this.wordId = wordId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getEnglish() {
        return english;
    }

    public void setEnglish(String english) {
        this.english = english;
    }

    public String getChinese() {
        return chinese;
    }

    public void setChinese(String chinese) {
        this.chinese = chinese;
    }

    public String getPartOfSpeech() {
        return partOfSpeech;
    }

    public void setPartOfSpeech(String partOfSpeech) {
        this.partOfSpeech = partOfSpeech;
    }

    public List<String> getOptions() {
        return options;
    }

    public void setOptions(List<String> options) {
        this.options = options;
    }
}
