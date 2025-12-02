package org.folio.test.config;

public class TestRailException extends RuntimeException {

  private static final String TESTRAIL_ERROR_MESSAGE = "Test Rail returned exception: %s";

  public TestRailException(String message) {
    super(TESTRAIL_ERROR_MESSAGE.formatted(message));
  }

  public TestRailException(String message, Throwable throwable) {
    super(TESTRAIL_ERROR_MESSAGE.formatted(message), throwable);
  }
}
