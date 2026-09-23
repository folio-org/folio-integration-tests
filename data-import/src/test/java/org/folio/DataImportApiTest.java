package org.folio;

import static org.folio.test.config.TestParam.TEST_TENANT;
import static org.folio.test.config.TestParam.TEST_TENANT_ID;

import java.util.Arrays;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

@FolioTest(team = "promin", module = "data-import")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class DataImportApiTest extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:promin/data-import/features/";
  private static final int THREAD_COUNT = 3;

  // Explicit feature list so that scenarios owned by DataImportCriticalPathApiTest and
  // DataImportExtendedApiTest are not run again here.
  private static final String[] FEATURES = {
    "marc-records/default-mapping-rules-update-and-verify.feature",
    "data-import-integration",
    "edifact/import-edi-invoice",
    "file-operations/file-extensions",
    "file-operations/file-upload",
    "file-operations/split-feature-enabled",
    "logging/data-import-delete-logs",
    "marc-records/marc-authorities/create/data-import-authority-records",
    "marc-records/data-import-holdings-records",
    "marc-records/marc-bibs/orders/data-import-orders",
    "marc-records/marc-bibs/delete/data-import-set-for-deletion",
    "marc-records/marc-bibs/data-import-bib-records",
    "marc-records/marc-bibs/create/data-import-multiple-records-from-marc-bib",
    "marc-records/marc-bibs/create/marc-bib-010z-canceled-lccn-second-position",
    "marc-records/marc-bibs/create/marc-bib-035-oclc-prefix-leading-zeros-duplicates",
    "marc-records/marc-bibs/create/item-notes-and-checkin-checkout-notes-mapping",
    "marc-records/marc-bibs/create/create-instance-holdings-and-items",
    "marc-records/marc-bibs/create/create-marc-bib-match-profile-suppress-from-discovery",
    "marc-records/marc-bibs/create/modify-action-remove-999-field-create-instance",
    "marc-records/marc-bibs/create/unmapped-marc-subfields-integration",
    "marc-records/marc-bibs/match/static-match-holdings-permanent-location-different-format",
    "marc-records/marc-bibs/match/match-on-location-update-holdings-and-item-locations",
    "marc-records/marc-bibs/match/match-by-canceled-lccn-update-instance",
    "marc-records/marc-bibs/match/marc-to-marc-match-by-010z",
    "marc-records/marc-bibs/match/static-match-permanent-location",
    "marc-records/marc-bibs/match/match-marc-to-marc-update-status-and-statistical-code",
    "marc-records/marc-bibs/match/match-marc-to-marc-update-discovery-suppress-status-and-statistical-code",
    "marc-records/marc-bibs/match/match-marc-to-marc-update-suppress-flags-and-statistical-code",
    "marc-records/marc-bibs/match/match-marc-to-marc-suppress-statistical-code-status-uncataloged",
    "marc-records/marc-bibs/match/match-marc-to-marc-update-instance-fail-holdings-and-items",
    "marc-records/marc-bibs/match/match-marc-to-marc-update-instance-and-holdings-fail-items",
    "marc-records/marc-bibs/match/instance-identifier-match",
    "marc-records/marc-bibs/match/match-by-canceled-lccn-update-instance-suppress-from-discovery",
    "marc-records/marc-bibs/match/pol-vrn-matching",
    "marc-records/marc-bibs/update/marc-bib-035-oclc-prefix-leading-zeros-duplicates-update",
    "marc-records/marc-bibs/update/modify-marc-bib-update-instance-holdings-and-items"
  };

  public DataImportApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    if (shouldCreateTenant()) {
      feature("classpath:promin/data-import/data-import-junit.feature")
        .reportDir(timestampedReportDir())
        .run();
    }
    feature("classpath:promin/data-import/global/create-marc-records.feature")
      .reportDir(timestampedReportDir())
      .run();
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
  void dataImportTest() {
    runFeatures(Arrays.asList(FEATURES), THREAD_COUNT, null);
  }
}
