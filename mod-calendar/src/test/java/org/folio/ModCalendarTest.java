package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "bama", module = "mod-calendar")
public class ModCalendarTest extends TestBase {

  private static final String TEST_BASE_PATH =
    "classpath:bama/mod-calendar/features/";

  public ModCalendarTest() {
    super(
      new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH))
    );
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:bama/mod-calendar/calendar-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }

  @Test
  void testCalendarSearch() {
    runFeatureTest("calendar-search");
  }

  @Test
  void testCalendarCreate() {
    runFeatureTest("calendar-create");
  }

  @Test
  void testCalendarEdit() {
    runFeatureTest("calendar-edit");
  }

  @Test
  void testCalendarSurroundingDates() {
    runFeatureTest("calendar-dates-surrounding");
  }

  @Test
  void testCalendarAllDates() {
    runFeatureTest("calendar-dates-all");
  }
}
