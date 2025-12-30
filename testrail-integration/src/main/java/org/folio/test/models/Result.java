package org.folio.test.models;

import com.fasterxml.jackson.annotation.JsonProperty;

public class Result {
  private @JsonProperty("case_id") Integer caseId;
  private @JsonProperty("status_id") Integer statusId;
  private @JsonProperty("comment") String comment;

  public void setCaseId(Integer caseId) {
    this.caseId = caseId;
  }

  public void setStatusId(Integer statusId) {
    this.statusId = statusId;
  }

  public void setComment(String comment) {
    this.comment = comment;
  }

  @Override
  public String toString() {
    return "Result{" +
      "caseId=" + caseId +
      ", statusId=" + statusId +
      ", comment='" + comment + '\'' +
      '}';
  }
}
