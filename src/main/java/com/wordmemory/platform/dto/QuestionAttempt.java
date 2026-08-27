package com.wordmemory.platform.dto;

import java.io.Serializable;

/**
 * 服务端保存的一次性答题状态。客户端只持有 token，不能决定题目、模式或题型。
 */
public class QuestionAttempt implements Serializable {

    private static final long serialVersionUID = 1L;

    private final String token;
    private final Integer wordId;
    private final String mode;
    private final String questionType;
    private final long issuedAtMillis;

    public QuestionAttempt(String token, Integer wordId, String mode, String questionType, long issuedAtMillis) {
        this.token = token;
        this.wordId = wordId;
        this.mode = mode;
        this.questionType = questionType;
        this.issuedAtMillis = issuedAtMillis;
    }

    public String getToken() {
        return token;
    }

    public Integer getWordId() {
        return wordId;
    }

    public String getMode() {
        return mode;
    }

    public String getQuestionType() {
        return questionType;
    }

    public long getIssuedAtMillis() {
        return issuedAtMillis;
    }
}
