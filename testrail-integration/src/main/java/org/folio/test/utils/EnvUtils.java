package org.folio.test.utils;

import org.folio.test.config.TestRailEnv;

import java.util.Optional;

public class EnvUtils {

  private EnvUtils(){
  }

  public static Integer getInt(TestRailEnv envVar) {
    return Optional.ofNullable(System.getenv().get(envVar.name()))
      .map(Integer::parseInt)
      .orElse(null);
  }

  public static String getString(TestRailEnv envVar) {
    return Optional.ofNullable(System.getenv(envVar.name()))
      .orElse("");
  }
}
