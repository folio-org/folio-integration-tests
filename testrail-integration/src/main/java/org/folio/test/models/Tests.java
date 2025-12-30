package org.folio.test.models;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

public record Tests(Integer offset, Integer limit, Integer size, @JsonProperty("_links") Links links, List<Test> tests) {
  @Override
  public String toString() {
    return "Tests{" +
      "offset=" + offset +
      ", limit=" + limit +
      ", size=" + size +
      ", links=" + links +
      ", tests=" + tests +
      '}';
  }
}
