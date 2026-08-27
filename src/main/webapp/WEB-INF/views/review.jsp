<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>复习 - 单词记忆平台</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<c:url value='/static/css/style.css'/>" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-expand navbar-dark bg-primary mb-4">
    <div class="container">
        <a class="navbar-brand" href="<c:url value='/home'/>">单词记忆平台</a>
        <ul class="navbar-nav me-auto">
            <li class="nav-item"><a class="nav-link" href="<c:url value='/home'/>">首页</a></li>
            <li class="nav-item"><a class="nav-link" href="<c:url value='/learning'/>">学习</a></li>
            <li class="nav-item"><a class="nav-link" href="<c:url value='/review'/>">复习</a></li>
            <li class="nav-item"><a class="nav-link" href="<c:url value='/ranking'/>">排行榜</a></li>
        </ul>
        <span class="navbar-text">
            ${sessionScope.username}
            <a class="btn btn-sm btn-outline-light ms-2" href="<c:url value='/logout'/>">退出</a>
        </span>
    </div>
</nav>
<div class="container">
    <div class="quiz-card mx-auto">
        <c:if test="${not empty message}">
            <div class="alert alert-success">${message}</div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>
        <c:if test="${not empty result}">
            <div class="alert ${result.correct ? 'alert-success' : 'alert-danger'}">
                ${result.correct ? '回答正确' : '回答错误'}，正确答案：${result.correctAnswer}，熟练度：${result.proficiency}
            </div>
        </c:if>

        <c:choose>
            <c:when test="${empty question}">
                <div class="alert alert-info text-center py-5">暂无待复习单词</div>
            </c:when>
            <c:otherwise>
                <div class="card">
                    <div class="card-header">复习模式</div>
                    <div class="card-body">
                        <form action="<c:url value='/learning/answer'/>" method="post">
                            <input type="hidden" name="wordId" value="${question.wordId}">
                            <input type="hidden" name="mode" value="review">
                            <c:choose>
                                <c:when test="${question.type == 'choice'}">
                                    <p class="fs-5">请选择「${question.english}」的中文释义</p>
                                    <c:if test="${not empty question.partOfSpeech}">
                                        <span class="badge bg-secondary mb-2">${question.partOfSpeech}</span>
                                    </c:if>
                                    <div class="option-list mt-2">
                                        <c:forEach var="opt" items="${question.options}">
                                            <label>
                                                <input type="radio" name="answer" value="${opt}" required> ${opt}
                                            </label>
                                        </c:forEach>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <p class="fs-5">请输入「${question.chinese}」对应的英文单词</p>
                                    <c:if test="${not empty question.partOfSpeech}">
                                        <span class="badge bg-secondary mb-2">${question.partOfSpeech}</span>
                                    </c:if>
                                    <input type="text" name="answer" class="form-control" required autocomplete="off">
                                </c:otherwise>
                            </c:choose>
                            <button type="submit" class="btn btn-primary mt-3 w-100">提交</button>
                        </form>
                        <form action="<c:url value='/learning/mark-unfamiliar'/>" method="post" class="mt-2">
                            <input type="hidden" name="wordId" value="${question.wordId}">
                            <button type="submit" class="btn btn-outline-warning w-100">标记为不熟练</button>
                        </form>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>
</body>
</html>
