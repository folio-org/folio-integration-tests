package org.folio.shared;

import org.apache.commons.lang3.RandomUtils;

import java.util.UUID;

public class SharedTenantOptions {

  /**
   *  Returns a property object containing tenant name, tenant id and the destroy option, which are
   *  needed for {@code AcquisitionsTest.beforeAll() and AcquisitionsTest.afterAll()} operation.
   *  <ul>
   *  <li>To use an existing tenant, pass {@code -Dtenant-name=<name>} and {@code -Dtenant-id=<id>}  VM options.</li>
   *  <li>To target the existing tenant for destruction, pass {@code -Ddestroy=true} VM option.</li>
   *  </ul>
   *
   * @param tenantPrefix Tenant prefix of a target class
   * @return Tenant properties as a {@code TenantData} object
   */
  static TenantData getTenant(String tenantPrefix) {
    var tenantName = System.getProperty("tenant-name");
    var tenantId = System.getProperty("tenant-id");
    var destroy = Boolean.parseBoolean(System.getProperty("destroy"));
    if (tenantName == null || tenantId == null) {
      tenantName = tenantPrefix + RandomUtils.nextLong();
      tenantId = UUID.randomUUID().toString();
    }
    return new TenantData(tenantName, tenantId, destroy);
  }

  record TenantData(String name, String id, boolean destroy) {
  }

  /**
   * Returns a property needed for tenant cleanup to be run in the {@code AcquisitionsTest.afterAll()} method.
   * <ul>
   *   <li>To ignore tenant cleanup, pass {@code -Dignore-cleanup=true} VM option.</li>
   * </ul>
   *
   * @return Cleanup property as a {@code boolean}
   */
  static boolean isIgnoreCleanup() {
    return Boolean.parseBoolean(System.getProperty("ignore-cleanup"));
  }

  /**
   * Returns a property of the run mode, which can be used to either run test methods individually, on their own Java
   * "thread pool-per-method" way, or utilize the "shared thread pool-per-class" mode (i.e. methods defined by an enum
   * implementing CommonFeature). By default, tests in the CI enable the "shared thread pool-per-class" for efficiency,
   * while existing options reserve the ability to run individual methods locally using the "dev" profile with or
   * without the shared thread pool.
   * <ul>
   *   <li>To run a single test method without the shared pool, pass {@code -Dkarate.env=dev} VM option.</li>
   *   <li>To run the full class without the shared pool, pass {@code -Dkarate.env=dev -Dtest.mode=no-shared-pool} VM options.</li>
   * </ul>
   * @return run mode property as a {@code boolean}
   */
  static boolean isIndividualRunMode() {
    return "no-shared-pool".equals(System.getProperty("test.mode")) || "dev".equals(System.getProperty("karate.env"));
  }
}
