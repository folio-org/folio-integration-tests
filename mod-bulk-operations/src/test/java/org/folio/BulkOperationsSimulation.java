package org.folio;

import com.intuit.karate.gatling.javaapi.KarateProtocolBuilder;
import io.gatling.javaapi.core.ScenarioBuilder;
import io.gatling.javaapi.core.Simulation;

import java.time.Duration;
import java.util.concurrent.ThreadLocalRandom;

import static com.intuit.karate.gatling.javaapi.KarateDsl.*;
import static io.gatling.javaapi.core.CoreDsl.*;

public class BulkOperationsSimulation extends Simulation {

  private static final String MOD_BULK_OPERATIONS_JUNIT =
      "classpath:firebird/mod-bulk-operations/mod-bulk-operations-junit.feature";
  private static final String INIT_DATA_FOR_USERS =
      "classpath:firebird/mod-bulk-operations/features/init-data/init-data-for-users-gatling.feature";
  private static final String USERS_POSITIVE_SCENARIOS =
      "classpath:firebird/mod-bulk-operations/features/users-positive-scenarios.feature";
  private static final String DESTROY_DATA =
      "classpath:common/destroy-data.feature";

  private static final int CREATE_ITERATIONS =
      Integer.parseInt(System.getProperty("simulation.iterations", "3"));
  private static final int CREATE_USERS =
      Integer.parseInt(System.getProperty("simulation.users", "3"));
  private static final int RAMP_UP_DURATION =
      Integer.parseInt(System.getProperty("simulation.ramp.seconds", "5"));
  private static final String KARATE_ENV =
      System.getProperty("karate.env", "local");

  public static final double SUCCESSFUL_REQUESTS_RATE = 99.0;
  public static final int RESPONSE_MAX_TIME = 50_000;

  private static String generateTenantId() {
    String constantString = "testtenant";
    long randomLong = ThreadLocalRandom.current().nextLong(Long.MAX_VALUE);
    return constantString + randomLong;
  }

  private static String initTenant() {
    String tenantId = generateTenantId();
    System.setProperty("testTenant", tenantId);
    System.out.printf("Running BulkOperationsUsersFlowSimulation with karate.env=%s, testTenant=%s%n",
        KARATE_ENV, tenantId);
    return tenantId;
  }

  public BulkOperationsSimulation() {

    KarateProtocolBuilder protocol = karateProtocol(
        uri("/_/proxy/tenants/{tenant}").nil(),
        uri("/_/proxy/tenants/{tenant}/modules").nil(),
        uri("/_/proxy/tenants/{tenant}/install").nil(),
        uri("/bulk-operations/upload").nil(),
        uri("/bulk-operations/{operationId}/start").nil(),
        uri("/bulk-operations/{operationId}/download").nil(),
        uri("/bulk-operations/{operationId}/preview").nil(),
        uri("/bulk-operations/{operationId}/content-update").nil(),
        uri("/bulk-operations/{operationId}/errors").nil()
    );

    String tenantId = initTenant();

    protocol.runner
        .systemProperty("testTenant", tenantId)
        .systemProperty("karate.env", KARATE_ENV);

    ScenarioBuilder before = scenario("00 - Setup modules and dependencies")
        .exec(karateFeature(MOD_BULK_OPERATIONS_JUNIT));

    ScenarioBuilder init = scenario("01 - Initialize data for users")
        .exec(karateFeature(INIT_DATA_FOR_USERS));

    ScenarioBuilder create = scenario("02 - Create bulk operations - positive users flow")
        .repeat(CREATE_ITERATIONS).on(
            exec(karateFeature(USERS_POSITIVE_SCENARIOS))
        );

    ScenarioBuilder after = scenario("99 - Destroy data and cleanup")
        .exec(karateFeature(DESTROY_DATA));

    setUp(
        before.injectOpen(atOnceUsers(1))
            .andThen(
                init.injectOpen(
                    nothingFor(Duration.ofSeconds(RAMP_UP_DURATION)),
                    atOnceUsers(1)
                )
            )
            .andThen(
                create.injectOpen(
                    nothingFor(Duration.ofSeconds(RAMP_UP_DURATION)),
                    rampUsers(CREATE_USERS).during(Duration.ofSeconds(RAMP_UP_DURATION))
                )
            )
            .andThen(
                after.injectOpen(
                    nothingFor(Duration.ofSeconds(RAMP_UP_DURATION)),
                    atOnceUsers(1)
                )
            )
    )
        .protocols(protocol)
        .assertions(
            global().successfulRequests().percent().gt(SUCCESSFUL_REQUESTS_RATE),
            global().responseTime().max().lt(RESPONSE_MAX_TIME)
        );
  }
}