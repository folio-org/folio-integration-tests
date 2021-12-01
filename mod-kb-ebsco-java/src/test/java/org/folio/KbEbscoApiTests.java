package org.folio;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInfo;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;

class KbEbscoApiTests extends TestBase {

  private static final String TEST_BASE_PATH = "classpath:domain/mod-kb-ebsco-java/features/";
  private static final String SETUP_CREDENTIALS_TAG = "CREDENTIALS";

  public KbEbscoApiTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:domain/mod-kb-ebsco-java/kb-ebsco-junit.feature");
  }

  @BeforeEach
  public void setupCredentials(TestInfo testInfo) {
    if (testInfo.getTags().contains(SETUP_CREDENTIALS_TAG)) {
      runFeature("classpath:domain/mod-kb-ebsco-java/features/setup/setup.feature");
    }
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }

  @AfterEach
  public void destroyCredentials(TestInfo testInfo) {
    if (testInfo.getTags().contains(SETUP_CREDENTIALS_TAG)) {
      runFeature("classpath:domain/mod-kb-ebsco-java/features/setup/destroy.feature");
    }
  }

  @Test
  @Tag(SETUP_CREDENTIALS_TAG)
  void accessTypesTest() {
    runFeatureTest("access-types");
  }

  @Test
  void kbCredentialsTest() {
    runFeatureTest("kb-credentials");
  }

  @Test
  @Tag(SETUP_CREDENTIALS_TAG)
  void packagesTest() {
    runFeatureTest("packages");
  }

  @Test
  @Tag(SETUP_CREDENTIALS_TAG)
  void providersTest() {
    runFeatureTest("providers");
  }

  @Test
  @Tag(SETUP_CREDENTIALS_TAG)
  void proxyTest() {
    runFeatureTest("proxy");
  }

  @Test
  @Tag(SETUP_CREDENTIALS_TAG)
  void resourcesTest() {
    runFeatureTest("resources");
  }

  @Test
  @Tag(SETUP_CREDENTIALS_TAG)
  void statusTest() {
    runFeatureTest("status");
  }

  @Test
  void tagsTest() {
    runFeatureTest("tags");
  }

  @Test
  @Tag(SETUP_CREDENTIALS_TAG)
  void titlesTest() {
    runFeatureTest("titles");
  }

  @Test
  @Tag(SETUP_CREDENTIALS_TAG)
  void userAssigmentTest() {
    runFeatureTest("user-assignment");
  }

  @Test
  @Tag(SETUP_CREDENTIALS_TAG)
  void usageConsolidationTest() {
    runFeatureTest("usage-consolidation");
  }
}