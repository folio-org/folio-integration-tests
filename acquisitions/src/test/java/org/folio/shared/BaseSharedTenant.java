package org.folio.shared;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Properties;
import java.util.UUID;
import java.util.function.Consumer;

import org.apache.commons.lang3.RandomUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class BaseSharedTenant {

  private static final Logger logger = LoggerFactory.getLogger(BaseSharedTenant.class);
  private static final Object FILE_LOCK = new Object();
  private static final String DESTROY_FEATURE_PATH = "classpath:common/eureka/destroy-data.feature";

  protected record TenantConfig(String tenantPrefix, String initFeaturePath, String tenantFilePath) {}
  protected record TenantContext(Class<?> ownerClass, Consumer<String> featureRunner) {}

  protected BaseSharedTenant() {
  }

  protected static boolean initializeTenant(TenantConfig config, TenantContext context) {
    if (isIndividualRunMode()) {
      var uniqueTenant = config.tenantPrefix() + RandomUtils.nextLong();
      var uniqueTenantId = UUID.randomUUID().toString();
      System.setProperty("testTenant", uniqueTenant);
      System.setProperty("testTenantId", uniqueTenantId);
      logger.info("initializeTenant:: Created unique tenant (Individual mode) {} for {}", uniqueTenant, context.ownerClass().getSimpleName());
      context.featureRunner().accept(config.initFeaturePath());

      return true;
    } else {
      var createdTenant = getOrCreateSharedTenant(config.tenantPrefix(), context.ownerClass(), config.tenantFilePath());
      if (createdTenant) {
        context.featureRunner().accept(config.initFeaturePath());
      }

      return createdTenant;
    }
  }

  protected static void cleanupTenant(boolean createdTenant, TenantConfig config, TenantContext context, String lastClassName) {
    if (isIndividualRunMode()) {
      context.featureRunner().accept(DESTROY_FEATURE_PATH);
    } else if (createdTenant) {
      if (isLastClass(lastClassName)) {
        logger.info("cleanupTenant:: Cleaning up shared tenant (Last class)");
        context.featureRunner().accept(DESTROY_FEATURE_PATH);
        deleteSharedTenantFile(config.tenantFilePath());
      } else {
        logger.info("cleanupTenant:: Skipping cleanup, tenant will be reused (Not last class)");
      }
    }
  }

  private static boolean isIndividualRunMode() {
    return "no-shared-pool".equals(System.getProperty("test.mode"));
  }

  private static boolean getOrCreateSharedTenant(String tenantPrefix, Class<?> ownerClass, String tenantFilePath) {
    synchronized (FILE_LOCK) {
      try {
        var tenantFile = new File(tenantFilePath);
        if (tenantFile.exists()) {
          var props = loadTenantProperties(tenantFile);
          var existingTenant = props.getProperty("tenant");
          var existingTenantId = props.getProperty("tenantId");
          var existingOwner = props.getProperty("owner");
          if (existingTenant != null && existingTenantId != null) {
            System.setProperty("testTenant", existingTenant);
            System.setProperty("testTenantId", existingTenantId);
            logger.info("getOrCreateSharedTenant:: Reusing tenant (Shared mode) {} (created by {}) for {}", existingTenant, existingOwner, ownerClass.getSimpleName());
            return false;
          }
        }

        var newTenant = tenantPrefix + RandomUtils.nextLong();
        var newTenantId = UUID.randomUUID().toString();
        var ownerName = ownerClass.getSimpleName();
        saveTenantProperties(tenantFile, newTenant, newTenantId, ownerName);
        System.setProperty("testTenant", newTenant);
        System.setProperty("testTenantId", newTenantId);
        logger.info("getOrCreateSharedTenant:: Shared mode: Created shared tenant {} by {}", newTenant, ownerName);

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
    props.setProperty("tenant", tenant);
    props.setProperty("tenantId", tenantId);
    props.setProperty("owner", owner);
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

  private static boolean isLastClass(String lastClassName) {
    var stackTrace = Thread.currentThread().getStackTrace();
    for (var element : stackTrace) {
      var className = element.getClassName();
      if (className.equals(lastClassName)) {
        return true;
      }
    }

    return false;
  }
}

