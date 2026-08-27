package com.wordmemory.platform.service;

import com.wordmemory.platform.entity.Like;
import com.wordmemory.platform.entity.User;
import com.wordmemory.platform.mapper.LikeMapper;
import com.wordmemory.platform.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 排行榜模块业务逻辑：排行榜查询与点赞。
 */
@Service
public class RankingService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private LikeMapper likeMapper;

    /** 排行榜（score DESC, total_likes DESC, created_at ASC）。 */
    public List<User> getRanking() {
        return userMapper.listRanking();
    }

    /** 当前用户已点赞的目标用户 ID 列表，用于页面置灰展示。 */
    public List<Integer> getLikedUserIds(Integer fromUserId) {
        return likeMapper.findLikedUserIds(fromUserId);
    }

    /** 点赞：写入点赞记录并累加目标用户获赞数，事务保证原子性。 */
    @Transactional
    public void like(Integer fromUserId, Integer toUserId) {
        if (fromUserId.equals(toUserId)) {
            throw new IllegalArgumentException("不能给自己点赞");
        }
        if (likeMapper.checkLike(fromUserId, toUserId) != null) {
            throw new IllegalArgumentException("您已经点过赞了");
        }
        Like like = new Like();
        like.setFromUserId(fromUserId);
        like.setToUserId(toUserId);
        likeMapper.insertLike(like);
        userMapper.incrTotalLikes(toUserId);
    }
}
