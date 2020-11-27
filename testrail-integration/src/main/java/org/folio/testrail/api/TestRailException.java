package org.folio.testrail.api;

public class TestRailException extends Exception {

  private static final String TESTRAIL_ERROR_MESSAGE = "TestRail API return HTTP ";

  public TestRailException(String message) {
    super(TESTRAIL_ERROR_MESSAGE + message);
  }
}
