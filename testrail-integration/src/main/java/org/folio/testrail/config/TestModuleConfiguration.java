package org.folio.testrail.config;

public class TestModuleConfiguration {

  private final String basePath;
  private final String suiteName;
  private final long suiteId;
  private final long sectionId;

  public TestModuleConfiguration(String basePath, String suitName, long suiteId, long sectionId) {
    this.basePath = basePath;
    this.suiteName = suitName;
    this.suiteId = suiteId;
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
