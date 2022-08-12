package org.folio.test.karate;

import com.intuit.karate.RuntimeHook;
import com.intuit.karate.core.FeatureRuntime;
import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.junit.jupiter.api.TestInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class FolioRuntimeHook implements RuntimeHook {

    protected static final Logger logger = LoggerFactory.getLogger(TestBase.class);

    private Class<?> testClass;

    private TestInfo testInfo;

    private int number;

    public FolioRuntimeHook(Class<?> testClass, TestInfo testInfo, int number) {
        this.testClass = testClass;
        this.testInfo = testInfo;
        this.number = number;
    }

    @Override
    public void afterFeature(FeatureRuntime fr) {
        FolioTest annotation = testClass.getAnnotation(FolioTest.class);
        if (annotation != null) {
            String testName = getTestName(annotation);
            String prefix = "[" + annotation.team() + "/" + annotation.module() + "] " + testName + " {" + number + "}  ";

            fr.result.setDisplayName(prefix + fr.result.getDisplayName());
        } else {
            logger.debug(String.format("FolioTest annotation not found on test class '%s'. Feature display name won't be modified.", testClass.getName()));
        }
    }

    private String getTestName(FolioTest annotation) {
        if (testInfo == null || !testInfo.getTestMethod().isPresent()) {
            return testClass.getSimpleName();
        } else {
            return testClass.getSimpleName() + "_" + testInfo.getTestMethod().get().getName();
        }
    }

}
