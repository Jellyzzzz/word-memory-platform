package com.wordmemory.platform.controller;

import com.wordmemory.platform.dto.LoginRequest;
import com.wordmemory.platform.entity.User;
import com.wordmemory.platform.interceptor.CsrfInterceptor;
import com.wordmemory.platform.service.UserService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.ui.Model;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserControllerTest {

    @Mock
    private UserService userService;

    @InjectMocks
    private UserController controller;

    @Test
    void successfulLoginChangesSessionIdAndRotatesCsrfToken() {
        LoginRequest request = new LoginRequest();
        request.setUsername("alice");
        request.setPassword("secret1");
        User user = new User();
        user.setUserId(7);
        user.setUsername("alice");
        when(userService.login("alice", "secret1")).thenReturn(user);

        HttpServletRequest servletRequest = mock(HttpServletRequest.class);
        HttpSession session = mock(HttpSession.class);
        Model model = mock(Model.class);

        assertEquals("redirect:/home", controller.login(request, servletRequest, session, model));
        verify(servletRequest).changeSessionId();
        verify(session).setAttribute(eq(CsrfInterceptor.SESSION_ATTRIBUTE), anyString());
        verify(session).setAttribute("userId", 7);
        verify(session).setAttribute("username", "alice");
    }

    @Test
    void logoutInvalidatesSession() {
        HttpSession session = mock(HttpSession.class);

        assertEquals("redirect:/login", controller.logout(session));
        verify(session).invalidate();
    }
}
