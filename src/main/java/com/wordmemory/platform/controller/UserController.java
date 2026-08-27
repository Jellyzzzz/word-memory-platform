package com.wordmemory.platform.controller;

import com.wordmemory.platform.dto.LoginRequest;
import com.wordmemory.platform.dto.RegisterRequest;
import com.wordmemory.platform.entity.User;
import com.wordmemory.platform.interceptor.CsrfInterceptor;
import com.wordmemory.platform.service.UserService;
import com.wordmemory.platform.util.QuestionAttemptStore;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * 用户模块控制器：注册、登录、退出。
 */
@Controller
public class UserController {

    @Autowired
    private UserService userService;

    /** 根路径：已登录则进入首页（未登录会被 LoginInterceptor 重定向到 /login）。 */
    @GetMapping("/")
    public String index() {
        return "redirect:/home";
    }

    @GetMapping("/login")
    public String loginPage(HttpSession session) {
        if (session.getAttribute("userId") != null) {
            return "redirect:/home";
        }
        return "login";
    }

    @PostMapping("/login")
    public String login(@ModelAttribute LoginRequest request, HttpServletRequest servletRequest,
                        HttpSession session, Model model) {
        User user = userService.login(request.getUsername(), request.getPassword());
        if (user == null) {
            model.addAttribute("error", "用户名或密码错误");
            return "login";
        }
        servletRequest.changeSessionId();
        QuestionAttemptStore.clear(session);
        CsrfInterceptor.rotateToken(session);
        session.setAttribute("userId", user.getUserId());
        session.setAttribute("username", user.getUsername());
        return "redirect:/home";
    }

    @GetMapping("/register")
    public String registerPage(HttpSession session) {
        if (session.getAttribute("userId") != null) {
            return "redirect:/home";
        }
        return "register";
    }

    @PostMapping("/register")
    public String register(@ModelAttribute RegisterRequest request, Model model) {
        if (request.getPassword() == null || !request.getPassword().equals(request.getConfirmPassword())) {
            model.addAttribute("error", "两次输入的密码不一致");
            return "register";
        }
        try {
            userService.register(request.getUsername(), request.getPassword());
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "register";
        }
        return "redirect:/login";
    }

    @PostMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }
}
