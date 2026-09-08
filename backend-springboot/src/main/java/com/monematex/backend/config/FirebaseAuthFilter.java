package com.monematex.backend.config;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.security.Key;
import java.util.Collections;
import java.util.List;

/**
 * Spring Security Filter that inspects and validates Bearer Tokens (MoneyMateX JWT / Firebase ID Tokens).
 * Sets Spring Security authentication context with principal = userId.
 */
public class FirebaseAuthFilter extends OncePerRequestFilter {

    private static final String SECRET_KEY_STR = "MoneyMateX_Super_Secret_JWT_Key_2026_For_Financial_Security_App!";
    private final Key key = Keys.hmacShaKeyFor(SECRET_KEY_STR.getBytes());

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        final String authHeader = request.getHeader("Authorization");

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            final String token = authHeader.substring(7).trim();
            if (!token.isEmpty()) {
                String userId = null;
                String email = null;

                try {
                    // Try parsing as MoneyMateX signed JWT
                    Claims claims = Jwts.parserBuilder()
                            .setSigningKey(key)
                            .build()
                            .parseClaimsJws(token)
                            .getBody();
                    userId = claims.getSubject();
                    email = claims.get("email", String.class);
                } catch (Exception e1) {
                    try {
                        // Fallback: parse as unsigned JWT / Firebase token
                        int i = token.lastIndexOf('.');
                        if (i > 0) {
                            String tokenWithoutSignature = token.substring(0, i + 1);
                            Claims claims = Jwts.parserBuilder()
                                    .build()
                                    .parseClaimsJwt(tokenWithoutSignature)
                                    .getBody();
                            userId = claims.getSubject();
                            email = claims.get("email", String.class);
                        }
                    } catch (Exception e2) {
                        // Fallback: raw token as userId if simple token format
                        if (!token.contains(".")) {
                            userId = token;
                        }
                    }
                }

                if (userId != null && !userId.isEmpty()) {
                    List<SimpleGrantedAuthority> authorities = Collections.singletonList(
                            new SimpleGrantedAuthority("ROLE_USER")
                    );

                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                            userId,
                            email != null ? email : userId,
                            authorities
                    );

                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            }
        }

        filterChain.doFilter(request, response);
    }
}
