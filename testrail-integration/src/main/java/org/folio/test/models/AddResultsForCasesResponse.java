package org.folio.test.models;

import com.fasterxml.jackson.annotation.JsonProperty;

public record AddResultsForCasesResponse(Long id, @JsonProperty("test_id") Integer testId, @JsonProperty("status_id") Integer statusId) {
  @Override
  public String toString() {
    return "AddResultsForCasesResponse{" +
      "id=" + id +
      ", testId=" + testId +
      ", statusId=" + statusId +
      '}';
  }
}
