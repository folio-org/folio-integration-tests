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

@FolioTest(team = "thunderjet", module = "ebsconet")
public class EbsconetApiTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-ebsconet/features/";

  public EbsconetApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void ebsconetApiTestBeforeAll() {
    System.setProperty("testTenant", "testebsconet" + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-ebsconet/init-ebsconet.feature");
  }

  @AfterAll
  public void ebsconetApiTestAfterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void cancelOrderLinesWithEbsconet() {
    runFeatureTest("cancel-order-lines-with-ebsconet");
  }

  @Test
  void closeOrderWithOrderLine() {
    runFeatureTest("close-order-with-order-line");
  }

  @Test
  void getEbsconetOrderLine() {
    runFeatureTest("get-ebsconet-order-line");
  }

  @Test
  void updateEbsconetOrderLine() {
    runFeatureTest("update-ebsconet-order-line");
  }

  @Test
  void updateEbsconetOrderLineEmptyLocations() {
    runFeatureTest("update-ebsconet-order-line-empty-locations");
  }

  @Test
  void updateEbsconetOrderLineMixedFormat() {
    runFeatureTest("update-mixed-order-line");
  }
}
