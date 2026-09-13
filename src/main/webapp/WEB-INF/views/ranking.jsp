<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>排行榜 - 单词记忆平台</title>
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
            <a class="back-link" href="<c:url value='/home'/>">← 返回首页</a>
            <span class="user-chip">
                <span class="user-avatar" aria-hidden="true">👤</span>
                <c:out value="${sessionScope.username}"/>
            </span>
            <form action="<c:url value='/logout'/>" method="post" class="logout-form">
                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                <button type="submit" class="logout-button">退出</button>
            </form>
        </div>
    </div>
</header>

<main class="app-container page-shell">
    <div class="page-heading">
        <div>
            <p class="page-kicker">Leaderboard</p>
            <h1 class="page-title">学习排行榜</h1>
            <p class="page-description">每一次正确作答都会积累积分，坚持学习的人值得被看见。</p>
        </div>
    </div>

    <c:if test="${not empty message}">
        <div class="notice notice--success" role="status">
            <span aria-hidden="true">♥</span>
            <c:out value="${message}"/>
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="notice notice--error" role="alert">
            <span aria-hidden="true">!</span>
            <c:out value="${error}"/>
        </div>
    </c:if>

    <c:choose>
        <c:when test="${empty ranking}">
            <section class="surface-card empty-state">
                <span class="empty-icon" aria-hidden="true">★</span>
                <h2>排行榜还没有数据</h2>
                <p>完成学习任务后，你的积分会出现在这里。</p>
                <a href="<c:url value='/learning'/>" class="game-button">开始学习</a>
            </section>
        </c:when>
        <c:otherwise>
            <section class="podium-grid" aria-label="排行榜前三名">
                <c:forEach var="user" items="${ranking}" end="2" varStatus="st">
                    <article class="podium-card podium-card--${st.count} ${user.userId == currentUserId ? 'is-current' : ''}">
                        <span class="podium-medal" aria-hidden="true">
                            <c:choose>
                                <c:when test="${st.count == 1}">🥇</c:when>
                                <c:when test="${st.count == 2}">🥈</c:when>
                                <c:otherwise>🥉</c:otherwise>
                            </c:choose>
                        </span>
                        <h2 class="podium-name">
                            <c:out value="${user.username}"/>
                            <c:if test="${user.userId == currentUserId}"><span class="you-badge">你</span></c:if>
                        </h2>
                        <p class="podium-score"><c:out value="${user.score}"/> <span>积分</span></p>
                        <div class="like-line">♥ <c:out value="${user.totalLikes}"/> 个赞</div>

                        <c:choose>
                            <c:when test="${user.userId == currentUserId}">
                                <span class="like-action like-action--self">你的名次</span>
                            </c:when>
                            <c:when test="${likedUserIds.contains(user.userId)}">
                                <span class="like-action like-action--done">♥ 已点赞</span>
                            </c:when>
                            <c:otherwise>
                                <form action="<c:url value='/ranking/like'/>" method="post">
                                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                    <input type="hidden" name="toUserId" value="${user.userId}">
                                    <button type="submit" class="like-action">♡ 点赞</button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                    </article>
                </c:forEach>
            </section>

            <c:if test="${fn:length(ranking) gt 3}">
                <section class="surface-card ranking-list" aria-label="其他排名">
                    <h2 class="ranking-list-title">继续前进</h2>
                    <c:forEach var="user" items="${ranking}" begin="3" varStatus="st">
                        <article class="ranking-row ${user.userId == currentUserId ? 'is-current' : ''}">
                            <span class="rank-number">#<c:out value="${st.index + 1}"/></span>
                            <span class="rank-user">
                                <c:out value="${user.username}"/>
                                <c:if test="${user.userId == currentUserId}"><span class="you-badge">你</span></c:if>
                            </span>
                            <span class="rank-stat"><strong><c:out value="${user.score}"/></strong> 积分</span>
                            <span class="rank-stat rank-stat--likes">♥ <strong><c:out value="${user.totalLikes}"/></strong></span>
                            <span class="rank-action">
                                <c:choose>
                                    <c:when test="${user.userId == currentUserId}">
                                        <span class="like-action like-action--self">自己</span>
                                    </c:when>
                                    <c:when test="${likedUserIds.contains(user.userId)}">
                                        <span class="like-action like-action--done">♥ 已点赞</span>
                                    </c:when>
                                    <c:otherwise>
                                        <form action="<c:url value='/ranking/like'/>" method="post">
                                            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                            <input type="hidden" name="toUserId" value="${user.userId}">
                                            <button type="submit" class="like-action">♡ 点赞</button>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </article>
                    </c:forEach>
                </section>
            </c:if>
        </c:otherwise>
    </c:choose>
</main>

<nav class="mobile-nav" aria-label="主要导航">
    <a href="<c:url value='/learning'/>"><span class="nav-icon" aria-hidden="true">▶</span><span>学习</span></a>
    <a href="<c:url value='/review'/>"><span class="nav-icon" aria-hidden="true">↻</span><span>复习</span></a>
    <a href="<c:url value='/words'/>"><span class="nav-icon" aria-hidden="true">Aa</span><span>词库</span></a>
    <a class="is-active" href="<c:url value='/ranking'/>"><span class="nav-icon" aria-hidden="true">★</span><span>排行</span></a>
</nav>
</body>
</html>
