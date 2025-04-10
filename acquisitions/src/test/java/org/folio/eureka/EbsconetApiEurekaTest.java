package org.folio.eureka;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Disabled;
@Disabled
@FolioTest(team = "thunderjet", module = "ebsconet")
public class EbsconetApiEurekaTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-ebsconet/eureka/features/";

  public EbsconetApiEurekaTest() {
    super(new TestIntegrationService(
      new TestModuleConfiguration(TEST_BASE_PATH)));
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
  void updateEbsconetOrderLineMixedFormat() {
    runFeatureTest("update-mixed-order-line");
  }

  @Test
  void cancelOrderLinesWithEbsconet() {
    runFeatureTest("cancel-order-lines-with-ebsconet");
  }
  @Test
  void updateEbsconetOrderLineEmptyLocations() {
    runFeatureTest("update-ebsconet-order-line-empty-locations");
  }

  @BeforeAll
  public void ebsconetApiTestBeforeAll() {
    runFeature("classpath:thunderjet/mod-ebsconet/eureka/ebsconet-junit.feature");
  }

  @AfterAll
  public void ebsconetApiTestAfterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

}
