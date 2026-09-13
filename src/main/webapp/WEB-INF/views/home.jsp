<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>首页 - 单词记忆平台</title>
    <link href="<c:url value='/static/css/style.css'/>?v=2" rel="stylesheet">
</head>
<body class="app-body">
<header class="app-header">
    <div class="app-container app-nav">
        <a class="brand" href="<c:url value='/home'/>" aria-label="单词记忆平台首页">
            <span class="brand-mark" aria-hidden="true">W</span>
            <span>WORD MEMORY</span>
        </a>
        <div class="nav-actions">
            <span class="user-chip">
                <span class="user-avatar" aria-hidden="true">👋</span>
                <c:out value="${sessionScope.username}"/>
            </span>
            <form action="<c:url value='/logout'/>" method="post" class="logout-form">
                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                <button type="submit" class="logout-button">退出</button>
            </form>
        </div>
    </div>
</header>

<main class="app-container page-shell home-page">
    <c:if test="${not empty error}">
        <div class="notice notice--error" role="alert">
            <span aria-hidden="true">!</span>
            <c:out value="${error}"/>
        </div>
    </c:if>

    <section class="home-hero">
        <p class="page-kicker">Ready to learn?</p>
        <h1 class="home-title">你好，<c:out value="${sessionScope.username}"/></h1>
        <p class="home-subtitle">今天也继续前进一点，把见过的单词真正记住。</p>
    </section>

    <section class="home-grid" aria-label="学习功能">
        <a href="<c:url value='/learning'/>" class="action-card action-card--primary">
            <span class="action-icon" aria-hidden="true">▶</span>
            <span class="action-copy">
                <span class="page-kicker page-kicker--inverse">今日任务</span>
                <strong class="action-label">继续学习</strong>
                <span class="action-description">掌握新的单词，逐步提升熟练度</span>
            </span>
            <span class="action-arrow" aria-hidden="true">→</span>
        </a>

        <a href="<c:url value='/review'/>" class="action-card">
            <span class="action-icon" aria-hidden="true">↻</span>
            <span class="action-copy">
                <strong class="action-label">复习模式</strong>
                <span class="action-description">重新挑战已掌握的内容</span>
            </span>
            <span class="action-arrow" aria-hidden="true">→</span>
        </a>

        <a href="<c:url value='/words'/>" class="action-card">
            <span class="action-icon" aria-hidden="true">Aa</span>
            <span class="action-copy">
                <strong class="action-label">我的词库</strong>
                <span class="action-description">查看熟练度，导入自己的单词</span>
            </span>
            <span class="action-arrow" aria-hidden="true">→</span>
        </a>

        <a href="<c:url value='/ranking'/>" class="action-card action-card--ranking">
            <span class="action-icon" aria-hidden="true">★</span>
            <span class="action-copy">
                <strong class="action-label">排行榜</strong>
                <span class="action-description">看看谁积累得最多，也为伙伴点个赞</span>
            </span>
            <span class="action-arrow" aria-hidden="true">→</span>
        </a>
    </section>
</main>

<nav class="mobile-nav" aria-label="主要导航">
    <a href="<c:url value='/learning'/>"><span class="nav-icon" aria-hidden="true">▶</span><span>学习</span></a>
    <a href="<c:url value='/review'/>"><span class="nav-icon" aria-hidden="true">↻</span><span>复习</span></a>
    <a href="<c:url value='/words'/>"><span class="nav-icon" aria-hidden="true">Aa</span><span>词库</span></a>
    <a href="<c:url value='/ranking'/>"><span class="nav-icon" aria-hidden="true">★</span><span>排行</span></a>
</nav>
</body>
</html>
