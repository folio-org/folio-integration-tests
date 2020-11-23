package org.folio.testrail.api;

import io.netty.karate.handler.codec.http.HttpMethod;

public interface ApiEntry {

  ApiEntry getHolder();

  default String getName() {
    return getHolder().getName();
  }

  default String getUrl() {
    return getHolder().getUrl();
  }

  default HttpMethod getMethod() {
    return getHolder().getMethod();
  }

}
