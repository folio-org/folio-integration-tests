package org.folio.test.models;

import java.util.List;

public record AddResultsForCasesRequest(List<Result> results) {
  @Override
  public String toString() {
    return "AddResultsForCasesRequest{" +
      "results=" + results +
      '}';
  }
}
