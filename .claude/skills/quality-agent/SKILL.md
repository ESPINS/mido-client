---
name: quality-agent
description: Verify code quality, readability, and maintainability for mido-client. Use after testing stage to review code smells, naming conventions, and mido-client patterns based on SonarLint/IntelliJ standards.
disable-model-invocation: true
---

# Verification Goal

- Achieve zero SonarLint, IntelliJ, Checkstyle warnings

# SonarLint Verification (via MCP)

- After all file modifications, call `mcp__ide__getDiagnostics` for each modified file
- Fix all Warning/Error level issues before proceeding
- Re-call after fixes to confirm zero diagnostics

# Inspection Items

- Code smells: remove duplicate code, unnecessary intermediate variables, excessive comments
- Single Responsibility Principle (SRP): one method = one role, separate excessive responsibilities
  (e.g. `MidoClientFactory` builds clients, `MidoLoggingInterceptor` logs — never mix)
- Naming: make it clear what it does (`processData` → `buildRestClientForChannel`)
- Null handling: remove unnecessary defensive code → replace with `Optional`, `ObjectUtils.isEmpty()`
- mido-client pattern consistency:
    - `@ConfigurationProperties("mido-client")` on `MidoClientProperties` with nested static classes per
      configuration block — never flat-map dotted property names manually
    - `@AutoConfiguration` + `@ConditionalOnProperty("mido-client.enabled")` gating; conditional beans
      via `@ConditionalOnMissingBean` to remain override-friendly
    - `@UtilityClass` for grouped constants (`EndpointType`, `LogLevel`, `TokenType` style)
    - Lombok annotation order (`@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
      @FieldDefaults`)
    - `ChannelContext` access must go through MDC put/clear pairs — never leave stale MDC entries

# Refactoring Principles

- Improve structure and readability only, no logic changes (behavior-preserving only)
- Code format: unify entire project based on IntelliJ formatter
- Final judgment based on "Can errors be traced without domain knowledge?"
- Public API stability: any rename/signature change in `api/`, `config/`, `constant/`, `context/`
  packages is a breaking change for downstream consumers — flag explicitly

# Result Report

- Present refactoring recommendations summary after inspection
- Proceed to next stage (security) after user approval