package org.folio;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Instant;
import java.util.Properties;
import java.util.UUID;

final class KeycloakUpgradeTenantState {

  private static final String TEST_TENANT = "testTenant";
  private static final String TEST_TENANT_ID = "testTenantId";
  private static final String MEMBER_TENANT = "memberTenant";
  private static final String MEMBER_TENANT_ID = "memberTenantId";
  private static final String CONSORTIUM_ID = "consortiumId";
  private static final String CONSORTIA_ADMIN_ID = "consortiaAdminId";
  private static final String MEMBER_ADMIN_ID = "memberAdminId";
  private static final String CONSORTIA_USER_ID = "consortiaUserId";
  private static final String STATE_FILE = "keycloak.upgrade.stateFile";
  private static final Path DEFAULT_STATE_FILE = Path.of("target", "keycloak-upgrade-tenant.properties");
  private static final String[] REQUIRED_STATE_KEYS = {
    TEST_TENANT, TEST_TENANT_ID, MEMBER_TENANT, MEMBER_TENANT_ID, CONSORTIUM_ID,
    CONSORTIA_ADMIN_ID, MEMBER_ADMIN_ID, CONSORTIA_USER_ID
  };

  private KeycloakUpgradeTenantState() {
  }

  static void prepareSeedTenant() {
    var testTenant = System.getProperty(TEST_TENANT);
    var testTenantId = System.getProperty(TEST_TENANT_ID);
    Properties state;

    if (isBlank(testTenant) && isBlank(testTenantId)) {
      state = Files.exists(stateFile()) ? load() : new Properties();
      testTenant = state.getProperty(TEST_TENANT, randomTenantName("kcupgrade"));
      testTenantId = state.getProperty(TEST_TENANT_ID, UUID.randomUUID().toString());
    } else if (isBlank(testTenant) || isBlank(testTenantId)) {
      throw new IllegalStateException("Provide both -DtestTenant and -DtestTenantId, or omit both to auto-generate them");
    } else {
      state = Files.exists(stateFile()) ? load() : new Properties();
    }

    state.setProperty(TEST_TENANT, testTenant);
    state.setProperty(TEST_TENANT_ID, testTenantId);
    addMissingConsortiaState(state);
    setTenantProperties(state);
    save(state);
  }

  static void prepareVerifyTenant() {
    var state = load();
    var testTenant = System.getProperty(TEST_TENANT);
    var testTenantId = System.getProperty(TEST_TENANT_ID);

    if (isBlank(testTenant) != isBlank(testTenantId)) {
      throw new IllegalStateException("Provide both -DtestTenant and -DtestTenantId, or omit both to load them from "
        + stateFile().toAbsolutePath());
    }

    if (!isBlank(testTenant) && !testTenant.equals(state.getProperty(TEST_TENANT))) {
      throw new IllegalStateException("Provided testTenant does not match seed state file: "
        + stateFile().toAbsolutePath());
    }
    if (!isBlank(testTenantId) && !testTenantId.equals(state.getProperty(TEST_TENANT_ID))) {
      throw new IllegalStateException("Provided testTenantId does not match seed state file: "
        + stateFile().toAbsolutePath());
    }

    validateState(state);
    setTenantProperties(state);
  }

  private static void save(Properties properties) {
    var stateFile = stateFile();
    try {
      var parent = stateFile.getParent();
      if (parent != null) {
        Files.createDirectories(parent);
      }

      properties.setProperty("createdAt", Instant.now().toString());

      try (OutputStream outputStream = Files.newOutputStream(stateFile)) {
        properties.store(outputStream, "Keycloak upgrade integration test tenant state");
      }
    } catch (IOException exception) {
      throw new IllegalStateException("Failed to write Keycloak upgrade tenant state to "
        + stateFile.toAbsolutePath(), exception);
    }
  }

  private static Properties load() {
    var stateFile = stateFile();
    if (!Files.exists(stateFile)) {
      throw new IllegalStateException("Keycloak upgrade tenant state file does not exist: "
        + stateFile.toAbsolutePath() + ". Run KeycloakUpgradeSeedTests first.");
    }

    try (InputStream inputStream = Files.newInputStream(stateFile)) {
      var properties = new Properties();
      properties.load(inputStream);
      return properties;
    } catch (IOException exception) {
      throw new IllegalStateException("Failed to read Keycloak upgrade tenant state from "
        + stateFile.toAbsolutePath(), exception);
    }
  }

  private static Path stateFile() {
    var override = System.getProperty(STATE_FILE);
    return isBlank(override) ? DEFAULT_STATE_FILE : Path.of(override);
  }

  private static void addMissingConsortiaState(Properties properties) {
    properties.computeIfAbsent(MEMBER_TENANT, key -> randomTenantName("kcmember"));
    properties.computeIfAbsent(MEMBER_TENANT_ID, key -> UUID.randomUUID().toString());
    properties.computeIfAbsent(CONSORTIUM_ID, key -> UUID.randomUUID().toString());
    properties.computeIfAbsent(CONSORTIA_ADMIN_ID, key -> UUID.randomUUID().toString());
    properties.computeIfAbsent(MEMBER_ADMIN_ID, key -> UUID.randomUUID().toString());
    properties.computeIfAbsent(CONSORTIA_USER_ID, key -> UUID.randomUUID().toString());
  }

  private static void validateState(Properties properties) {
    for (String key : REQUIRED_STATE_KEYS) {
      if (isBlank(properties.getProperty(key))) {
        throw new IllegalStateException("Keycloak upgrade tenant state is missing " + key + " in "
          + stateFile().toAbsolutePath() + ". Delete the state file and rerun KeycloakUpgradeSeedTests.");
      }
    }
  }

  private static void setTenantProperties(Properties properties) {
    properties.stringPropertyNames().forEach(name -> System.setProperty(name, properties.getProperty(name)));
  }

  private static String randomTenantName(String prefix) {
    return prefix + UUID.randomUUID().toString().replace("-", "").substring(0, 12);
  }

  private static boolean isBlank(String value) {
    return value == null || value.isBlank();
  }
}
