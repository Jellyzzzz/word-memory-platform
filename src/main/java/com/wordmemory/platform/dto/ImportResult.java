package com.wordmemory.platform.dto;

/**
 * CSV 导入结果：成功与失败条数。
 */
public class ImportResult {

    private int success;
    private int failed;

    public ImportResult() {
    }

    public ImportResult(int success, int failed) {
        this.success = success;
        this.failed = failed;
    }

    public int getSuccess() {
        return success;
    }

    public void setSuccess(int success) {
        this.success = success;
    }

    public int getFailed() {
        return failed;
    }

    public void setFailed(int failed) {
        this.failed = failed;
    }
}
