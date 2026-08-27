<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>词库管理 - 单词记忆平台</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<c:url value='/static/css/style.css'/>" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-expand navbar-dark bg-primary mb-4">
    <div class="container">
        <a class="navbar-brand" href="<c:url value='/home'/>">单词记忆平台</a>
        <a class="btn btn-sm btn-outline-light ms-2" href="<c:url value='/home'/>">返回首页</a>
        <span class="navbar-text ms-auto">
            ${sessionScope.username}
            <a class="btn btn-sm btn-outline-light ms-2" href="<c:url value='/logout'/>">退出</a>
        </span>
    </div>
</nav>
<div class="container">
    <c:if test="${not empty message}">
        <div class="alert alert-success">${message}</div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>
    <c:if test="${not empty importResult}">
        <div class="alert alert-success">导入完成：成功 ${importResult.success} 条，失败 ${importResult.failed} 条</div>
    </c:if>

    <div class="card mb-4">
        <div class="card-header">导入自定义单词（CSV）</div>
        <div class="card-body">
            <p class="text-muted">格式：english,chinese[,part_of_speech]，每行一条，UTF-8 编码。例：apple,苹果,n.</p>
            <form action="<c:url value='/words/import'/>" method="post" enctype="multipart/form-data"
                  class="d-flex gap-2">
                <input type="file" name="file" accept=".csv" class="form-control" required>
                <button type="submit" class="btn btn-primary">导入</button>
            </form>
        </div>
    </div>

    <div class="card mb-4">
        <div class="card-header">内置词库 <span class="badge bg-secondary">${builtinWords.size()}</span></div>
        <div class="card-body">
            <table class="table table-striped align-middle">
                <thead>
                <tr><th>英文</th><th>中文</th><th>词性</th><th>熟练度</th><th>操作</th></tr>
                </thead>
                <tbody>
                <c:forEach var="word" items="${builtinWords}">
                    <tr>
                        <td>${word.english}</td>
                        <td>${word.chinese}</td>
                        <td>${word.partOfSpeech}</td>
                        <td><span class="badge ${word.proficiency >= 3 ? 'bg-success' : 'bg-secondary'}">${word.proficiency}</span></td>
                        <td>
                            <form action="<c:url value='/words/relearn'/>" method="post" class="d-inline">
                                <input type="hidden" name="wordId" value="${word.wordId}">
                                <button type="submit" class="btn btn-sm btn-outline-warning">重新学习</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <div class="card">
        <div class="card-header">我的自定义单词 <span class="badge bg-secondary">${customWords.size()}</span></div>
        <div class="card-body">
            <c:choose>
                <c:when test="${empty customWords}">
                    <p class="text-muted">暂无自定义单词，请通过 CSV 导入。</p>
                </c:when>
                <c:otherwise>
                    <table class="table table-striped align-middle">
                        <thead>
                        <tr><th>英文</th><th>中文</th><th>词性</th><th>熟练度</th><th>操作</th></tr>
                        </thead>
                        <tbody>
                        <c:forEach var="word" items="${customWords}">
                            <tr>
                                <td>${word.english}</td>
                                <td>${word.chinese}</td>
                                <td>${word.partOfSpeech}</td>
                                <td><span class="badge ${word.proficiency >= 3 ? 'bg-success' : 'bg-secondary'}">${word.proficiency}</span></td>
                                <td>
                                    <form action="<c:url value='/words/relearn'/>" method="post" class="d-inline">
                                        <input type="hidden" name="wordId" value="${word.wordId}">
                                        <button type="submit" class="btn btn-sm btn-outline-warning">重新学习</button>
                                    </form>
                                    <form action="<c:url value='/words/delete'/>" method="post" class="d-inline">
                                        <input type="hidden" name="wordId" value="${word.wordId}">
                                        <button type="submit" class="btn btn-sm btn-danger">删除</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>
</body>
</html>
