package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "folijet", module = "mod-source-record-manager")
public class ModSourceRecordManagerTest extends TestBaseEureka {
  private static final String TEST_BASE_PATH = "classpath:folijet/mod-source-record-manager/features/";

  public ModSourceRecordManagerTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:folijet/mod-source-record-manager/source-record-manager.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void getMappingRulesTest() {
    runFeatureTest("mapping-rules.feature");
  }

  @Test
  void getJobExecutionTest() {
    runFeatureTest("job-execution.feature");
  }

  @Test
  void getMappingMetadataTest() {
    runFeatureTest("mapping-metadata.feature");
  }

}
