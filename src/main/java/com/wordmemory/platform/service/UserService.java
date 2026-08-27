package com.wordmemory.platform.service;

import com.wordmemory.platform.entity.User;
import com.wordmemory.platform.entity.UserWordProgress;
import com.wordmemory.platform.entity.Word;
import com.wordmemory.platform.mapper.UserMapper;
import com.wordmemory.platform.mapper.UserWordProgressMapper;
import com.wordmemory.platform.mapper.WordMapper;
import com.wordmemory.platform.util.PasswordUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 用户模块业务逻辑：注册、登录、用户名查重。
 */
@Service
public class UserService {

    private static final String STATUS_LEARNING = "learning";

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private WordMapper wordMapper;

    @Autowired
    private UserWordProgressMapper progressMapper;

    /** 注册：校验用户名与密码，加盐哈希入库，并为全部内置单词初始化学习进度。 */
    @Transactional
    public User register(String username, String password) {
        String name = username == null ? "" : username.trim();
        if (name.isEmpty()) {
            throw new IllegalArgumentException("用户名不能为空");
        }
        if (password == null || password.length() < 6) {
            throw new IllegalArgumentException("密码长度不能少于 6 位");
        }
        if (!checkUsernameUnique(name)) {
            throw new IllegalArgumentException("用户名已存在");
        }

        String salt = PasswordUtil.generateSalt();
        User user = new User();
        user.setUsername(name);
        user.setSalt(salt);
        user.setPasswordHash(PasswordUtil.hash(salt, password));
        userMapper.insertUser(user);

        initProgress(user.getUserId());
        return user;
    }

    /** 登录：校验用户名与密码哈希，失败返回 null。 */
    public User login(String username, String password) {
        if (username == null || password == null) {
            return null;
        }
        User user = userMapper.findByUsername(username.trim());
        if (user == null) {
            return null;
        }
        String hash = PasswordUtil.hash(user.getSalt(), password);
        return hash.equals(user.getPasswordHash()) ? user : null;
    }

    /** 用户名是否未被占用。 */
    public boolean checkUsernameUnique(String username) {
        return userMapper.findByUsername(username) == null;
    }

    private void initProgress(Integer userId) {
        List<Word> builtinWords = wordMapper.findAllBuiltin();
        for (Word word : builtinWords) {
            UserWordProgress progress = new UserWordProgress();
            progress.setUserId(userId);
            progress.setWordId(word.getWordId());
            progress.setProficiency(0);
            progress.setStatus(STATUS_LEARNING);
            progressMapper.insertProgress(progress);
        }
    }
}
