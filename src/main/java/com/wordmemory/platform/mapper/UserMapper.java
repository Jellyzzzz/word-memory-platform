package com.wordmemory.platform.mapper;

import com.wordmemory.platform.entity.User;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * users 表数据访问接口。
 */
public interface UserMapper {

    /** 插入用户，回填自增 userId。 */
    int insertUser(User user);

    /** 按用户名查询，用于登录与注册查重。 */
    User findByUsername(String username);

    /** 按主键查询。 */
    User findById(Integer userId);

    /** 排行榜排序查询：score DESC, total_likes DESC, created_at ASC。 */
    List<User> listRanking();

    /** 获赞数 +1。 */
    int incrTotalLikes(@Param("userId") Integer userId);

    /** 积分累加（答对 +1）。 */
    int addScore(@Param("userId") Integer userId, @Param("delta") int delta);
}
