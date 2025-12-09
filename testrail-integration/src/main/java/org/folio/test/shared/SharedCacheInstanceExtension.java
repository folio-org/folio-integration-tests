package org.folio.test.shared;

import org.junit.jupiter.api.extension.BeforeAllCallback;
import org.junit.jupiter.api.extension.ExtensionContext;

import static org.folio.test.shared.SharedCacheInstanceInitializer.start;

public class SharedCacheInstanceExtension implements BeforeAllCallback {

  @Override
  public void beforeAll(ExtensionContext context) {
    start();
  }
}