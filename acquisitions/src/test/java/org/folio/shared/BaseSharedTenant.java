package org.folio.shared;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Properties;
import java.util.function.Consumer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class BaseSharedTenant {

  private static final Logger logger = LoggerFactory.getLogger(BaseSharedTenant.class);
  private static final String DESTROY_FEATURE_PATH = "classpath:common/eureka/destroy-data.feature";
  private static final Object FILE_LOCK = new Object();
  private static final String TEST_TENANT = "testTenant";
  private static final String TEST_TENANT_ID = "testTenantId";
  private static final String OWNER = "owner";

  protected record TenantConfig(String tenantPrefix, String initFeaturePath, String tenantFilePath) {
  }

  protected record TenantContext(Class<?> ownerClass, Consumer<String> featureRunner) {
  }

  protected BaseSharedTenant() {
  }

  protected static boolean initializeTenant(TenantConfig config, TenantContext context) {
    if (SharedTenantOptions.isIndividualRunMode()) {
      var tenant = SharedTenantOptions.getTenant(config.tenantPrefix());
      System.setProperty(TEST_TENANT, tenant.name());
      System.setProperty(TEST_TENANT_ID, tenant.id());
      logger.info("initializeTenant:: Initialized unique individual tenant {} for {}", tenant.name(), context.ownerClass().getSimpleName());
      try {
        if (!tenant.destroy()) {
          context.featureRunner().accept(config.initFeaturePath());
        }
        return true;
      } catch (Exception e) {
        logger.error("initializeTenant:: Failed to initialize individual tenant: {}", e.getMessage(), e);
        throw new RuntimeException("Failed to initialize individual tenant", e);
      }
    }

    try {
      var createdTenant = getOrCreateSharedTenant(config.tenantPrefix(), context.ownerClass(), config.tenantFilePath());
      if (createdTenant) {
        context.featureRunner().accept(config.initFeaturePath());
      }

      return createdTenant;
    } catch (Exception e) {
      logger.error("initializeTenant:: Failed to initialize shared tenant, deleting tenant file: {}", e.getMessage(), e);
      deleteSharedTenantFile(config.tenantFilePath());
      throw new RuntimeException("Failed to initialize shared tenant", e);
    }
  }

  protected static void cleanupTenant(TenantConfig config, TenantContext context, String lastClassName) {
    if (SharedTenantOptions.isIgnoreCleanup()) {
      logger.info("cleanupTenant:: Ignoring cleanup for tenant for {}", context.ownerClass().getSimpleName());
      return;
    }
    if (SharedTenantOptions.isIndividualRunMode()) {
      try {
        logger.info("cleanupTenant:: Cleaning up individual tenant for {}", context.ownerClass().getSimpleName());
        context.featureRunner().accept(DESTROY_FEATURE_PATH);

        return;
      } finally {
        deleteSharedTenantFile(config.tenantFilePath());
      }
    }

    var callingClassName = context.ownerClass() != null ? context.ownerClass().getName() : null;
    if (lastClassName.equals(callingClassName)) {
      logger.info("cleanupTenant:: Cleaning up shared tenant (Last class: {})", callingClassName);
      try {
        context.featureRunner().accept(DESTROY_FEATURE_PATH);
        logger.info("cleanupTenant:: Successfully cleaned up tenant data");
      } catch (Exception e) {
        logger.error("cleanupTenant:: Failed to cleanup tenant data: {}", e.getMessage(), e);
      } finally {
        deleteSharedTenantFile(config.tenantFilePath());
        logger.info("cleanupTenant:: Deletion of shared tenant file completed");
      }
    } else {
      logger.info("cleanupTenant:: Skipping cleanup, tenant will be reused (Current class: {}, Last class: {})", callingClassName, lastClassName);
    }
  }

  private static boolean getOrCreateSharedTenant(String tenantPrefix, Class<?> ownerClass, String tenantFilePath) {
    synchronized (FILE_LOCK) {
      try {
        var tenantFile = new File(tenantFilePath);
        if (tenantFile.exists()) {
          var props = loadTenantProperties(tenantFile);
          var existingTenant = props.getProperty(TEST_TENANT);
          var existingTenantId = props.getProperty(TEST_TENANT_ID);
          var existingOwner = props.getProperty(OWNER);
          if (existingTenant != null && existingTenantId != null) {
            System.setProperty(TEST_TENANT, existingTenant);
            System.setProperty(TEST_TENANT_ID, existingTenantId);
            logger.info("getOrCreateSharedTenant:: Reusing tenant {} (created by {}) for {}", existingTenant, existingOwner, ownerClass.getSimpleName());

            return false;
          }
        }

        var tenant = SharedTenantOptions.getTenant(tenantPrefix);
        var ownerName = ownerClass.getSimpleName();
        saveTenantProperties(tenantFile, tenant.name(), tenant.id(), ownerName);
        System.setProperty(TEST_TENANT, tenant.name());
        System.setProperty(TEST_TENANT_ID, tenant.id());
        logger.info("getOrCreateSharedTenant:: Created shared tenant {} by {}", tenant.name(), ownerName);

        return true;
      } catch (Exception e) {
        logger.error("getOrCreateSharedTenant:: Failed to create/retrieve tenant: {}", e.getMessage(), e);
        deleteSharedTenantFile(tenantFilePath);
        throw new RuntimeException("Failed to initialize shared tenant", e);
      }
    }
  }

  private static Properties loadTenantProperties(File file) {
    var props = new Properties();
    try (var fis = new FileInputStream(file)) {
      props.load(fis);
    } catch (IOException e) {
      logger.warn("loadTenantProperties:: Failed to load tenant properties from {}: {}", file.getAbsolutePath(), e.getMessage());
    }

    return props;
  }

  private static void saveTenantProperties(File file, String tenant, String tenantId, String owner) {
    var props = new Properties();
    props.setProperty(TEST_TENANT, tenant);
    props.setProperty(TEST_TENANT_ID, tenantId);
    props.setProperty(OWNER, owner);
    try {
      Files.createDirectories(Paths.get(file.getParent()));
      try (var fos = new FileOutputStream(file)) {
        props.store(fos, "Shared tenant information");
      }
    } catch (IOException e) {
      logger.error("Failed to save tenant properties to {}: {}", file.getAbsolutePath(), e.getMessage());
    }
  }

  private static void deleteSharedTenantFile(String tenantFilePath) {
    synchronized (FILE_LOCK) {
      var tenantFile = new File(tenantFilePath);
      if (tenantFile.exists()) {
        try {
          Files.delete(tenantFile.toPath());
          logger.info("deleteSharedTenantFile:: Deleted shared tenant file: {}", tenantFilePath);
        } catch (IOException e) {
          logger.warn("deleteSharedTenantFile:: Failed to delete tenant file {}: {}", tenantFilePath, e.getMessage());
        }
      }
    }
  }
}

