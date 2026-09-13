<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>注册 - 单词记忆平台</title>
    <link href="<c:url value='/static/css/style.css'/>?v=2" rel="stylesheet">
</head>
<body class="auth-body">
<main class="auth-shell">
    <section class="auth-showcase auth-showcase--register" aria-label="单词记忆平台介绍">
        <div class="auth-brand">
            <span class="brand-mark" aria-hidden="true">W</span>
            <span>WORD MEMORY</span>
        </div>
        <div class="auth-message">
            <h1>从今天开始，<br>积累每一步。</h1>
            <p>创建账号，开始学习、复习，并在排行榜上记录自己的坚持。</p>
        </div>
        <div class="floating-words" aria-hidden="true">
            <span class="floating-word">START</span>
            <span class="floating-word">FOCUS</span>
            <span class="floating-word">REVIEW</span>
            <span class="floating-word">GROW</span>
        </div>
    </section>

    <section class="auth-panel">
        <p class="auth-kicker auth-kicker--review">Create account</p>
        <h2 class="auth-title">注册学习账号</h2>
        <p class="auth-description">设置用户名和至少 6 位密码即可开始。</p>

        <c:if test="${not empty error}">
            <div class="notice notice--error" role="alert">
                <span aria-hidden="true">!</span>
                <c:out value="${error}"/>
            </div>
        </c:if>

        <form action="<c:url value='/register'/>" method="post">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
            <div class="form-group">
                <label class="form-label" for="username">用户名</label>
                <input id="username" type="text" name="username" class="form-control"
                       required maxlength="50" autocomplete="username" autofocus>
            </div>
            <div class="form-group">
                <label class="form-label" for="password">密码</label>
                <input id="password" type="password" name="password" class="form-control"
                       required minlength="6" autocomplete="new-password">
            </div>
            <div class="form-group">
                <label class="form-label" for="confirm-password">确认密码</label>
                <input id="confirm-password" type="password" name="confirmPassword" class="form-control"
                       required minlength="6" autocomplete="new-password">
            </div>
            <button type="submit" class="game-button game-button--review game-button--wide">创建账号</button>
        </form>

        <p class="auth-footer">已经有账号？<a href="<c:url value='/login'/>">返回登录</a></p>
    </section>
</main>
</body>
</html>
