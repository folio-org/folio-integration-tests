package org.folio;

import org.apache.commons.lang3.RandomUtils;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.util.UUID;

@FolioTest(team = "thunderjet", module = "mod-mosaic")
class MosaicApiTest extends TestBaseEureka {

  // Default module settings :
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-mosaic/features/";

  MosaicApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  void mosaicApiTestBeforeAll() {
    System.setProperty("testTenant", "testmosaic" + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-mosaic/init-mosaic.feature");
  }

  @AfterAll
  void mosaicApiTestAfterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void validateOrder() {
    runFeatureTest("validate-order.feature");
  }

  @Test
  void createOrder1FromMinimalTemplate() {
    runFeatureTest("create-order-1-from-minimal-template.feature");
  }

  @Test
  void createOrder2FromDefaultTemplate() {
    runFeatureTest("create-order-2-from-default-template.feature");
  }

  @Test
  void createOrder3FromPhysicalTemplate() {
    runFeatureTest("create-order-3-from-physical-template.feature");
  }

  @Test
  void createOrder4FromElectronicTemplate() {
    runFeatureTest("create-order-4-from-electronic-template.feature");
  }

  @Test
  void createOrder5FromPEMixTemplate() {
    runFeatureTest("create-order-5-from-pe-mix-template.feature");
  }

  @Test
  void createOrder6WithOpenWorkflowStatus() {
    runFeatureTest("create-order-6-with-open-workflow-status.feature");
  }

  @Test
  void createOrder7WithCheckInItems() {
    runFeatureTest("create-order-7-with-check-in-items.feature");
  }
}
