package org.folio.testrail.config;

import static org.folio.testrail.config.TestConfigurationConstants.CROSS_MODULE_TEST_BASE_PATH;
import static org.folio.testrail.config.TestConfigurationConstants.CROSS_MODULE_TEST_SECTION_ID;
import static org.folio.testrail.config.TestConfigurationConstants.CROSS_MODULE_TEST_SUITE_NAME;
import static org.folio.testrail.config.TestConfigurationConstants.FINANCE_TEST_BASE_PATH;
import static org.folio.testrail.config.TestConfigurationConstants.FINANCE_TEST_SECTION_ID;
import static org.folio.testrail.config.TestConfigurationConstants.FINANCE_TEST_SUITE_NAME;
import static org.folio.testrail.config.TestConfigurationConstants.INVOICES_TEST_BASE_PATH;
import static org.folio.testrail.config.TestConfigurationConstants.INVOICES_TEST_SECTION_ID;
import static org.folio.testrail.config.TestConfigurationConstants.INVOICES_TEST_SUITE_NAME;
import static org.folio.testrail.config.TestConfigurationConstants.ORDERS_TEST_BASE_PATH;
import static org.folio.testrail.config.TestConfigurationConstants.ORDERS_TEST_SECTION_ID;
import static org.folio.testrail.config.TestConfigurationConstants.ORDERS_TEST_SUITE_NAME;
import static org.folio.testrail.config.TestConfigurationConstants.TEST_SUITE_ID;

public enum TestConfigurationEnum {

  CROSS_MODULE_CONFIGURATION(CROSS_MODULE_TEST_BASE_PATH,
                             CROSS_MODULE_TEST_SUITE_NAME,
                             TEST_SUITE_ID,
                             CROSS_MODULE_TEST_SECTION_ID),

  FINANCE_CONFIGURATION(FINANCE_TEST_BASE_PATH,
                        FINANCE_TEST_SUITE_NAME,
                        TEST_SUITE_ID,
                        FINANCE_TEST_SECTION_ID),

  INVOICES_CONFIGURATION(INVOICES_TEST_BASE_PATH,
                         INVOICES_TEST_SUITE_NAME,
                         TEST_SUITE_ID,
                         INVOICES_TEST_SECTION_ID),

  ORDERS_CONFIGURATION(ORDERS_TEST_BASE_PATH,
                       ORDERS_TEST_SUITE_NAME,
                       TEST_SUITE_ID,
                       ORDERS_TEST_SECTION_ID);

  private String basePath;
  private String suiteName;
  private long suiteId;
  private long sectionId;

  TestConfigurationEnum(String basePath, String suitName, long suitId, long sectionId) {
    this.basePath = basePath;
    this.suiteName = suitName;
    this.suiteId = suitId;
    this.sectionId = sectionId;
  }

  public String getBasePath() {
    return basePath;
  }

  public String getSuiteName() {
    return suiteName;
  }

  public long getSuiteId() {
    return suiteId;
  }

  public long getSectionId() {
    return sectionId;
  }
}
