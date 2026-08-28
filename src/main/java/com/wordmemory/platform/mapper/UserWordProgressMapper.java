package com.wordmemory.platform.mapper;

import com.wordmemory.platform.entity.UserWordProgress;
import com.wordmemory.platform.entity.Word;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * user_word_progress 表数据访问接口。
 */
public interface UserWordProgressMapper {

    /** 插入一条进度记录。 */
    int insertProgress(UserWordProgress progress);

    /** 查询某用户对某单词的进度。 */
    UserWordProgress findByUserAndWord(@Param("userId") Integer userId, @Param("wordId") Integer wordId);

    /** 查询并锁定进度记录，供答题和重置熟练度事务使用。 */
    UserWordProgress findByUserAndWordForUpdate(@Param("userId") Integer userId,
                                                @Param("wordId") Integer wordId);

    /** 查询某用户某状态（learning/mastered）下的单词，通过 JOIN words 返回 Word。 */
    List<Word> findWordsByUserAndStatus(@Param("userId") Integer userId, @Param("status") String status);

    /** 更新熟练度与状态（按 user_id + word_id 定位）。 */
    int updateProgress(UserWordProgress progress);
}
