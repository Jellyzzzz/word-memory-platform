package com.wordmemory.platform.service;

import com.wordmemory.platform.dto.AnswerResult;
import com.wordmemory.platform.entity.UserWordProgress;
import com.wordmemory.platform.entity.Word;
import com.wordmemory.platform.mapper.UserMapper;
import com.wordmemory.platform.mapper.UserWordProgressMapper;
import com.wordmemory.platform.mapper.WordMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class LearningServiceTest {

    @Mock
    private WordMapper wordMapper;

    @Mock
    private UserWordProgressMapper progressMapper;

    @Mock
    private UserMapper userMapper;

    @InjectMocks
    private LearningService learningService;

    @Test
    void rejectsUnknownModeBeforeQuerying() {
        assertThrows(IllegalArgumentException.class,
                () -> learningService.generateQuestion(1, "tampered"));
        verifyNoInteractions(progressMapper);
    }

    @Test
    void rejectsWordThatIsNotAccessibleToCurrentUser() {
        UserWordProgress progress = progress(1, 99, 0, "learning");
        when(progressMapper.findByUserAndWordForUpdate(1, 99)).thenReturn(progress);
        when(wordMapper.findAccessibleById(1, 99)).thenReturn(null);

        assertThrows(IllegalArgumentException.class,
                () -> learningService.judgeAnswer(1, "learning", "blank", 99, "secret"));
        verify(progressMapper, never()).updateProgress(any());
        verify(userMapper, never()).addScore(anyInt(), anyInt());
    }

    @Test
    void rejectsStaleQuestionWhenStatusNoLongerMatchesMode() {
        when(progressMapper.findByUserAndWordForUpdate(1, 7))
                .thenReturn(progress(1, 7, 3, "mastered"));

        assertThrows(IllegalArgumentException.class,
                () -> learningService.judgeAnswer(1, "learning", "blank", 7, "apple"));
        verifyNoInteractions(wordMapper);
    }

    @Test
    void choiceQuestionAcceptsOnlyChineseAnswer() {
        UserWordProgress progress = progress(1, 7, 0, "learning");
        stubAnswer(progress, word(7, "apple", "苹果"));

        AnswerResult result = learningService.judgeAnswer(1, "learning", "choice", 7, "apple");

        assertFalse(result.isCorrect());
        assertEquals(0, progress.getProficiency());
        verify(userMapper, never()).addScore(anyInt(), anyInt());
    }

    @Test
    void learningAnswerCrossesMasteredThresholdAndAddsScore() {
        UserWordProgress progress = progress(1, 7, 2, "learning");
        stubAnswer(progress, word(7, "apple", "苹果"));
        when(userMapper.addScore(1, 1)).thenReturn(1);

        AnswerResult result = learningService.judgeAnswer(1, "learning", "blank", 7, " APPLE ");

        assertTrue(result.isCorrect());
        assertEquals(3, progress.getProficiency());
        assertEquals("mastered", progress.getStatus());
        verify(userMapper).addScore(1, 1);
    }

    @Test
    void reviewMistakeReturnsWordToLearningPool() {
        UserWordProgress progress = progress(1, 7, 3, "mastered");
        stubAnswer(progress, word(7, "apple", "苹果"));

        AnswerResult result = learningService.judgeAnswer(1, "review", "choice", 7, "梨");

        assertFalse(result.isCorrect());
        assertEquals(2, progress.getProficiency());
        assertEquals("learning", progress.getStatus());
    }

    @Test
    void proficiencyNeverExceedsFive() {
        UserWordProgress progress = progress(1, 7, 5, "mastered");
        stubAnswer(progress, word(7, "apple", "苹果"));
        when(userMapper.addScore(1, 1)).thenReturn(1);

        learningService.judgeAnswer(1, "review", "choice", 7, "苹果");

        assertEquals(5, progress.getProficiency());
    }

    @Test
    void markUnfamiliarDoesNotCreateProgressForArbitraryWord() {
        when(progressMapper.findByUserAndWordForUpdate(1, 99)).thenReturn(null);
        when(wordMapper.findAccessibleById(1, 99)).thenReturn(null);

        assertThrows(IllegalArgumentException.class, () -> learningService.markUnfamiliar(1, 99));
        verify(progressMapper, never()).insertProgress(any());
    }

    private void stubAnswer(UserWordProgress progress, Word word) {
        when(progressMapper.findByUserAndWordForUpdate(progress.getUserId(), progress.getWordId()))
                .thenReturn(progress);
        when(wordMapper.findAccessibleById(progress.getUserId(), progress.getWordId())).thenReturn(word);
        when(progressMapper.updateProgress(progress)).thenReturn(1);
    }

    private UserWordProgress progress(int userId, int wordId, int proficiency, String status) {
        UserWordProgress progress = new UserWordProgress();
        progress.setUserId(userId);
        progress.setWordId(wordId);
        progress.setProficiency(proficiency);
        progress.setStatus(status);
        return progress;
    }

    private Word word(int wordId, String english, String chinese) {
        Word word = new Word();
        word.setWordId(wordId);
        word.setEnglish(english);
        word.setChinese(chinese);
        word.setSource("builtin");
        return word;
    }
}
