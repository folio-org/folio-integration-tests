package org.folio.test.models;

public enum ResultStatus {
  PASSED(1),
  BLOCKED(2),
  UNTESTED(3),
  RETEST(4),
  FAILED(5);

  private final int statusId;

  ResultStatus(int statusId) {
    this.statusId = statusId;
  }

  public int getStatusId() {
    return statusId;
  }
}