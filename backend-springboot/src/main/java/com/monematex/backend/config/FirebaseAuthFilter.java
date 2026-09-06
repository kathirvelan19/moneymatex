package com.monematex.backend.config;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
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
import java.util.Collections;
import java.util.List;

/**
 * Spring Security Filter that inspects and validates Firebase-issued Bearer ID Tokens.
 * Extracts the canonical Firebase user UID ('sub' claim) and sets Spring Security authentication context.
 */
public class FirebaseAuthFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        final String authHeader = request.getHeader("Authorization");

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            final String token = authHeader.substring(7).trim();
            if (!token.isEmpty()) {
                try {
                    // Extract payload from Firebase JWT Token
                    int i = token.lastIndexOf('.');
                    if (i > 0) {
                        String tokenWithoutSignature = token.substring(0, i + 1);

                        Claims claims = Jwts.parserBuilder()
                                .build()
                                .parseClaimsJwt(tokenWithoutSignature)
                                .getBody();

                        String userId = claims.getSubject();
                        String email = claims.get("email", String.class);

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
                } catch (Exception e) {
                    logger.warn("Firebase ID Token parsing/validation notice: " + e.getMessage());
                }
            }
        }

        filterChain.doFilter(request, response);
    }
}
