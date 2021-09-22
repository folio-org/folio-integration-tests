package org.folio;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;

class KbEbscoApiTests extends TestBase {

  private static final String TEST_BASE_PATH = "classpath:domain/mod-kb-ebsco-java/features/";

  public KbEbscoApiTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:domain/mod-kb-ebsco-java/kb-ebsco-junit.feature");
    runFeature("classpath:domain/mod-kb-ebsco-java/features/setup/setup.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }

//  @Test
//  void accessTypesTest() {
//    runFeatureTest("access-types");
//  }
//
//  @Test
//  void kbCredentialsTest() {
//    runFeatureTest("kb-credentials");
//  }
//
//  @Test
//  void packagesTest() {
//    runFeatureTest("packages");
//  }
//
//  @Test
//  void providersTest() {
//    runFeatureTest("providers");
//  }
//
//  @Test
//  void proxyTest() {
//    runFeatureTest("proxy");
//  }
//
//  @Test
//  void resourcesTest() {
//    runFeatureTest("resources");
//  }
//
//  @Test
//  void statusTest() {
//    runFeatureTest("status");
//  }
//
//  @Test
//  void tagsTest() {
//    runFeatureTest("tags");
//  }

  @Test
  void titlesTest() {
    runFeatureTest("titles");
  }

//  @Test
//  void userAssigmentTest() {
//    runFeatureTest("user-assignment");
//  }
}