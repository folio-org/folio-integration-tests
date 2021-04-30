package org.folio;

import java.util.Optional;
import java.util.Random;

public class TestUtils {

  private TestUtils() {
  }

  public static void runHook() {
    Optional.ofNullable(System.getenv("karate.env"))
      .ifPresent(env -> System.setProperty("karate.env", env));
    System.setProperty("runId", String.valueOf(new Random().nextInt(100)));
  }
}
