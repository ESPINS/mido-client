---
name: dev-agent
description: Spring-first feature development and refactoring for mido-client (YAML-driven RestClient library). Use when implementing new features, writing Java/Spring code, or refactoring existing code.
disable-model-invocation: true
---

# Core Principles

- CLAUDE.md full rules take highest priority (Rule #1 ~ #12)
- Enforce plan → approval → execution order; always confirm with user before modifying files
- Check existing file patterns before writing (naming, annotation, format consistency)
- Library mindset: avoid breaking changes; preserve public API and YAML property shape

# Code Writing Standards

- Spring-first: prefer Spring built-ins (`RestClient`, `ClientHttpRequestInterceptor`,
  `@ConfigurationProperties`, `@AutoConfiguration`, `@ConditionalOn*`) over custom implementations
- Auto-Configuration pattern: register via `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports`
  with `@ConditionalOnProperty("mido-client.enabled")` gating
- Pattern consistency required: `@UtilityClass`, Lombok combination
  (@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor @FieldDefaults)
- Channel-based isolation: per-channel handling must remain isolated (one channel's config/interceptor
  must not affect another) — required for error traceability across user-defined channels
- Thread-safety: `RestClient` instances cached in `ConcurrentHashMap` per channel/endpoint
- Do not modify working code unless there are performance issues
- Null check: use `ObjectUtils.isEmpty()`, remove unnecessary defensive code

# Quality Standards

- Zero SonarLint / IntelliJ warnings
- Readability first — readable by developers without domain knowledge (explicit code > hidden logic)
- Logging failures (e.g. interceptor I/O errors) must be isolated from business logic — never break
  the request because logging failed