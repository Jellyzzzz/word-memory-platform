package com.wordmemory.platform.service;

import com.wordmemory.platform.entity.Like;
import com.wordmemory.platform.entity.User;
import com.wordmemory.platform.mapper.LikeMapper;
import com.wordmemory.platform.mapper.UserMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.dao.DataIntegrityViolationException;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class RankingServiceTest {

    @Mock
    private UserMapper userMapper;

    @Mock
    private LikeMapper likeMapper;

    @InjectMocks
    private RankingService rankingService;

    @Test
    void rejectsSelfLike() {
        assertThrows(IllegalArgumentException.class, () -> rankingService.like(1, 1));
        verifyNoInteractions(userMapper, likeMapper);
    }

    @Test
    void rejectsMissingTargetUser() {
        when(userMapper.findById(2)).thenReturn(null);

        assertThrows(IllegalArgumentException.class, () -> rankingService.like(1, 2));
        verify(likeMapper, never()).insertLike(any());
    }

    @Test
    void convertsConcurrentDuplicateLikeToBusinessErrorWithoutIncrementingCounter() {
        when(userMapper.findById(2)).thenReturn(new User());
        when(likeMapper.insertLike(any(Like.class))).thenThrow(new DuplicateKeyException("duplicate"));

        IllegalArgumentException error = assertThrows(IllegalArgumentException.class,
                () -> rankingService.like(1, 2));
        assertEquals("您已经点过赞了", error.getMessage());
        verify(userMapper, never()).incrTotalLikes(anyInt());
    }

    @Test
    void successfulLikeIncrementsCounterExactlyOnce() {
        when(userMapper.findById(2)).thenReturn(new User());
        when(likeMapper.insertLike(any(Like.class))).thenReturn(1);
        when(userMapper.incrTotalLikes(2)).thenReturn(1);

        rankingService.like(1, 2);

        verify(likeMapper).insertLike(any(Like.class));
        verify(userMapper).incrTotalLikes(2);
    }

    @Test
    void convertsForeignKeyRaceToBusinessError() {
        when(userMapper.findById(2)).thenReturn(new User());
        when(likeMapper.insertLike(any(Like.class)))
                .thenThrow(new DataIntegrityViolationException("target deleted"));

        IllegalArgumentException error = assertThrows(IllegalArgumentException.class,
                () -> rankingService.like(1, 2));
        assertEquals("用户状态已变化，请刷新排行榜后重试", error.getMessage());
        verify(userMapper, never()).incrTotalLikes(anyInt());
    }
}
