package com.fairpay.util;

import javax.crypto.KeyGenerator;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

public class JwtSecretGenerator {
    
    public static void main(String[] args) {
        try {
            KeyGenerator keyGen = KeyGenerator.getInstance("HmacSHA256");
            keyGen.init(256); // Chave de 256 bits
            byte[] secretKey = keyGen.generateKey().getEncoded();
            String base64Secret = Base64.getEncoder().encodeToString(secretKey);
            
            System.out.println("Adicione esta chave ao seu application.properties:");
            System.out.println("jwt.secret=" + base64Secret);
            
        } catch (NoSuchAlgorithmException e) {
            System.err.println("Erro ao gerar a chave: " + e.getMessage());
        }
    }
}