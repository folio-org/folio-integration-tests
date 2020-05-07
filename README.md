# Folio-Integration-Tests

## Introduction
This project is the set of integration tests based on [karate framework](https://github.com/intuit/karate)
## Running integration tests

To run all existing API tests on localhost
```
mvn test
```

To run all existing API tests on [testing environment](https://folio-testing-okapi.aws.indexdata.com:443)
```
mvn test -DargLine="-Dkarate.env=testing"
```

To run all existing API tests on [snapshot environment](https://folio-snapshot-okapi.aws.indexdata.com:443)
```
mvn test -DargLine="-Dkarate.env=snapshot"
```

To run only specific test use `-Dtest=<TestName>` and `-pl <submodule_name>` on localhost 
```
mvn test -Dtest=FinanceApiTest -pl poc
```

Also possible to run integration tests trough IDE by:
- Any test runner like FinanceApiTest
- Directly from root feature file resources/domain/mod-orders/orders.feature
- A specific scenario if it contains all available variable as in above example

## Folder structure
```
├── FolioModuleName1
├── FolioModuleNameN
└── poc
    └── src
      └── main
      │   ├── java
      │   └── resources
      │       ├── common
      │       │   ├── destroy-data.feature
      │       │   ├── dev.feature
      │       │   ├── global-finances.feature
      │       │   ├── global-inventory.feature
      │       │   ├── global-organizations.feature
      │       │   ├── login.feature
      │       │   ├── module.feature
      │       │   ├── setup-users.feature
      │       │   └── tenant.feature
      │       ├── domain
      │       │   ├── mod-finance
      │       │   │   ├── cases
      │       │   │   │   └── transactions.feature
      │       │   │   └── finance.feature
      │       │   └── mod-orders
      │       │       ├── cases
      │       │       │   └── composite-orders.feature
      │       │       └── orders.feature
      │       ├── examples
      │       │   ├── crud.feature
      │       │   └── simple-data-driven.feature
      │       ├── karate-config.js
      │       ├── logback-test.xml
      │       └── samples
      │           └── mod-orders
      │               └── order-line.json
      └── test
          └── java
              └── org
                 └── folio
                      ├── FinanceApiTest.java
                      ├── OrdersApiTest.java
                      └── TestUtils.java
```
- FolioModuleName1,N - placeholders for future modules
- PoC/src/main/java - folder for reusable java code or utils methods
- PoC/src/main/resources/common - folder for reusable feature files
- PoC/src/main/resources/domain - folder with domain specific integration tests
- PoC/src/main/resources/examples - folder with karate examples
- PoC/src/main/resources/karate-config.js - karate configuration file applicable for all feature files
- PoC/src/main/resources/samples - folder with domain specific reusable files like request data
- PoC/test/java/org/folio - folder with Test runners 

> To add Integration tests for a Folio module, create a directory with the module name at the root of this repo and put the tests under it (feel free to use the same directory structure for the module as specified for PoC) and update root pom.xml with new submodule.

## Resources
- [Karate repository](https://github.com/intuit/karate)
- [Karate documentation](https://intuit.github.io/karate)
- [Karate examples](https://github.com/intuit/karate/tree/master/karate-demo)
