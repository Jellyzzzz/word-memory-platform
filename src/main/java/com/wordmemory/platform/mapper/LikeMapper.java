package com.wordmemory.platform.mapper;

import com.wordmemory.platform.entity.Like;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * likes 表数据访问接口。
 */
public interface LikeMapper {

    /** 插入点赞记录。 */
    int insertLike(Like like);

    /** 查询是否已点赞，返回 null 表示未点赞。 */
    Like checkLike(@Param("fromUserId") Integer fromUserId, @Param("toUserId") Integer toUserId);

    /** 查询某用户已点赞的目标用户 ID 列表，用于排行榜置灰展示。 */
    List<Integer> findLikedUserIds(Integer fromUserId);
}
