package com.wordmemory.platform.service;

import com.wordmemory.platform.dto.AnswerResult;
import com.wordmemory.platform.dto.ImportResult;
import com.wordmemory.platform.dto.Question;
import com.wordmemory.platform.entity.UserWordProgress;
import com.wordmemory.platform.entity.Word;
import com.wordmemory.platform.mapper.UserMapper;
import com.wordmemory.platform.mapper.UserWordProgressMapper;
import com.wordmemory.platform.mapper.WordMapper;
import com.wordmemory.platform.util.CsvUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

/**
 * 单词学习模块业务逻辑：学习/复习出题与判题、熟练度与积分更新、自定义单词管理。
 */
@Service
public class LearningService {

    public static final String MODE_LEARNING = "learning";
    public static final String MODE_REVIEW = "review";

    private static final String STATUS_LEARNING = "learning";
    private static final String STATUS_MASTERED = "mastered";
    private static final int MASTERED_THRESHOLD = 3;
    private static final int MAX_PROFICIENCY = 5;
    private static final int DISTRACTOR_COUNT = 3;

    @Autowired
    private WordMapper wordMapper;

    @Autowired
    private UserWordProgressMapper progressMapper;

    @Autowired
    private UserMapper userMapper;

    public List<Word> getLearningWords(Integer userId) {
        return progressMapper.findWordsByUserAndStatus(userId, STATUS_LEARNING);
    }

    public List<Word> getReviewWords(Integer userId) {
        return progressMapper.findWordsByUserAndStatus(userId, STATUS_MASTERED);
    }

    /** 从指定模式的单词池随机取词，生成选择题或填空题；池为空返回 null。 */
    public Question generateQuestion(Integer userId, String mode) {
        List<Word> pool = MODE_LEARNING.equals(mode) ? getLearningWords(userId) : getReviewWords(userId);
        if (pool.isEmpty()) {
            return null;
        }
        Word target = pool.get(ThreadLocalRandom.current().nextInt(pool.size()));

        Question question = new Question();
        question.setWordId(target.getWordId());
        question.setEnglish(target.getEnglish());
        question.setChinese(target.getChinese());
        question.setPartOfSpeech(target.getPartOfSpeech());

        if (ThreadLocalRandom.current().nextBoolean()) {
            question.setType("choice");
            List<Word> distractors = wordMapper.findRandomWords(target.getWordId(), DISTRACTOR_COUNT);
            List<String> options = new ArrayList<>();
            for (Word d : distractors) {
                options.add(d.getChinese());
            }
            options.add(target.getChinese());
            Collections.shuffle(options);
            question.setOptions(options);
        } else {
            question.setType("blank");
        }
        return question;
    }

    /** 判题：更新熟练度与积分，返回判题结果。 */
    @Transactional
    public AnswerResult judgeAnswer(Integer userId, String mode, int wordId, String answer) {
        Word word = wordMapper.findById(wordId);
        if (word == null) {
            throw new IllegalArgumentException("题目不存在");
        }
        boolean correct = isCorrect(word, answer);
        updateProgress(userId, wordId, correct, mode);
        if (correct) {
            userMapper.addScore(userId, 1);
        }

        UserWordProgress updated = progressMapper.findByUserAndWord(userId, wordId);
        AnswerResult result = new AnswerResult();
        result.setCorrect(correct);
        result.setCorrectAnswer(word.getEnglish() + "（" + word.getChinese() + "）");
        result.setProficiency(updated.getProficiency());
        result.setStatus(updated.getStatus());
        return result;
    }

    /** 按熟练度规则更新进度：学习答对 +1、复习答对 +1/答错 -1，熟练度 >=3 转 mastered。 */
    public void updateProgress(Integer userId, int wordId, boolean correct, String mode) {
        UserWordProgress progress = progressMapper.findByUserAndWord(userId, wordId);
        if (progress == null) {
            progress = new UserWordProgress();
            progress.setUserId(userId);
            progress.setWordId(wordId);
            progress.setProficiency(0);
            progress.setStatus(STATUS_LEARNING);
            progressMapper.insertProgress(progress);
        }

        int proficiency = progress.getProficiency();
        if (MODE_LEARNING.equals(mode)) {
            if (correct) {
                proficiency = Math.min(proficiency + 1, MAX_PROFICIENCY);
            }
        } else {
            proficiency = correct
                    ? Math.min(proficiency + 1, MAX_PROFICIENCY)
                    : Math.max(proficiency - 1, 0);
        }
        String status = proficiency >= MASTERED_THRESHOLD ? STATUS_MASTERED : STATUS_LEARNING;
        progress.setProficiency(proficiency);
        progress.setStatus(status);
        progressMapper.updateProgress(progress);
    }

    /** 标记为不熟练：熟练度归零、回到 learning 池。 */
    @Transactional
    public void markUnfamiliar(Integer userId, int wordId) {
        UserWordProgress progress = progressMapper.findByUserAndWord(userId, wordId);
        if (progress == null) {
            progress = new UserWordProgress();
            progress.setUserId(userId);
            progress.setWordId(wordId);
            progress.setProficiency(0);
            progress.setStatus(STATUS_LEARNING);
            progressMapper.insertProgress(progress);
            return;
        }
        progress.setProficiency(0);
        progress.setStatus(STATUS_LEARNING);
        progressMapper.updateProgress(progress);
    }

    public List<Word> listCustomWords(Integer userId) {
        return wordMapper.listCustomWords(userId);
    }

    /** 导入 CSV：逐行解析，成功写入自定义单词及其进度，返回成功/失败条数。 */
    @Transactional
    public ImportResult importWords(InputStream in, Integer userId) {
        int success = 0;
        int failed = 0;
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                Word word = CsvUtil.parseLine(line);
                if (word == null) {
                    failed++;
                    continue;
                }
                word.setSource("custom");
                word.setOwnerId(userId);
                wordMapper.insertWord(word);

                UserWordProgress progress = new UserWordProgress();
                progress.setUserId(userId);
                progress.setWordId(word.getWordId());
                progress.setProficiency(0);
                progress.setStatus(STATUS_LEARNING);
                progressMapper.insertProgress(progress);
                success++;
            }
        } catch (IOException e) {
            throw new IllegalArgumentException("文件读取失败", e);
        }
        return new ImportResult(success, failed);
    }

    /** 删除自定义单词，仅限本人；删除失败抛出异常。 */
    @Transactional
    public void deleteCustomWord(Integer userId, int wordId) {
        int affected = wordMapper.deleteCustomWord(wordId, userId);
        if (affected == 0) {
            throw new IllegalArgumentException("只能删除自己的自定义单词");
        }
    }

    private boolean isCorrect(Word word, String answer) {
        if (answer == null) {
            return false;
        }
        String a = answer.trim();
        return a.equalsIgnoreCase(word.getEnglish()) || a.equals(word.getChinese());
    }
}
