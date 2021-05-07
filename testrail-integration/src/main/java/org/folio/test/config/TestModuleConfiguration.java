package org.folio.test.config;

public class TestModuleConfiguration {

  private final String basePath;

  public TestModuleConfiguration(String basePath) {
    this.basePath = basePath;
  }

  public String getBasePath() {
    return basePath;
  }

}
