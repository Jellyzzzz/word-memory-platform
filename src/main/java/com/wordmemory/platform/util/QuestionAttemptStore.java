package com.wordmemory.platform.util;

import com.wordmemory.platform.dto.Question;
import com.wordmemory.platform.dto.QuestionAttempt;

import javax.servlet.http.HttpSession;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;

/** 在 Session 中签发并原子消费一次性题目，防止参数篡改和重复计分。 */
public final class QuestionAttemptStore {

    public static final String SESSION_ATTRIBUTE = "questionAttempts";

    private static final int MAX_ATTEMPTS = 10;
    private static final long ATTEMPT_TTL_MILLIS = 30L * 60L * 1000L;

    private QuestionAttemptStore() {
    }

    public static QuestionAttempt issue(HttpSession session, Question question, String mode) {
        long now = System.currentTimeMillis();
        QuestionAttempt attempt = new QuestionAttempt(
                SecureTokenUtil.generateToken(),
                question.getWordId(),
                mode,
                question.getType(),
                now
        );
        synchronized (session) {
            Map<String, QuestionAttempt> attempts = getOrCreateAttempts(session);
            removeExpired(attempts, now);
            while (attempts.size() >= MAX_ATTEMPTS) {
                Iterator<String> iterator = attempts.keySet().iterator();
                if (iterator.hasNext()) {
                    iterator.next();
                    iterator.remove();
                }
            }
            attempts.put(attempt.getToken(), attempt);
        }
        return attempt;
    }

    public static QuestionAttempt consume(HttpSession session, String token) {
        if (session == null || token == null || token.isBlank()) {
            return null;
        }
        synchronized (session) {
            Object value = session.getAttribute(SESSION_ATTRIBUTE);
            if (!(value instanceof Map<?, ?>)) {
                return null;
            }
            @SuppressWarnings("unchecked")
            Map<String, QuestionAttempt> attempts = (Map<String, QuestionAttempt>) value;
            long now = System.currentTimeMillis();
            removeExpired(attempts, now);
            QuestionAttempt attempt = attempts.remove(token);
            if (attempt == null || now - attempt.getIssuedAtMillis() > ATTEMPT_TTL_MILLIS) {
                return null;
            }
            return attempt;
        }
    }

    public static void clear(HttpSession session) {
        if (session != null) {
            synchronized (session) {
                session.removeAttribute(SESSION_ATTRIBUTE);
            }
        }
    }

    private static Map<String, QuestionAttempt> getOrCreateAttempts(HttpSession session) {
        Object value = session.getAttribute(SESSION_ATTRIBUTE);
        if (value instanceof Map<?, ?>) {
            @SuppressWarnings("unchecked")
            Map<String, QuestionAttempt> attempts = (Map<String, QuestionAttempt>) value;
            return attempts;
        }
        Map<String, QuestionAttempt> attempts = new LinkedHashMap<>();
        session.setAttribute(SESSION_ATTRIBUTE, attempts);
        return attempts;
    }

    private static void removeExpired(Map<String, QuestionAttempt> attempts, long now) {
        attempts.values().removeIf(attempt -> now - attempt.getIssuedAtMillis() > ATTEMPT_TTL_MILLIS);
    }
}
