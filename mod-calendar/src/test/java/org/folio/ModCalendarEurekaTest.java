package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Disabled;
@Disabled
@FolioTest(team = "bama", module = "mod-calendar")
public class ModCalendarEurekaTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH =
            "classpath:bama/mod-calendar/eureka-features/";

    public ModCalendarEurekaTest() {
        super(
                new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH))
        );
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:bama/mod-calendar/calendar-junit-eureka.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/eureka/destroy-data.feature");
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
