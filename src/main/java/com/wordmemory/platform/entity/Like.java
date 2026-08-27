package com.wordmemory.platform.entity;

import java.time.LocalDateTime;

/**
 * 点赞记录实体，对应 likes 表。
 * 同一 from_user_id 对同一 to_user_id 仅一条记录，且不允许自赞。
 */
public class Like {

    private Integer id;
    private Integer fromUserId;
    private Integer toUserId;
    private LocalDateTime createdAt;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getFromUserId() {
        return fromUserId;
    }

    public void setFromUserId(Integer fromUserId) {
        this.fromUserId = fromUserId;
    }

    public Integer getToUserId() {
        return toUserId;
    }

    public void setToUserId(Integer toUserId) {
        this.toUserId = toUserId;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
