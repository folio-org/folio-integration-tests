package org.folio;

import static org.folio.TestUtils.runHook;

import com.intuit.karate.junit5.Karate;
import java.io.IOException;
import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.junit.Ignore;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class CrossModulesApiTest extends AbstractTestRailIntegrationTest {

  private static final String TEST_SUITE_NAME = "cross-modules";
  private static final Long DEFAULT_SUITE_ID = 111l;
  private static final Long DEFAULT_SECTION_ID = 1385l;

  private static String TEST_BASE_PATH = "classpath:domain/cross-modules/features/";

  private static String TEST_CASE_NAME_1 = "create-order-with-invoice-that-has-enough-money";
  private static String TEST_CASE_NAME_2 = "order-invoice-relation";

  public CrossModulesApiTest() {
    super(TEST_BASE_PATH, TEST_SUITE_NAME, DEFAULT_SUITE_ID, DEFAULT_SECTION_ID);
  }

  @Ignore
  @Karate.Test
  Karate financeTest() {
    runHook();
    return Karate.run("classpath:domain/cross-modules/cross-modules.feature");
  }

  @Test
  void createOrderWithInvoiceWithEnoughMoney() throws IOException {
    commonTestCase(TEST_CASE_NAME_1);
  }

  @Test
  void orderInvoiceRelation() throws IOException {
    commonTestCase(TEST_CASE_NAME_2);
  }

  @BeforeAll
  public static void crossModuleApiTestBeforeAll() {
    Karate.run("classpath:domain/cross-modules/cross-modules.feature");
  }

  @AfterAll
  public static void crossModuleApiTestAfterAll() {
    Karate.run("classpath:common/destroy-data.feature");
  }

}