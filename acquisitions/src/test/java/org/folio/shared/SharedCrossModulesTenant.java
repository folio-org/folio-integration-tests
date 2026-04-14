package org.folio.shared;

import java.util.function.Consumer;

public class SharedCrossModulesTenant extends BaseSharedTenant {

  private static final String INIT_FEATURE_PATH = "classpath:thunderjet/cross-modules/init-cross-modules.feature";
  private static final String SHARED_TENANT_FILE = "target/shared-crossmodules-tenant.properties";
  private static final String LAST_CLASS_NAME = "org.folio.CrossModulesExtendedApiTest";

  private SharedCrossModulesTenant() {
  }

  public static boolean initializeTenant(String tenantPrefix, Class<?> ownerClass, Consumer<String> initFeatureRunner) {
    var config = new TenantConfig(tenantPrefix, INIT_FEATURE_PATH, SHARED_TENANT_FILE);
    var context = new TenantContext(ownerClass, initFeatureRunner);
    return BaseSharedTenant.initializeTenant(config, context);
  }

  public static void cleanupTenant(Class<?> ownerClass, Consumer<String> destroyFeatureRunner) {
    var config = new TenantConfig(null, INIT_FEATURE_PATH, SHARED_TENANT_FILE);
    var context = new TenantContext(ownerClass, destroyFeatureRunner);
    BaseSharedTenant.cleanupTenant(config, context, LAST_CLASS_NAME);
  }
}