package com.wordmemory.platform.controller;

import com.wordmemory.platform.entity.User;
import com.wordmemory.platform.service.RankingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
import java.util.List;

/**
 * 排行榜模块控制器：查看排行榜、点赞。
 */
@Controller
public class RankingController {

    @Autowired
    private RankingService rankingService;

    @GetMapping("/ranking")
    public String ranking(HttpSession session, Model model) {
        Integer userId = (Integer) session.getAttribute("userId");
        List<User> ranking = rankingService.getRanking();
        List<Integer> likedUserIds = rankingService.getLikedUserIds(userId);
        model.addAttribute("ranking", ranking);
        model.addAttribute("likedUserIds", likedUserIds);
        model.addAttribute("currentUserId", userId);
        return "ranking";
    }

    @PostMapping("/ranking/like")
    public String like(@RequestParam("toUserId") int toUserId, HttpSession session,
                       RedirectAttributes redirectAttributes) {
        Integer userId = (Integer) session.getAttribute("userId");
        try {
            rankingService.like(userId, toUserId);
            redirectAttributes.addFlashAttribute("message", "点赞成功");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/ranking";
    }
}
