package com.wordmemory.platform.interceptor;

import com.wordmemory.platform.util.SecureTokenUtil;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Set;

/** 为所有修改状态的请求提供基于 Session 的 CSRF 防护。 */
public class CsrfInterceptor implements HandlerInterceptor {

    public static final String SESSION_ATTRIBUTE = "csrfToken";
    public static final String REQUEST_PARAMETER = "_csrf";

    private static final Set<String> SAFE_METHODS = Set.of("GET", "HEAD", "OPTIONS", "TRACE");

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        HttpSession session = request.getSession(true);
        String expected = ensureToken(session);
        if (SAFE_METHODS.contains(request.getMethod())) {
            return true;
        }

        String actual = request.getParameter(REQUEST_PARAMETER);
        if (!constantTimeEquals(expected, actual)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF token invalid or missing");
            return false;
        }
        return true;
    }

    public static void rotateToken(HttpSession session) {
        session.setAttribute(SESSION_ATTRIBUTE, SecureTokenUtil.generateToken());
    }

    private static String ensureToken(HttpSession session) {
        Object value = session.getAttribute(SESSION_ATTRIBUTE);
        if (value instanceof String && !((String) value).isBlank()) {
            return (String) value;
        }
        String token = SecureTokenUtil.generateToken();
        session.setAttribute(SESSION_ATTRIBUTE, token);
        return token;
    }

    private static boolean constantTimeEquals(String expected, String actual) {
        if (expected == null || actual == null) {
            return false;
        }
        return MessageDigest.isEqual(
                expected.getBytes(StandardCharsets.UTF_8),
                actual.getBytes(StandardCharsets.UTF_8)
        );
    }
}
