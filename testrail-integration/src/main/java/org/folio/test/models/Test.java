package org.folio.test.models;

import com.fasterxml.jackson.annotation.JsonProperty;

public record Test(Long id, @JsonProperty("case_id") Integer caseId, String title) {
  @Override
  public String toString() {
    return "Test{" +
      "id=" + id +
      ", caseId=" + caseId +
      ", title='" + title + '\'' +
      '}';
  }
}
