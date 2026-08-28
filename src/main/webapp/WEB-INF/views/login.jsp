<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>登录 - 单词记忆平台</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<c:url value='/static/css/style.css'/>" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-5 col-lg-4 mt-5">
            <div class="card shadow-sm">
                <div class="card-body p-4">
                    <h3 class="text-center mb-4">单词记忆平台</h3>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger py-2"><c:out value="${error}"/></div>
                    </c:if>
                    <form action="<c:url value='/login'/>" method="post">
                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                        <div class="mb-3">
                            <label class="form-label">用户名</label>
                            <input type="text" name="username" class="form-control" required autofocus>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">密码</label>
                            <input type="password" name="password" class="form-control" required>
                        </div>
                        <button type="submit" class="btn btn-primary w-100">登录</button>
                    </form>
                    <div class="text-center mt-3">
                        <a href="<c:url value='/register'/>">没有账号？去注册</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
