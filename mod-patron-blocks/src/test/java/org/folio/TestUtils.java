package org.folio;

import java.util.Random;

public class TestUtils {

  private TestUtils() {
  }

  public static void specifyRandomRunnerId() {
    System.setProperty("runId", String.valueOf(new Random().nextInt(100)));
  }
}
