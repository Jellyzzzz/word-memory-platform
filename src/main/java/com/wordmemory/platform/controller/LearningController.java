package com.wordmemory.platform.controller;

import com.wordmemory.platform.dto.AnswerRequest;
import com.wordmemory.platform.dto.AnswerResult;
import com.wordmemory.platform.dto.ImportResult;
import com.wordmemory.platform.dto.Question;
import com.wordmemory.platform.dto.QuestionAttempt;
import com.wordmemory.platform.service.LearningService;
import com.wordmemory.platform.util.QuestionAttemptStore;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;

/**
 * 单词学习模块控制器：学习/复习、自定义单词导入与删除。
 */
@Controller
public class LearningController {

    private static final Log LOGGER = LogFactory.getLog(LearningController.class);

    @Autowired
    private LearningService learningService;

    /** 首页：各功能模式入口。 */
    @GetMapping("/home")
    public String home() {
        return "home";
    }

    /** 词库管理页：展示内置词库与本人自定义单词。 */
    @GetMapping("/words")
    public String library(HttpSession session, Model model) {
        Integer userId = (Integer) session.getAttribute("userId");
        model.addAttribute("builtinWords", learningService.listBuiltinWordsWithProgress(userId));
        model.addAttribute("customWords", learningService.listCustomWordsWithProgress(userId));
        return "library";
    }

    @GetMapping("/learning")
    public String learning(HttpSession session, Model model) {
        Integer userId = (Integer) session.getAttribute("userId");
        Question question = learningService.generateQuestion(userId, LearningService.MODE_LEARNING);
        model.addAttribute("question", question);
        if (question != null) {
            QuestionAttempt attempt = QuestionAttemptStore.issue(
                    session, question, LearningService.MODE_LEARNING);
            model.addAttribute("questionToken", attempt.getToken());
        }
        return "learning";
    }

    @GetMapping("/review")
    public String review(HttpSession session, Model model) {
        Integer userId = (Integer) session.getAttribute("userId");
        Question question = learningService.generateQuestion(userId, LearningService.MODE_REVIEW);
        model.addAttribute("question", question);
        if (question != null) {
            QuestionAttempt attempt = QuestionAttemptStore.issue(
                    session, question, LearningService.MODE_REVIEW);
            model.addAttribute("questionToken", attempt.getToken());
        }
        return "review";
    }

    @PostMapping("/learning/answer")
    public String answer(@ModelAttribute AnswerRequest request,
                         @RequestParam("questionToken") String questionToken,
                         HttpSession session, Model model, RedirectAttributes redirectAttributes) {
        Integer userId = (Integer) session.getAttribute("userId");
        QuestionAttempt attempt = QuestionAttemptStore.consume(session, questionToken);
        if (attempt == null) {
            redirectAttributes.addFlashAttribute("error", "题目已失效或已提交，请重新获取题目");
            return "redirect:/home";
        }

        String view = LearningService.MODE_REVIEW.equals(attempt.getMode()) ? "review" : "learning";
        try {
            AnswerResult result = learningService.judgeAnswer(
                    userId,
                    attempt.getMode(),
                    attempt.getQuestionType(),
                    attempt.getWordId(),
                    request.getAnswer()
            );
            model.addAttribute("question",
                    learningService.getQuestionByWordId(userId, attempt.getWordId()));
            model.addAttribute("result", result);
            return view;
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/" + view;
        }
    }

    @PostMapping("/learning/mark-unfamiliar")
    public String markUnfamiliar(@RequestParam("questionToken") String questionToken, HttpSession session,
                                 RedirectAttributes redirectAttributes) {
        Integer userId = (Integer) session.getAttribute("userId");
        QuestionAttempt attempt = QuestionAttemptStore.consume(session, questionToken);
        if (attempt == null || !LearningService.MODE_REVIEW.equals(attempt.getMode())) {
            redirectAttributes.addFlashAttribute("error", "题目已失效，请重新获取题目");
            return "redirect:/review";
        }
        try {
            learningService.markUnfamiliar(userId, attempt.getWordId());
            redirectAttributes.addFlashAttribute("message", "已标记为不熟练");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/review";
    }

    /** 重新学习：将单词熟练度清零，回到学习池。 */
    @PostMapping("/words/relearn")
    public String relearn(@RequestParam("wordId") int wordId, HttpSession session,
                          RedirectAttributes redirectAttributes) {
        Integer userId = (Integer) session.getAttribute("userId");
        try {
            learningService.markUnfamiliar(userId, wordId);
            redirectAttributes.addFlashAttribute("message", "已重新学习");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/words";
    }

    @PostMapping("/words/import")
    public String importWords(@RequestParam("file") MultipartFile file, HttpSession session,
                              RedirectAttributes redirectAttributes) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (file == null || file.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "请选择要导入的 CSV 文件");
            return "redirect:/words";
        }
        try {
            ImportResult result = learningService.importWords(file.getInputStream(), userId);
            redirectAttributes.addFlashAttribute("importResult", result);
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        } catch (Exception e) {
            LOGGER.error("CSV import failed for user " + userId, e);
            redirectAttributes.addFlashAttribute("error", "导入失败，请检查文件格式后重试");
        }
        return "redirect:/words";
    }

    @PostMapping("/words/delete")
    public String deleteWord(@RequestParam("wordId") int wordId, HttpSession session,
                             RedirectAttributes redirectAttributes) {
        Integer userId = (Integer) session.getAttribute("userId");
        try {
            learningService.deleteCustomWord(userId, wordId);
            redirectAttributes.addFlashAttribute("message", "删除成功");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/words";
    }
}
