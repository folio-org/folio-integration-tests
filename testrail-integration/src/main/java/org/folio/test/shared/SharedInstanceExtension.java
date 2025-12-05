package org.folio.test.shared;

import org.junit.jupiter.api.extension.BeforeAllCallback;
import org.junit.jupiter.api.extension.ExtensionContext;

import static org.folio.test.shared.SharedInstanceInitializer.start;

public class SharedInstanceExtension implements BeforeAllCallback {

  @Override
  public void beforeAll(ExtensionContext context) {
    start();
  }
}