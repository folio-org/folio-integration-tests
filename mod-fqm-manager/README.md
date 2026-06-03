# mod-fqm-manager tests

## Running tagged tests

`ModFqmManagerTest` uses the standard Karate tag support from `karate.options`.
When running one scenario tag, include the mod-fqm-manager setup and teardown tags in the same tag list so the tenant, permissions, sample data, and cleanup still run.

Lifecycle tags:

* `@FqmManagerSetup` - runs `fqm-junit.feature` before the test scenarios
* `@FqmManagerTeardown` - runs the mod-fqm-manager cleanup wrapper after the test scenarios

Example for TestRail case `@C831957` on snapshot:

```sh
mvn test -pl common,testrail-integration,mod-fqm-manager \
  -Dkarate.env=snapshot \
  "-Dkarate.options=--tags @FqmManagerSetup,@C831957,@FqmManagerTeardown"
```

Keep the `karate.options` value quoted because it contains spaces. To run a different tagged scenario, replace `@C831957` with the desired tag and keep `@FqmManagerSetup` and `@FqmManagerTeardown` in the list.
