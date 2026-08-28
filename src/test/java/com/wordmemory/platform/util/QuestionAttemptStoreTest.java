package com.wordmemory.platform.util;

import com.wordmemory.platform.dto.Question;
import com.wordmemory.platform.dto.QuestionAttempt;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

class QuestionAttemptStoreTest {

    private HttpSession session;
    private Map<String, Object> attributes;

    @BeforeEach
    void setUp() {
        session = mock(HttpSession.class);
        attributes = new HashMap<>();
        when(session.getAttribute(anyString())).thenAnswer(invocation -> attributes.get(invocation.getArgument(0)));
        doAnswer(invocation -> {
            attributes.put(invocation.getArgument(0), invocation.getArgument(1));
            return null;
        }).when(session).setAttribute(anyString(), any());
        doAnswer(invocation -> {
            attributes.remove(invocation.getArgument(0));
            return null;
        }).when(session).removeAttribute(anyString());
    }

    @Test
    void consumesEachAttemptOnlyOnce() {
        Question question = question(7, "choice");
        QuestionAttempt issued = QuestionAttemptStore.issue(session, question, "learning");

        QuestionAttempt consumed = QuestionAttemptStore.consume(session, issued.getToken());
        assertNotNull(consumed);
        assertEquals(7, consumed.getWordId());
        assertEquals("learning", consumed.getMode());
        assertNull(QuestionAttemptStore.consume(session, issued.getToken()));
    }

    @Test
    void invalidTokenDoesNotConsumeValidAttempt() {
        QuestionAttempt issued = QuestionAttemptStore.issue(session, question(8, "blank"), "review");

        assertNull(QuestionAttemptStore.consume(session, "tampered"));
        assertNotNull(QuestionAttemptStore.consume(session, issued.getToken()));
    }

    private Question question(int wordId, String type) {
        Question question = new Question();
        question.setWordId(wordId);
        question.setType(type);
        return question;
    }
}
