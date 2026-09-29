package org.folio;

import static org.folio.test.config.TestParam.TEST_TENANT;
import static org.folio.test.config.TestParam.TEST_TENANT_ID;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

@FolioTest(team = "promin", module = "mod-inventory")
public class ConsortiaInventoryTest extends TestBaseEureka {
  private static final String TEST_BASE_PATH = "classpath:promin/mod-inventory/features/consortia/";

  public ConsortiaInventoryTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature(TEST_BASE_PATH + "consortia-inventory-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    try {
      runFeature(TEST_BASE_PATH + "destroy-consortia.feature");
    } finally {
      // This class never uses the shared testTenant/testTenantId (it builds its own
      // central/university/college tenants), but the inherited runHook() still generates
      // and sets them when unset. Clear them here so a later test class in the same JVM
      // fork doesn't see them as already-provisioned and skip creating its own tenant.
      if (shouldCreateTenant()) {
        System.clearProperty(TEST_TENANT.getValue());
        System.clearProperty(TEST_TENANT_ID.getValue());
      }
    }
  }

  @Test
  void mod_inventoryConsortiaTest() {
    runFeatureTest("features/update-ownership.feature");
  }

  @Test
  void shareMarcInstanceTest() {
    runFeatureTest("features/share-marc-instance.feature");
  }

  @Override
  public void runHook() {
    super.runHook();
    System.setProperty("consortiaAdminUserId", UUID.randomUUID().toString());
    System.setProperty("centralUserId", UUID.randomUUID().toString());
    System.setProperty("universityUserId", UUID.randomUUID().toString());
    System.setProperty("collegeUserId", UUID.randomUUID().toString());
    System.setProperty("consortiumId", UUID.randomUUID().toString());

    System.setProperty("randomNumbers", String.valueOf(ThreadLocalRandom.current().nextLong(Long.MAX_VALUE)));

    System.setProperty("centralTenantId", UUID.randomUUID().toString());
    System.setProperty("collegeTenantId", UUID.randomUUID().toString());
    System.setProperty("universityTenantId", UUID.randomUUID().toString());
  }
}
