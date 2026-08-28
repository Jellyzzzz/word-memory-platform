package com.wordmemory.platform.util;

import java.security.SecureRandom;
import java.util.Base64;

/** 生成只用于服务端会话校验的高熵随机 token。 */
public final class SecureTokenUtil {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final int TOKEN_BYTES = 32;

    private SecureTokenUtil() {
    }

    public static String generateToken() {
        byte[] bytes = new byte[TOKEN_BYTES];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
