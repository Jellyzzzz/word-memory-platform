package com.wordmemory.platform.mapper;

import com.wordmemory.platform.dto.WordProgress;
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

    /** 查询当前用户可访问的单词：内置单词或本人自定义单词。 */
    Word findAccessibleById(@Param("userId") Integer userId, @Param("wordId") Integer wordId);

    /** 插入单词，回填自增 wordId。 */
    int insertWord(Word word);

    /** 查询某用户的全部自定义单词。 */
    List<Word> listCustomWords(Integer ownerId);

    /** 删除自定义单词，校验归属与来源，返回影响行数。 */
    int deleteCustomWord(@Param("wordId") Integer wordId, @Param("ownerId") Integer ownerId);

    /** 随机取若干非当前单词，用于生成选择题干扰项。 */
    List<Word> findRandomWords(@Param("excludeWordId") Integer excludeWordId, @Param("limit") int limit);

    /** 查询某用户全部内置单词及其熟练度。 */
    List<WordProgress> listBuiltinWithProgress(@Param("userId") Integer userId);

    /** 查询某用户自定义单词及其熟练度。 */
    List<WordProgress> listCustomWithProgress(@Param("userId") Integer userId);
}
