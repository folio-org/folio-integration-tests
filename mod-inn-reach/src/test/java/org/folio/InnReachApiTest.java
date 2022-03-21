package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class InnReachApiTest extends TestBase {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:volaris/features/";

  public InnReachApiTest() {
    super(new TestIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void getBibRecord() {
    runFeatureTest("bib-info");
  }

  @Test
  void innReachCirculation() {
    runFeatureTest("inn-reach-circulation");
  }

  @Test
  void patronInfo() {
    runFeatureTest("patron-info");
  }

  @Test
  void agencyMappings() {
    runFeatureTest("agency-mappings");
  }

  @Test
  void authentication() {
    runFeatureTest("authentication");
  }

  @Test
  void centralPatronTypeMapping() {
    runFeatureTest("central-patron-type-mapping");
  }

  @Test
  void centralServerConfiguration() {
    runFeatureTest("central-server-configuration");
  }

  @Test
  void centralServer() {
    runFeatureTest("central-server");
  }

  @Test
  void contribution() {
    runFeatureTest("contribution");
  }

  @Test
  void contributionCriteria() {
    runFeatureTest("contribution-criteria");
  }

  @Test
  void InnReachLocation() {
    runFeatureTest("inn-reach-location");
  }

  @Test
  void handleD2RProxyCall() {
    runFeatureTest("inn-reach-proxy");
  }

  @Test
  void InnReachRecallUser() {
    runFeatureTest("inn-reach-recall-user");
  }

  @Test
  void InnReachTransaction() {
    runFeatureTest("inn-reach-transaction");
  }

  @Test
  void ItemContributionOptionsConfiguration() {
    runFeatureTest("item-contribution-options-configuration");
  }

  @Test
  void ItemTypeMapping() {
    runFeatureTest("item-type-mapping");
  }

  @Test
  void LibraryMapping() {
    runFeatureTest("library-mapping");
  }

  @Test
  void LocationMapping() {
    runFeatureTest("location-mapping");
  }

  @Test
  void MARCRecordTransformation() {
    runFeatureTest("marc-record-transformation");
  }

  @Test
  void MARCTransformationOptionsSettings() {
    runFeatureTest("marc-transformation-options-settings");
  }

  @Test
  void MaterialTypeMapping() {
    runFeatureTest("material-type-mapping");
  }

  @Test
  void PatronTypeMapping() {
    runFeatureTest("patron-type-mapping");
  }

  @Test
  void UserCustomFieldMapping() {
    runFeatureTest("user-custom-field-mapping");
  }

  @BeforeAll
  public void innReachApiTestBeforeAll() {
    runFeature("classpath:volaris/mod-inn-reach-junit.feature");
  }

  @AfterAll
  public void innReachApiTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }

}


