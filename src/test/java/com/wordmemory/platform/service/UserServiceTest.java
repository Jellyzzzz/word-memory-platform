package com.wordmemory.platform.service;

import com.wordmemory.platform.entity.User;
import com.wordmemory.platform.mapper.UserMapper;
import com.wordmemory.platform.mapper.UserWordProgressMapper;
import com.wordmemory.platform.mapper.WordMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DuplicateKeyException;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserMapper userMapper;

    @Mock
    private WordMapper wordMapper;

    @Mock
    private UserWordProgressMapper progressMapper;

    @InjectMocks
    private UserService userService;

    @Test
    void rejectsUsernameLongerThanDatabaseColumn() {
        IllegalArgumentException error = assertThrows(IllegalArgumentException.class,
                () -> userService.register("x".repeat(51), "secret1"));
        assertEquals("用户名不能超过 50 个字符", error.getMessage());
        verifyNoInteractions(userMapper);
    }

    @Test
    void convertsConcurrentUniqueConstraintFailureToBusinessError() {
        when(userMapper.findByUsername("alice")).thenReturn(null);
        when(userMapper.insertUser(any(User.class))).thenThrow(new DuplicateKeyException("duplicate"));

        IllegalArgumentException error = assertThrows(IllegalArgumentException.class,
                () -> userService.register("alice", "secret1"));
        assertEquals("用户名已存在", error.getMessage());
        verifyNoInteractions(wordMapper, progressMapper);
    }
}
