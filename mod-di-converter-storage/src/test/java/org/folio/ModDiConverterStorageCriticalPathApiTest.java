package org.folio;

import static org.folio.test.config.TestParam.TEST_TENANT;
import static org.folio.test.config.TestParam.TEST_TENANT_ID;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

/**
 * mod-di-converter-storage scenarios that TestRail classifies as Critical Path.
 */
@FolioTest(team = "promin", module = "mod-di-converter-storage")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class ModDiConverterStorageCriticalPathApiTest extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:promin/mod-di-converter-storage/features/";
  private static final String DELETE_AUTHORITY_PATH = TEST_BASE_PATH + "delete-authority/";

  public ModDiConverterStorageCriticalPathApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
  }

  @BeforeAll
  public void setup() {
    if (shouldCreateTenant()) {
      feature("classpath:promin/mod-di-converter-storage/data-import-converter-storage-junit.feature")
        .reportDir(timestampedReportDir())
        .run();
    }
  }

  @AfterAll
  public void teardown() {
    if (shouldCreateTenant()) {
      try {
        feature("classpath:common/eureka/destroy-data.feature")
          .reportDir(timestampedReportDir())
          .run();
      } finally {
        System.clearProperty(TEST_TENANT.getValue());
        System.clearProperty(TEST_TENANT_ID.getValue());
      }
    }
  }

  @Test
  void deleteAuthorityProfileSettings() {
    feature(DELETE_AUTHORITY_PATH + "delete-authority-profile-settings.feature")
      .run();
  }
}
