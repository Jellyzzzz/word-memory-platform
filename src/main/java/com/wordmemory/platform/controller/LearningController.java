package com.wordmemory.platform.controller;

import com.wordmemory.platform.dto.AnswerRequest;
import com.wordmemory.platform.dto.AnswerResult;
import com.wordmemory.platform.dto.ImportResult;
import com.wordmemory.platform.dto.Question;
import com.wordmemory.platform.service.LearningService;
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
        model.addAttribute("builtinWords", learningService.listBuiltinWords());
        model.addAttribute("customWords", learningService.listCustomWords(userId));
        return "library";
    }

    @GetMapping("/learning")
    public String learning(HttpSession session, Model model) {
        Integer userId = (Integer) session.getAttribute("userId");
        Question question = learningService.generateQuestion(userId, LearningService.MODE_LEARNING);
        model.addAttribute("question", question);
        model.addAttribute("mode", "learning");
        return "learning";
    }

    @GetMapping("/review")
    public String review(HttpSession session, Model model) {
        Integer userId = (Integer) session.getAttribute("userId");
        Question question = learningService.generateQuestion(userId, LearningService.MODE_REVIEW);
        model.addAttribute("question", question);
        model.addAttribute("mode", "review");
        return "review";
    }

    @PostMapping("/learning/answer")
    public String answer(@ModelAttribute AnswerRequest request, @RequestParam("mode") String mode,
                         HttpSession session, RedirectAttributes redirectAttributes) {
        Integer userId = (Integer) session.getAttribute("userId");
        try {
            AnswerResult result = learningService.judgeAnswer(userId, mode, request.getWordId(), request.getAnswer());
            redirectAttributes.addFlashAttribute("result", result);
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/" + (LearningService.MODE_REVIEW.equals(mode) ? "review" : "learning");
    }

    @PostMapping("/learning/mark-unfamiliar")
    public String markUnfamiliar(@RequestParam("wordId") int wordId, HttpSession session,
                                 RedirectAttributes redirectAttributes) {
        Integer userId = (Integer) session.getAttribute("userId");
        learningService.markUnfamiliar(userId, wordId);
        redirectAttributes.addFlashAttribute("message", "已标记为不熟练");
        return "redirect:/review";
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
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "导入失败：" + e.getMessage());
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
