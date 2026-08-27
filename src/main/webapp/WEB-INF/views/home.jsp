<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>首页 - 单词记忆平台</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<c:url value='/static/css/style.css'/>" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-expand navbar-dark bg-primary mb-4">
    <div class="container">
        <a class="navbar-brand" href="<c:url value='/home'/>">单词记忆平台</a>
        <span class="navbar-text ms-auto">
            ${sessionScope.username}
            <a class="btn btn-sm btn-outline-light ms-2" href="<c:url value='/logout'/>">退出</a>
        </span>
    </div>
</nav>
<div class="container">
    <div class="p-4 mb-4 bg-white rounded shadow-sm text-center">
        <h2>欢迎，${sessionScope.username}</h2>
        <p class="text-muted mb-0">选择一个模式开始学习</p>
    </div>

    <div class="row g-4">
        <div class="col-md-6">
            <a href="<c:url value='/learning'/>" class="text-decoration-none">
                <div class="card h-100 text-center">
                    <div class="card-body p-4">
                        <h4 class="card-title text-primary">学习模式</h4>
                        <p class="card-text text-muted">学习待掌握的新单词</p>
                    </div>
                </div>
            </a>
        </div>
        <div class="col-md-6">
            <a href="<c:url value='/review'/>" class="text-decoration-none">
                <div class="card h-100 text-center">
                    <div class="card-body p-4">
                        <h4 class="card-title text-primary">复习模式</h4>
                        <p class="card-text text-muted">巩固已掌握的单词</p>
                    </div>
                </div>
            </a>
        </div>
        <div class="col-md-6">
            <a href="<c:url value='/words'/>" class="text-decoration-none">
                <div class="card h-100 text-center">
                    <div class="card-body p-4">
                        <h4 class="card-title text-primary">词库管理</h4>
                        <p class="card-text text-muted">查看词库、导入自定义单词</p>
                    </div>
                </div>
            </a>
        </div>
        <div class="col-md-6">
            <a href="<c:url value='/ranking'/>" class="text-decoration-none">
                <div class="card h-100 text-center">
                    <div class="card-body p-4">
                        <h4 class="card-title text-primary">排行榜</h4>
                        <p class="card-text text-muted">查看积分排名并点赞</p>
                    </div>
                </div>
            </a>
        </div>
    </div>
</div>
</body>
</html>
