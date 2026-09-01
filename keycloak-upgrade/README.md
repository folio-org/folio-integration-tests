# Keycloak Upgrade Integration Tests

This test verifies that data created with the previous Keycloak image still works after installing a newer `folio-keycloak` image.

The test is split into two runners because the Keycloak container must be replaced between phases while preserving the Keycloak database.

## Run

When no state file exists, the seed phase generates a random tenant name and id, then writes them to `target/keycloak-upgrade-tenant.properties`. The verify phase reads the same file.

If the seed phase fails after tenant creation, remove `target/keycloak-upgrade-tenant.properties` to generate a new tenant, or clean up the failed tenant before rerunning the seed phase.

Start the environment with the old Keycloak image, then seed upgrade data:

```shell
mvn clean test -pl common,testrail-integration,keycloak-upgrade \
  -DfailIfNoTests=false \
  -Dsurefire.failIfNoSpecifiedTests=false \
  -Dtest=KeycloakUpgradeSeedTests \
  -DargLine="-Dkarate.env=eureka2"
```

Restart Keycloak with the upgraded image against the same database, wait for Keycloak and Kong to become ready, then verify:

```shell
mvn test -pl common,testrail-integration,keycloak-upgrade \
  -DfailIfNoTests=false \
  -Dsurefire.failIfNoSpecifiedTests=false \
  -Dtest=KeycloakUpgradeVerifyTests \
  -DargLine="-Dkarate.env=eureka2"
```

To use an explicit state file location, add `-Dkeycloak.upgrade.stateFile=/path/to/keycloak-upgrade-tenant.properties` to both `argLine` values.

To use an explicit tenant instead of the generated one, add both `-DtestTenant=<tenant>` and `-DtestTenantId=<uuid>` to the seed command. The seed phase still writes them to the state file for the verify command.

## What It Covers

- Tenant authentication state survives the Keycloak restart.
- Existing FOLIO user and credentials still work.
- Login, refresh, user lookup, and effective permission resolution still work through FOLIO APIs.
- FOLIO-issued tokens still contain the expected `sub`, `user_id`, and client claims.
- Tenant metadata can still be updated through the FOLIO tenant manager API.
- Role/capability assignments created before the upgrade still resolve after the upgrade.
- The verify phase cleans up the generated tenant after a successful run.
