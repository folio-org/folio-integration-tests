package org.folio.test.hooks;

import com.intuit.karate.RuntimeHook;
import com.intuit.karate.core.FeatureRuntime;
import org.folio.test.annotation.FolioTest;
import org.junit.jupiter.api.TestInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public record FolioRuntimeHook(Class<?> testClass, TestInfo testInfo, int number) implements RuntimeHook {

  private static final Logger logger = LoggerFactory.getLogger(FolioRuntimeHook.class);

  @Override
  public void afterFeature(FeatureRuntime featureRuntime) {
    var annotation = testClass.getAnnotation(FolioTest.class);
    if (annotation != null) {
      var testName = getTestName();
      var prefix = "[" + annotation.team() + "/" + annotation.module() + "] " + testName + " {" + number + "}  ";
      featureRuntime.result.setDisplayName(prefix + featureRuntime.result.getDisplayName());
    } else {
      logger.debug("FolioTest annotation not found on test class {}. Feature display name won't be modified.", testClass.getName());
    }
  }

  private String getTestName() {
    if (testInfo == null || testInfo.getTestMethod().isEmpty()) {
      return testClass.getSimpleName();
    } else {
      return testClass.getSimpleName() + "_" + testInfo.getTestMethod().get().getName();
    }
  }
}
