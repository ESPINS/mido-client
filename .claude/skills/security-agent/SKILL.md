---
name: security-agent
description: Security review for mido-client (Spring Boot RestClient library). Final pipeline stage — checks credential safety in logs/interceptors, YAML property handling, URL validation, and downstream-trust assumptions.
disable-model-invocation: true
---

# Credential & Sensitive Data Protection

- **Logs must never contain raw credentials**: `Authorization` headers (Bearer / Basic), API key
  headers, query-string tokens, refresh tokens — mask or omit in `MidoLoggingInterceptor` and any
  request/response body logging path
- Verify all `LogLevel` modes (`off` / `console` / `file` / `all`) apply the same masking — file
  logs are especially prone to credential leaks
- **No hardcoded credentials** anywhere in source, tests, or `application*.yml` defaults
  → real credentials live only in user-supplied YAML / environment variables
- README, USAGE_EXAMPLES, and example YAML must use obvious placeholders (`YOUR_TOKEN`,
  `${SOME_TOKEN_ENV}`), never realistic-looking sample tokens

# Input Validation (YAML Properties Boundary)

- Apply `@Valid`, `@NotNull`, `@NotBlank`, `@URL` on `MidoClientProperties` fields where appropriate
- Validate URL hosts/schemes before building `RestClient` — reject blank or malformed URLs at
  startup, not at first request
- Reject channel configs that combine incompatible auth modes (e.g. Bearer + Basic on same endpoint)
- Channel names from YAML are used as map keys / MDC values — reject names containing control chars
  or newlines (log injection vector)

# HTTP Client Security

- Default to HTTPS for any auth-bearing endpoint; warn (or fail) if Bearer/Basic/API Key is
  configured over plain HTTP
- TLS verification must remain enabled — never expose a "skip-ssl" toggle without a loud warning
- Interceptors must not mutate or leak credentials across channels (per-channel isolation)
- No stack traces or internal class names in exceptions thrown to consumers → use a stable
  `MidoClientException`-style surface

# Library Trust Boundary

- This library runs **inside** the consumer's JVM — treat YAML properties as trusted input from the
  app owner, but treat upstream HTTP responses as untrusted
- Never `eval`/reflect on response bodies; deserialize with Jackson + typed targets only
- `ChannelContext` / MDC must be cleared on completion (try/finally) — stale MDC across threads is
  both a data-leak and a debugging hazard

# Result Report

- On vulnerability found: stop immediately and report severity, location, and improvement guide
- On no issues: report "Security review complete" and end pipeline