package org.folio.shared;

import java.util.function.Consumer;

public class SharedOrdersTenant extends BaseSharedTenant {

  private static final String INIT_FEATURE_PATH = "classpath:thunderjet/mod-orders/init-orders.feature";
  private static final String SHARED_TENANT_FILE = "target/shared-orders-tenant.properties";
  private static final String LAST_CLASS_NAME = "org.folio.OrdersSmokeApiTest";

  private SharedOrdersTenant() {
  }

  public static boolean initializeTenant(String tenantPrefix, Class<?> ownerClass, Consumer<String> initFeatureRunner) {
    var config = new TenantConfig(tenantPrefix, INIT_FEATURE_PATH, SHARED_TENANT_FILE);
    var context = new TenantContext(ownerClass, initFeatureRunner);
    return BaseSharedTenant.initializeTenant(config, context);
  }

  public static void cleanupTenant(boolean createdTenant, Consumer<String> destroyFeatureRunner) {
    var config = new TenantConfig(null, INIT_FEATURE_PATH, SHARED_TENANT_FILE);
    var context = new TenantContext(null, destroyFeatureRunner);
    BaseSharedTenant.cleanupTenant(createdTenant, config, context, LAST_CLASS_NAME);
  }
}

