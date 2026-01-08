package org.folio.shared;

import java.util.function.Consumer;

public class SharedInvoicesTenant extends BaseSharedTenant {

  private static final String INIT_FEATURE_PATH = "classpath:thunderjet/mod-invoice/init-invoice.feature";
  private static final String SHARED_TENANT_FILE = "target/shared-invoices-tenant.properties";
  private static final String LAST_CLASS_NAME = "org.folio.InvoicesSmokeApiTest";

  private SharedInvoicesTenant() {
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

