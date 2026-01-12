package org.folio.test.utils;

import com.intuit.karate.StringUtils;
import org.folio.test.config.TestRailEnv;
import java.util.Optional;

public class EnvUtils {

  private EnvUtils(){
  }

  public static Integer getInt(TestRailEnv envVar) {
    return Optional.ofNullable(System.getenv().get(envVar.name()))
      .filter(value -> !StringUtils.isBlank(value))
      .map(Integer::parseInt)
      .orElse(null);
  }

  public static String getString(TestRailEnv envVar) {
    return Optional.ofNullable(System.getenv(envVar.name()))
      .orElse("");
  }
}
