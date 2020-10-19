package com.gurock.testrail.api;

import io.netty.karate.handler.codec.http.HttpMethod;

public class ApiEntryHolder implements ApiEntry {

  private String name;
  private String url;
  private HttpMethod method;

  public ApiEntryHolder(String name, String url, HttpMethod method) {
    this.name = name;
    this.url = url;
    this.method = method;
  }

  @Override
  public String getName() {
    return name;
  }

  @Override
  public String getUrl() {
    return url;
  }

  @Override
  public HttpMethod getMethod() {
    return method;
  }

  public ApiEntryHolder getHolder() {
    return this;
  }
}
