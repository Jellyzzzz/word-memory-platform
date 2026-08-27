<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>学习 - 单词记忆平台</title>
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
    <div class="quiz-card mx-auto">
        <c:if test="${not empty error}">
            <div class="alert alert-danger"><c:out value="${error}"/></div>
        </c:if>
        <c:choose>
            <c:when test="${not empty result}">
                <div class="card">
                    <div class="card-header">学习模式</div>
                    <div class="card-body">
                        <p class="fs-4"><c:out value="${question.english}"/> <span class="text-muted fs-6"><c:out value="${question.chinese}"/></span></p>
                        <c:if test="${not empty question.partOfSpeech}">
                            <span class="badge bg-secondary"><c:out value="${question.partOfSpeech}"/></span>
                        </c:if>
                        <c:choose>
                            <c:when test="${result.correct}">
                                <div class="alert alert-success mt-3 mb-3">回答正确</div>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-danger mt-3 mb-3">回答错误，正确答案：<c:out value="${result.correctAnswer}"/></div>
                            </c:otherwise>
                        </c:choose>
                        <a href="<c:url value='/learning'/>" class="btn btn-primary w-100">下一个</a>
                    </div>
                </div>
            </c:when>
            <c:when test="${empty question}">
                <div class="alert alert-info text-center py-5">暂无待学习单词</div>
            </c:when>
            <c:otherwise>
                <div class="card">
                    <div class="card-header">学习模式</div>
                    <div class="card-body">
                        <form action="<c:url value='/learning/answer'/>" method="post">
                            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                            <input type="hidden" name="questionToken" value="${questionToken}">
                            <c:choose>
                                <c:when test="${question.type == 'choice'}">
                                    <p class="fs-5">请选择「<c:out value="${question.english}"/>」的中文释义</p>
                                    <c:if test="${not empty question.partOfSpeech}">
                                        <span class="badge bg-secondary mb-2"><c:out value="${question.partOfSpeech}"/></span>
                                    </c:if>
                                    <div class="option-list mt-2">
                                        <c:forEach var="opt" items="${question.options}">
                                            <label>
                                                <input type="radio" name="answer" value="${fn:escapeXml(opt)}" required> <c:out value="${opt}"/>
                                            </label>
                                        </c:forEach>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <p class="fs-5">请输入「<c:out value="${question.chinese}"/>」对应的英文单词</p>
                                    <c:if test="${not empty question.partOfSpeech}">
                                        <span class="badge bg-secondary mb-2"><c:out value="${question.partOfSpeech}"/></span>
                                    </c:if>
                                    <input type="text" name="answer" class="form-control" required autocomplete="off">
                                </c:otherwise>
                            </c:choose>
                            <button type="submit" class="btn btn-primary mt-3 w-100">提交</button>
                        </form>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>
</body>
</html>
