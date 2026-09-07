<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>登录 - 单词记忆平台</title>
    <link href="<c:url value='/static/css/style.css'/>?v=2" rel="stylesheet">
</head>
<body class="auth-body">
<main class="auth-shell">
    <section class="auth-showcase" aria-label="单词记忆平台介绍">
        <div class="auth-brand">
            <span class="brand-mark" aria-hidden="true">W</span>
            <span>WORD MEMORY</span>
        </div>
        <div class="auth-message">
            <h1>每天一点，<br>真正记住。</h1>
            <p>用清晰的练习、复习和熟练度反馈，让每一个单词都留下来。</p>
        </div>
        <div class="floating-words" aria-hidden="true">
            <span class="floating-word">HELLO</span>
            <span class="floating-word">MEMORY</span>
            <span class="floating-word">LEARN</span>
            <span class="floating-word">WORLD</span>
        </div>
    </section>

    <section class="auth-panel">
        <p class="auth-kicker">Welcome back</p>
        <h2 class="auth-title">继续你的学习</h2>
        <p class="auth-description">登录后回到自己的单词进度。</p>

        <c:if test="${not empty error}">
            <div class="notice notice--error" role="alert">
                <span aria-hidden="true">!</span>
                <c:out value="${error}"/>
            </div>
        </c:if>

        <form action="<c:url value='/login'/>" method="post">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
            <div class="form-group">
                <label class="form-label" for="username">用户名</label>
                <input id="username" type="text" name="username" class="form-control"
                       required autocomplete="username" autofocus>
            </div>
            <div class="form-group">
                <label class="form-label" for="password">密码</label>
                <input id="password" type="password" name="password" class="form-control"
                       required autocomplete="current-password">
            </div>
            <button type="submit" class="game-button game-button--wide">登录</button>
        </form>

        <p class="auth-footer">还没有账号？<a href="<c:url value='/register'/>">立即注册</a></p>
    </section>
</main>
</body>
</html>
