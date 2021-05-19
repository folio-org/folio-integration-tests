package org.folio;

import static java.lang.String.format;
import static org.folio.TestUtils.specifyRandomRunnerId;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;

import com.intuit.karate.junit5.Karate;

public class ModFeesFinesApiTests extends TestBase {
  private static final String TEST_BASE_PATH = "classpath:domain/mod-feesfines/features/";

  public ModFeesFinesApiTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  private Karate run(String feature) {
    specifyRandomRunnerId();
    return Karate.run(format("%s/%s.feature", TEST_BASE_PATH, feature));
  }

  // We have a separate test class for owners that also provides TestRail integration.
//  @Karate.Test
//  Karate ownersTest() {
//    return run("owners");
//  }

  @Karate.Test
  Karate accountsTest() {
    return run("accounts");
  }

  @Karate.Test
  Karate feeFineActionsTest() {
    return run("feeFineActions");
  }

  @Karate.Test
  Karate feeFineReportsTest() {
    return run("feeFineReports");
  }

  @Karate.Test
  Karate feeFineTypesTest() {
    return run("feeFineTypes");
  }

  @Karate.Test
  Karate lostItemFeePoliciesTest() {
    return run("lostItemFeePolicies");
  }

  @Karate.Test
  Karate manualPatronBlocksTest() {
    return run("manualBlocks");
  }

  @Karate.Test
  Karate manualPatronBlockTemplatesTest() {
    return run("manualBlockTemplates");
  }

  @Karate.Test
  Karate overdueFinePoliciesTestTest() {
    return run("overdueFinePolicies");
  }

  @Karate.Test
  Karate moduleTenantApiTestTest() {
    return run("moduleTenantApi");
  }
}
