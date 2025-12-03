package org.folio.test.config;

public enum TestParam {
  KARATE_ENV("karate.env"),
  TEST_TENANT("testTenant"),
  TEST_TENANT_ID("testTenantId"),
  CLIENT_SECRET("clientSecret");

  private final String value;

  TestParam(String value) {
    this.value = value;
  }

  public String getValue() {
    return value;
  }
}
