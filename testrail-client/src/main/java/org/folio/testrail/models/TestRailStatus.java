package org.folio.testrail.models;

public enum TestRailStatus {
  PASSED(1),
  BLOCKED(2),
  UNTESTED(3),
  RETEST(4), FAILED(5);

  private int statusId;

  TestRailStatus(int i) {
    this.statusId = i;
  }

  public int getStatusId() {
    return statusId;
  }
}
