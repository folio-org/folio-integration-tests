package org.folio;

import java.util.Optional;
import java.util.Random;
import java.util.function.Function;
import org.apache.commons.lang3.StringUtils;

public class TestUtils {

  private static final String TENANT_TEMPLATE = "testenant";

  private static final Function<String, String> FUNCTION_RANDOM = t -> getNotBlackTemplate(t)
      + new Random().nextInt(1000);

  private static final Function<String, String> FUNCTION_MILLIS = t -> getNotBlackTemplate(t)
      + System.currentTimeMillis();

  private TestUtils() {
  }

  private static String getNotBlackTemplate(String template) {
    return StringUtils.isBlank(template) ? TENANT_TEMPLATE : template;
  }

  private static String generateRandomTenant() {
    return generateRandomTenant(null);
  }

  private static String generateRandomTenantMillis() {
    return generateRandomTenantMillis(null);
  }

  private static String generateRandomTenant(String template) {
    return FUNCTION_RANDOM.apply(template);
  }

  private static String generateRandomTenantMillis(String template) {
    return FUNCTION_MILLIS.apply(template);
  }

  public static void runHook() {
    Optional.ofNullable(System.getenv("karate.env"))
        .ifPresent(env -> System.setProperty("karate.env", env));
    // Provide uniqueness of "testTenant" based on the value specified when karate tests runs
    System.setProperty("testTenant", generateRandomTenantMillis());
  }

}
