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
    if (isIndividualRunMode()) {
      var uniqueTenant = config.tenantPrefix() + RandomUtils.nextLong();
      var uniqueTenantId = UUID.randomUUID().toString();
      System.setProperty(TEST_TENANT, uniqueTenant);
      System.setProperty(TEST_TENANT_ID, uniqueTenantId);
      logger.info("initializeTenant:: Created unique tenant (Individual mode) {} for {}", uniqueTenant, context.ownerClass().getSimpleName());
      try {
        context.featureRunner().accept(config.initFeaturePath());

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
    if (isIndividualRunMode()) {
      logger.info("cleanupTenant:: Cleaning up individual tenant for {}", context.ownerClass().getSimpleName());
      context.featureRunner().accept(DESTROY_FEATURE_PATH);

      return;
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


  private static boolean isIndividualRunMode() {
    // To run tests in efficient "shared pool and tenant" mode -Dtest.mode=no-shared-pool VM option should NOT be set
    // because this mode is enabled by default for the nightly Karate CI runs. We can mimic the CI behavior locally
    // by setting -Dkarate.env=dev-shared. But if you explicitly want "shared pool and tenant" activity to be disabled
    // do NOT use either -Dtest.mode=no-shared-pool OR -Dkarate.env=dev-shared
    var disableSharedPoolAndTenantWithNoSharedPool = "no-shared-pool".equals(System.getProperty("test.mode"));

    // To run tests individually without "shared pool and tenant" mode set -Dkarate.env=dev VM option
    // to run the tests the "old-school way" locally with newly created thread pools and tenant per feature
    var disableSharedPoolAndTenantWithKarateEnv = "dev".equals(System.getProperty("karate.env"));

    return disableSharedPoolAndTenantWithNoSharedPool || disableSharedPoolAndTenantWithKarateEnv;
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
            logger.info("getOrCreateSharedTenant:: Reusing tenant (Shared mode) {} (created by {}) for {}", existingTenant, existingOwner, ownerClass.getSimpleName());

            return false;
          }
        }

        var newTenant = tenantPrefix + RandomUtils.nextLong();
        var newTenantId = UUID.randomUUID().toString();
        var ownerName = ownerClass.getSimpleName();
        saveTenantProperties(tenantFile, newTenant, newTenantId, ownerName);
        System.setProperty(TEST_TENANT, newTenant);
        System.setProperty(TEST_TENANT_ID, newTenantId);
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

