package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

import static org.folio.test.config.TestParam.TEST_TENANT;
import static org.folio.test.config.TestParam.TEST_TENANT_ID;

@FolioTest(team = "promin", module = "data-import")
class DataImportConsortiaExtendedApiTest extends TestBaseEureka {
  private static final String TEST_BASE_PATH = "classpath:promin/data-import/features/";
  private static final String DELETE_AUTHORITY_BASE_PATH =
    "classpath:promin/data-import/features/marc-records/marc-authorities/delete/consortia/";

  public DataImportConsortiaExtendedApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
  }

  @BeforeAll
  void setup() {
    if (shouldCreateTenant()) {
      feature("classpath:promin/data-import/consortia-data-import-junit.feature")
        .reportDir(timestampedReportDir())
        .run();
    }
  }

  @AfterAll
  void tearDown() {
    if (shouldCreateTenant()) {
      try {
        feature("classpath:promin/data-import/destroy-consortia-junit.feature")
          .reportDir(timestampedReportDir())
          .run();
      } finally {
        System.clearProperty(TEST_TENANT.getValue());
        System.clearProperty(TEST_TENANT_ID.getValue());
      }
    }
  }

  @Test
  void deleteAuthorityFromMemberTenant() {
    feature(DELETE_AUTHORITY_BASE_PATH + "delete-authority-consortia-member-tenant.feature")
      .reportDir(timestampedReportDir())
      .run();
  }

  @Test
  void deleteSharedAuthorityFromCentralTenant() {
    feature(DELETE_AUTHORITY_BASE_PATH + "delete-authority-consortia-central-tenant.feature")
      .reportDir(timestampedReportDir())
      .run();
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
