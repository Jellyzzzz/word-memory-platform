package com.wordmemory.platform.interceptor;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

class CsrfInterceptorTest {

    private final CsrfInterceptor interceptor = new CsrfInterceptor();
    private HttpServletRequest request;
    private HttpServletResponse response;
    private Map<String, Object> sessionAttributes;

    @BeforeEach
    void setUp() {
        HttpSession session = mock(HttpSession.class);
        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        sessionAttributes = new HashMap<>();

        when(request.getSession(true)).thenReturn(session);
        when(session.getAttribute(anyString()))
                .thenAnswer(invocation -> sessionAttributes.get(invocation.getArgument(0)));
        doAnswer(invocation -> {
            sessionAttributes.put(invocation.getArgument(0), invocation.getArgument(1));
            return null;
        }).when(session).setAttribute(anyString(), any());
    }

    @Test
    void issuesTokenOnGetAndAcceptsItOnPost() throws Exception {
        when(request.getMethod()).thenReturn("GET");
        assertTrue(interceptor.preHandle(request, response, new Object()));

        String token = (String) sessionAttributes.get(CsrfInterceptor.SESSION_ATTRIBUTE);
        assertNotNull(token);
        when(request.getMethod()).thenReturn("POST");
        when(request.getParameter(CsrfInterceptor.REQUEST_PARAMETER)).thenReturn(token);
        assertTrue(interceptor.preHandle(request, response, new Object()));
    }

    @Test
    void rejectsMissingTokenOnPost() throws Exception {
        when(request.getMethod()).thenReturn("POST");

        assertFalse(interceptor.preHandle(request, response, new Object()));
        verify(response).sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF token invalid or missing");
    }
}
