package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class ModTagsApiTest extends TestBase {
    private static final String TEST_BASE_PATH = "classpath:domain/tags/features/";

    public ModTagsApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void modTagsBeforeAll() {
        runFeature("classpath:domain/tags/basic-junit.feature");
    }

    @Test
    void tagsTest() {
        runFeatureTest("tags");
    }


    /**
     * Not using yet - need changes in tags module
     * https://issues.folio.org/browse/FAT-935
     */
    @AfterAll
    public void modTagsAfterAll() {
//        runFeature("classpath:common/destroy-data.feature");
    }
}
