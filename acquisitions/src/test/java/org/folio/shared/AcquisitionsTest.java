package org.folio.shared;

public interface AcquisitionsTest {
  void beforeAll();

  void afterAll();

  default void destroyTenant() {}

  void runFeatures();
}