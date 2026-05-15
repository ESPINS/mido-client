---
name: test-agent
description: Write and run tests for mido-client (Spring Boot RestClient library). Use after development stage to write JUnit tests, verify Auto-Configuration and HTTP flows, and achieve coverage targets.
disable-model-invocation: true
---

# Core Principles

- Library testing focus: Auto-Configuration wiring, conditional bean activation, property binding,
  end-to-end HTTP request/response flow
- Use `ApplicationContextRunner` for Auto-Configuration tests (lightweight, no full Spring Boot context)
- Use `MockRestServiceServer` or WireMock to verify outbound HTTP behavior — do **not** call real
  external APIs in tests
- Given-When-Then comment structure required (readability)
- Class names: follow `*Test` convention / Method names: describe the scenario
  (e.g. `shouldCreateRestClientPerChannel`, `shouldThrowWhenChannelNotConfigured`,
  `shouldMaskAuthHeaderInLogs`)
- No empty test methods — real verification logic required, assert message required (clarify failure cause)

# Annotation Patterns

- Auto-Configuration test:
  `ApplicationContextRunner` with `.withConfiguration(AutoConfigurations.of(MidoClientAutoConfiguration.class))`
  and `.withPropertyValues("mido-client.enabled=true", ...)`
- Unit test (Factory / Interceptor / ChannelContext):
  Plain JUnit 5 + Mockito where genuinely needed
- Integration test (RestClient behavior):
  `@SpringBootTest` + `MockRestServiceServer` (bind to the `RestClient.Builder` under test)
- Property-binding test:
  `@EnableConfigurationProperties(MidoClientProperties.class)` + `@TestPropertySource`

# Verification Standards

- Prefer specific `assertThat()` assertions (hasSize, isEqualTo, isNotNull, etc.)
- Verify auth header / interceptor behavior at the HTTP layer, not via field reflection
- Verify per-channel isolation: two channels with different configs must produce independent clients
- Coverage targets:
  - Auto-Configuration (`MidoClientAutoConfiguration`) 90%+
  - Factory (`MidoClientFactory`) 85%+
  - Interceptor / ChannelContext 80%+
  - Constants/enums excluded from targets

# Data Strategy

- No database in this project — skip `@Sql` / `@Transactional` patterns
- Test YAML fixtures live under `src/test/resources` (e.g. `application-test.yml`) and are loaded via
  `@TestPropertySource` or `.withPropertyValues(...)` per test
- Each test must be independent and runnable in CI without network access