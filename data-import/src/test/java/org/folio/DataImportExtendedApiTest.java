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

@FolioTest(team = "promin", module = "data-import")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class DataImportExtendedApiTest extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:promin/data-import/features/";
  private static final String MATCH_AUTHORITY_PATH =
    "classpath:promin/data-import/features/marc-records/marc-authorities/match/";

  public DataImportExtendedApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
  }

  @BeforeAll
  public void setup() {
    if (shouldCreateTenant()) {
      feature("classpath:promin/data-import/data-import-junit.feature")
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
  void relatorTermCode1xx7xxFieldsContributors() {
    feature("classpath:promin/data-import/features/marc-records/marc-bibs/create/relator-term-code-1xx-7xx-fields.feature")
      .run();
  }

  @Test
  void contributors720RelatorTermsAndCodes() {
    feature("classpath:promin/data-import/features/marc-records/marc-bibs/create/contributors-720-relator-terms-and-codes.feature")
      .run();
  }

  @Test
  void authorityComparisonPartExtended() {
    feature(MATCH_AUTHORITY_PATH + "authority-comparison-part-extended.feature")
      .run();
  }

  // MODSOURCE-1019: "Only compare part of the value" on 001 for MARC Authority.
  // C1538655, C1538657, C1538658. Not yet classified in TestRail - move to CriticalPath if needed.
  @Test
  void authority001ComparisonPart() {
    feature(MATCH_AUTHORITY_PATH + "authority-001-comparison-part.feature")
      .run();
  }

  @Test
  void diAuthorityExtended() {
    feature("classpath:promin/data-import/features/marc-records/marc-authorities/create/data-import-authority-records-extended.feature")
      .run();
  }

  @Test
  void oclcCopycatImportAndOverlay() {
    feature("classpath:promin/data-import/features/marc-records/marc-bibs/single-record-import/oclc-copycat-import-and-overlay.feature")
      .run();
  }

  @Test
  void marcToMarcMatchBy008Field() {
    feature("classpath:promin/data-import/features/marc-records/marc-bibs/match/marc-to-marc-match-by-008-field.feature")
      .run();
  }
}
