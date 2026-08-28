package com.wordmemory.platform.dto;

/**
 * 答题请求参数。选择题的 answer 为所选中文释义，填空题的 answer 为用户输入的英文。
 */
public class AnswerRequest {

    private String answer;

    public String getAnswer() {
        return answer;
    }

    public void setAnswer(String answer) {
        this.answer = answer;
    }
}
