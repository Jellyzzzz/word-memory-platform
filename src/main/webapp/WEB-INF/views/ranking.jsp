<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>排行榜 - 单词记忆平台</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<c:url value='/static/css/style.css'/>" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-expand navbar-dark bg-primary mb-4">
    <div class="container">
        <a class="navbar-brand" href="<c:url value='/home'/>">单词记忆平台</a>
        <a class="btn btn-sm btn-outline-light ms-2" href="<c:url value='/home'/>">返回首页</a>
        <span class="navbar-text ms-auto">
            <c:out value="${sessionScope.username}"/>
            <form action="<c:url value='/logout'/>" method="post" class="d-inline ms-2">
                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                <button type="submit" class="btn btn-sm btn-outline-light">退出</button>
            </form>
        </span>
    </div>
</nav>
<div class="container">
    <c:if test="${not empty message}">
        <div class="alert alert-success"><c:out value="${message}"/></div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger"><c:out value="${error}"/></div>
    </c:if>

    <div class="card">
        <div class="card-header">排行榜</div>
        <div class="card-body">
            <table class="table table-striped align-middle">
                <thead>
                <tr><th>排名</th><th>用户名</th><th>积分</th><th>获赞数</th><th>操作</th></tr>
                </thead>
                <tbody>
                <c:forEach var="user" items="${ranking}" varStatus="st">
                    <tr>
                        <td>${st.index + 1}</td>
                        <td><c:out value="${user.username}"/></td>
                        <td>${user.score}</td>
                        <td>${user.totalLikes}</td>
                        <td>
                            <c:choose>
                                <c:when test="${user.userId == currentUserId}">
                                    <span class="text-muted">自己</span>
                                </c:when>
                                <c:when test="${likedUserIds.contains(user.userId)}">
                                    <button class="btn btn-sm btn-secondary" disabled>已点赞</button>
                                </c:when>
                                <c:otherwise>
                                    <form action="<c:url value='/ranking/like'/>" method="post" class="d-inline">
                                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="toUserId" value="${user.userId}">
                                        <button type="submit" class="btn btn-sm btn-primary">点赞</button>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
