package com.wordmemory.platform.entity;

/**
 * 用户单词学习进度实体，对应 user_word_progress 表。
 * proficiency 取值 0-5；status 取值 learning/mastered。
 */
public class UserWordProgress {

    private Integer id;
    private Integer userId;
    private Integer wordId;
    private int proficiency;
    private String status;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getWordId() {
        return wordId;
    }

    public void setWordId(Integer wordId) {
        this.wordId = wordId;
    }

    public int getProficiency() {
        return proficiency;
    }

    public void setProficiency(int proficiency) {
        this.proficiency = proficiency;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
