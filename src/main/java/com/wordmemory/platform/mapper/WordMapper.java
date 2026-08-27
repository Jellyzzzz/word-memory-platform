package com.wordmemory.platform.mapper;

import com.wordmemory.platform.entity.Word;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * words 表数据访问接口。
 */
public interface WordMapper {

    /** 查询全部内置单词，用于注册时初始化学习进度。 */
    List<Word> findAllBuiltin();

    /** 按主键查询。 */
    Word findById(Integer wordId);

    /** 插入单词，回填自增 wordId。 */
    int insertWord(Word word);

    /** 查询某用户的全部自定义单词。 */
    List<Word> listCustomWords(Integer ownerId);

    /** 删除自定义单词，校验归属与来源，返回影响行数。 */
    int deleteCustomWord(@Param("wordId") Integer wordId, @Param("ownerId") Integer ownerId);

    /** 随机取若干非当前单词，用于生成选择题干扰项。 */
    List<Word> findRandomWords(@Param("excludeWordId") Integer excludeWordId, @Param("limit") int limit);
}
