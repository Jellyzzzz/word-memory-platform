<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>复习 - 单词记忆平台</title>
    <link href="<c:url value='/static/css/style.css'/>?v=2" rel="stylesheet">
</head>
<body class="app-body review-theme">
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

<main class="quiz-page">
    <div class="quiz-mode-header">
        <div>
            <p class="mode-kicker mode-kicker--review">Review</p>
            <h1 class="mode-heading">复习模式</h1>
        </div>
        <span class="mode-badge mode-badge--review"><span aria-hidden="true">●</span> 巩固记忆</span>
    </div>
    <div class="lesson-line" aria-hidden="true"><span></span><span></span><span></span><span></span></div>

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

    <c:choose>
        <c:when test="${not empty result}">
            <section class="quiz-card">
                <div class="word-stage">
                    <h2 class="question-word"><c:out value="${question.english}"/></h2>
                    <p class="question-translation"><c:out value="${question.chinese}"/></p>
                    <c:if test="${not empty question.partOfSpeech}">
                        <span class="part-of-speech"><c:out value="${question.partOfSpeech}"/></span>
                    </c:if>
                </div>

                <c:choose>
                    <c:when test="${result.correct}">
                        <div class="feedback-panel feedback-panel--correct" role="status">
                            <div class="feedback-heading">
                                <span class="feedback-icon feedback-icon--review" aria-hidden="true">✓</span>
                                <div>
                                    <h3 class="feedback-title">记得很牢！</h3>
                                    <p class="feedback-answer">熟练度已经更新，继续保持。</p>
                                </div>
                            </div>
                            <div class="mastery-row">
                                <span class="mastery-label">
                                    当前熟练度
                                    <c:if test="${result.status == 'mastered'}"><span class="status-pill">保持掌握</span></c:if>
                                </span>
                                <span class="mastery-meter" aria-label="熟练度 ${result.proficiency} / 5">
                                    <span class="mastery-dot ${result.proficiency >= 1 ? 'is-filled' : ''}"></span>
                                    <span class="mastery-dot ${result.proficiency >= 2 ? 'is-filled' : ''}"></span>
                                    <span class="mastery-dot ${result.proficiency >= 3 ? 'is-filled' : ''}"></span>
                                    <span class="mastery-dot ${result.proficiency >= 4 ? 'is-filled' : ''}"></span>
                                    <span class="mastery-dot ${result.proficiency >= 5 ? 'is-filled' : ''}"></span>
                                </span>
                            </div>
                            <a href="<c:url value='/review'/>" class="game-button game-button--review game-button--wide">继续复习</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="feedback-panel feedback-panel--wrong" role="status">
                            <div class="feedback-heading">
                                <span class="feedback-icon" aria-hidden="true">×</span>
                                <div>
                                    <h3 class="feedback-title">再巩固一下</h3>
                                    <p class="feedback-answer">正确答案：<strong><c:out value="${result.correctAnswer}"/></strong></p>
                                </div>
                            </div>
                            <div class="mastery-row">
                                <span class="mastery-label">
                                    当前熟练度
                                    <c:if test="${result.status == 'learning'}"><span class="status-pill">回到学习</span></c:if>
                                </span>
                                <span class="mastery-meter" aria-label="熟练度 ${result.proficiency} / 5">
                                    <span class="mastery-dot ${result.proficiency >= 1 ? 'is-filled' : ''}"></span>
                                    <span class="mastery-dot ${result.proficiency >= 2 ? 'is-filled' : ''}"></span>
                                    <span class="mastery-dot ${result.proficiency >= 3 ? 'is-filled' : ''}"></span>
                                    <span class="mastery-dot ${result.proficiency >= 4 ? 'is-filled' : ''}"></span>
                                    <span class="mastery-dot ${result.proficiency >= 5 ? 'is-filled' : ''}"></span>
                                </span>
                            </div>
                            <a href="<c:url value='/review'/>" class="game-button game-button--danger game-button--wide">记住了，下一题</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
        </c:when>

        <c:when test="${empty question}">
            <section class="surface-card empty-state">
                <span class="empty-icon" aria-hidden="true">☀</span>
                <h2>暂时没有待复习单词</h2>
                <p>先完成一些学习任务，掌握后的单词会来到这里。</p>
                <a href="<c:url value='/learning'/>" class="game-button game-button--review">去学习</a>
            </section>
        </c:when>

        <c:otherwise>
            <section class="quiz-card">
                <form action="<c:url value='/learning/answer'/>" method="post">
                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="questionToken" value="${questionToken}">

                    <c:choose>
                        <c:when test="${question.type == 'choice'}">
                            <div class="word-stage">
                                <h2 class="question-word"><c:out value="${question.english}"/></h2>
                                <c:if test="${not empty question.partOfSpeech}">
                                    <span class="part-of-speech"><c:out value="${question.partOfSpeech}"/></span>
                                </c:if>
                            </div>
                            <fieldset class="question-fieldset">
                                <legend class="question-prompt">还记得它的中文释义吗？</legend>
                                <div class="option-list">
                                    <c:forEach var="opt" items="${question.options}">
                                        <label class="answer-option">
                                            <input type="radio" name="answer" value="${fn:escapeXml(opt)}" required>
                                            <span class="answer-option__content"><c:out value="${opt}"/></span>
                                        </label>
                                    </c:forEach>
                                </div>
                            </fieldset>
                        </c:when>
                        <c:otherwise>
                            <div class="word-stage">
                                <h2 class="question-word"><c:out value="${question.chinese}"/></h2>
                                <c:if test="${not empty question.partOfSpeech}">
                                    <span class="part-of-speech"><c:out value="${question.partOfSpeech}"/></span>
                                </c:if>
                            </div>
                            <label class="question-prompt" for="review-answer">输入对应的英文单词</label>
                            <input id="review-answer" type="text" name="answer" class="answer-input"
                                   required autocomplete="off" autofocus>
                        </c:otherwise>
                    </c:choose>

                    <button type="submit" class="game-button game-button--review game-button--wide">检查答案</button>
                </form>

                <form action="<c:url value='/learning/mark-unfamiliar'/>" method="post"
                      class="quiz-secondary-action">
                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="questionToken" value="${questionToken}">
                    <button type="submit" class="text-button">我不熟悉这个单词</button>
                </form>
            </section>
        </c:otherwise>
    </c:choose>
</main>

<nav class="mobile-nav" aria-label="主要导航">
    <a href="<c:url value='/learning'/>"><span class="nav-icon" aria-hidden="true">▶</span><span>学习</span></a>
    <a class="is-active" href="<c:url value='/review'/>"><span class="nav-icon" aria-hidden="true">↻</span><span>复习</span></a>
    <a href="<c:url value='/words'/>"><span class="nav-icon" aria-hidden="true">Aa</span><span>词库</span></a>
    <a href="<c:url value='/ranking'/>"><span class="nav-icon" aria-hidden="true">★</span><span>排行</span></a>
</nav>
</body>
</html>
