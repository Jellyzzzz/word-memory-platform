<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>词库管理 - 单词记忆平台</title>
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
            <p class="page-kicker">Vocabulary</p>
            <h1 class="page-title">我的词库</h1>
            <p class="page-description">查看每个单词的掌握程度，也可以导入自己的学习内容。</p>
        </div>
    </div>

    <c:if test="${not empty message}">
        <div class="notice notice--success" role="status">
            <span aria-hidden="true">✓</span>
            <c:out value="${message}"/>
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="notice notice--error" role="alert">
            <span aria-hidden="true">!</span>
            <c:out value="${error}"/>
        </div>
    </c:if>
    <c:if test="${not empty importResult}">
        <div class="notice notice--success" role="status">
            <span aria-hidden="true">✓</span>
            <span>
                导入完成：成功 <strong><c:out value="${importResult.success}"/></strong> 条，
                失败 <strong><c:out value="${importResult.failed}"/></strong> 条
            </span>
        </div>
    </c:if>

    <section class="surface-card import-card">
        <div>
            <h2 class="import-title">＋ 导入自己的单词</h2>
            <p class="import-description">上传 UTF-8 编码的 CSV 文件，每行一个单词，词性可以省略。</p>
            <code class="import-example">apple,苹果,n.</code>
        </div>
        <form action="<c:url value='/words/import'/>" method="post" enctype="multipart/form-data"
              class="import-form">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
            <label class="file-control">
                <input type="file" name="file" accept=".csv,text/csv" required aria-label="选择 CSV 文件">
            </label>
            <button type="submit" class="game-button">开始导入</button>
        </form>
    </section>

    <section class="surface-card library-card">
        <div class="library-tabs" role="tablist" aria-label="词库分类">
            <button type="button" class="library-tab is-active" role="tab" aria-selected="true"
                    aria-controls="builtin-panel" data-tab-target="builtin">
                内置词库 <span class="tab-count"><c:out value="${builtinWords.size()}"/></span>
            </button>
            <button type="button" class="library-tab" role="tab" aria-selected="false"
                    aria-controls="custom-panel" data-tab-target="custom">
                我的单词 <span class="tab-count"><c:out value="${customWords.size()}"/></span>
            </button>
        </div>

        <section id="builtin-panel" class="word-panel is-active" role="tabpanel" data-tab-panel="builtin">
            <div class="panel-heading">
                <div>
                    <h2>内置词库</h2>
                    <p>系统准备的基础学习内容</p>
                </div>
            </div>
            <c:choose>
                <c:when test="${empty builtinWords}">
                    <div class="empty-state">
                        <span class="empty-icon" aria-hidden="true">Aa</span>
                        <h2>内置词库为空</h2>
                        <p>请确认数据库初始化脚本已经执行。</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="word-list">
                        <c:forEach var="word" items="${builtinWords}">
                            <article class="word-row">
                                <div>
                                    <strong class="word-english"><c:out value="${word.english}"/></strong>
                                    <span class="word-meta">
                                        <c:out value="${word.chinese}"/>
                                        <c:if test="${not empty word.partOfSpeech}">
                                            · <c:out value="${word.partOfSpeech}"/>
                                        </c:if>
                                    </span>
                                </div>
                                <div class="word-mastery">
                                    <small>熟练度 <c:out value="${word.proficiency}"/> / 5</small>
                                    <span class="mastery-meter" aria-label="熟练度 ${word.proficiency} / 5">
                                        <span class="mastery-dot ${word.proficiency >= 1 ? 'is-filled' : ''}"></span>
                                        <span class="mastery-dot ${word.proficiency >= 2 ? 'is-filled' : ''}"></span>
                                        <span class="mastery-dot ${word.proficiency >= 3 ? 'is-filled' : ''}"></span>
                                        <span class="mastery-dot ${word.proficiency >= 4 ? 'is-filled' : ''}"></span>
                                        <span class="mastery-dot ${word.proficiency >= 5 ? 'is-filled' : ''}"></span>
                                    </span>
                                </div>
                                <div class="word-actions">
                                    <form action="<c:url value='/words/relearn'/>" method="post">
                                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="wordId" value="${word.wordId}">
                                        <button type="submit" class="compact-button">重新学习</button>
                                    </form>
                                </div>
                            </article>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>

        <section id="custom-panel" class="word-panel" role="tabpanel" data-tab-panel="custom">
            <div class="panel-heading">
                <div>
                    <h2>我的单词</h2>
                    <p>通过 CSV 导入的个人学习内容</p>
                </div>
            </div>
            <c:choose>
                <c:when test="${empty customWords}">
                    <div class="empty-state">
                        <span class="empty-icon" aria-hidden="true">＋</span>
                        <h2>还没有自定义单词</h2>
                        <p>使用上方导入工具，创建属于自己的词库。</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="word-list">
                        <c:forEach var="word" items="${customWords}">
                            <article class="word-row">
                                <div>
                                    <strong class="word-english"><c:out value="${word.english}"/></strong>
                                    <span class="word-meta">
                                        <c:out value="${word.chinese}"/>
                                        <c:if test="${not empty word.partOfSpeech}">
                                            · <c:out value="${word.partOfSpeech}"/>
                                        </c:if>
                                    </span>
                                </div>
                                <div class="word-mastery">
                                    <small>熟练度 <c:out value="${word.proficiency}"/> / 5</small>
                                    <span class="mastery-meter" aria-label="熟练度 ${word.proficiency} / 5">
                                        <span class="mastery-dot ${word.proficiency >= 1 ? 'is-filled' : ''}"></span>
                                        <span class="mastery-dot ${word.proficiency >= 2 ? 'is-filled' : ''}"></span>
                                        <span class="mastery-dot ${word.proficiency >= 3 ? 'is-filled' : ''}"></span>
                                        <span class="mastery-dot ${word.proficiency >= 4 ? 'is-filled' : ''}"></span>
                                        <span class="mastery-dot ${word.proficiency >= 5 ? 'is-filled' : ''}"></span>
                                    </span>
                                </div>
                                <div class="word-actions">
                                    <form action="<c:url value='/words/relearn'/>" method="post">
                                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="wordId" value="${word.wordId}">
                                        <button type="submit" class="compact-button">重新学习</button>
                                    </form>
                                    <form action="<c:url value='/words/delete'/>" method="post">
                                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="wordId" value="${word.wordId}">
                                        <button type="submit" class="compact-button compact-button--danger">删除</button>
                                    </form>
                                </div>
                            </article>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </section>
</main>

<nav class="mobile-nav" aria-label="主要导航">
    <a href="<c:url value='/learning'/>"><span class="nav-icon" aria-hidden="true">▶</span><span>学习</span></a>
    <a href="<c:url value='/review'/>"><span class="nav-icon" aria-hidden="true">↻</span><span>复习</span></a>
    <a class="is-active" href="<c:url value='/words'/>"><span class="nav-icon" aria-hidden="true">Aa</span><span>词库</span></a>
    <a href="<c:url value='/ranking'/>"><span class="nav-icon" aria-hidden="true">★</span><span>排行</span></a>
</nav>
<script src="<c:url value='/static/js/ui.js'/>?v=2"></script>
</body>
</html>
