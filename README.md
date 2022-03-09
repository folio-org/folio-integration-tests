# Folio-Integration-Tests

Copyright (C) 2020-2021 The Open Library Foundation

This software is distributed under the terms of the Apache License,
Version 2.0. See the file "[LICENSE](LICENSE)" for more information.

## Introduction
This project is the set of integration tests based on [karate framework](https://github.com/karatelabs/karate)
## Running integration tests

To run all existing API tests on localhost
```
mvn test
```

To run all existing API tests on [testing environment](https://folio-testing-okapi.dev.folio.org:443)
```
mvn test -DargLine="-Dkarate.env=testing"
```

To run all existing API tests on [snapshot environment](https://folio-snapshot-okapi.dev.folio.org:443)
```
mvn test -DargLine="-Dkarate.env=snapshot"
```

To run only specific submodule use `-pl common,<submodule_name>` on localhost
```
mvn test -pl common,poc
```

This first builds the common submodule and stores it into the ~/.m2 directory so that poc can use it.

To run only specific test use `-Dtest=<TestName>` and `-pl common,<submodule_name>` on localhost
```
mvn test -Dtest=FinanceApiTest -pl common,poc
```

To run specific feature from IDEA
```
  1. Create runner class (Example : org.folio.OrdersApiTest)
  2. Set environment variable in configuration : karate.env=snapshot
```
  


Also possible to run integration tests trough IDE by:
- Any test runner like FinanceApiTest
- Directly from root feature file resources/domain/mod-orders/orders.feature
- A specific scenario if it contains all available variable as in above example

## Folder structure
```
├── FolioModuleName1
├── FolioModuleNameN
├── common
│    └── src
│      └── main
│        ├── java
│        └── resources
│             └── common
│                ├── destroy-data.feature
│                ├── dev.feature
│                ├── login.feature
│                ├── module.feature
│                ├── setup-users.feature
│                └── tenant.feature
└── poc
    └── src
      └── main
      │   ├── java
      │   └── resources
      │       ├── common
      │       │   ├── global-finances.feature
      │       │   ├── global-inventory.feature
      │       │   ├── global-organizations.feature
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
- common - module for reusable features
- PoC/src/main/java - folder for reusable java code or utils methods
- PoC/src/main/resources/common - folder for reusable feature files
- PoC/src/main/resources/domain - folder with domain specific integration tests
- PoC/src/main/resources/examples - folder with karate examples
- PoC/src/main/resources/karate-config.js - karate configuration file applicable for all feature files
- PoC/src/main/resources/samples - folder with domain specific reusable files like request data
- PoC/test/java/org/folio - folder with Test runners 

> To add Integration tests for a Folio module, create a directory with the module name at the root of this repo and put the tests under it (feel free to use the same directory structure for the module as specified for PoC) and update root pom.xml with new submodule.

> To reuse features from the common module you should update pom.xml with dependency below. All features will be located in classpath.
```xml
<dependencies>
    <dependency>
        <groupId>org.folio</groupId>
        <artifactId>common</artifactId>
        <version>1.0-SNAPSHOT</version>
    </dependency>
</dependencies>
```

## Running tests for a specific module in a specific environment
```
sh ./runtests.sh ${PROJECT} ${ENVIRONMENT}
For example, 
sh ./runtests.sh mod-oai-pmh snapshot
``` 

To build common run
```
sh ./runtests.sh common
```
before any other module.

* Supported values for project are module names from root pom.xml
* Supported values for environment depend on `karate-config.js` in the corresponding module. 
For example:

| Environment                               |
| ----------------------------------------- |
| snapshot                                  |
| snapshot-2                                |
| Any supported value in karate.config      |

## Running tests in rancher 
* Create a secret called `integration-tests`
* Set up secret values: `environment` and `propject`. 
* Then in rancher pipeline in runscript step specify 
```
sh ./runtests.sh ${PROJECT} ${ENVIRONMENT}
```

Run with PROJECT=common before any other module to build common.

## Resources
- [Karate repository](https://github.com/karatelabs/karate)
- [Karate documentation](https://karatelabs.github.io/karate/)
- [Karate examples](https://github.com/karatelabs/karate/tree/master/karate-demo)

## Project Setup to test via Vagrant overall roadmap

- Add permissions to user. 

    The list of permissions should include: 
    okapi.proxy.modules.", okapi.proxy.pull.", okapi.proxy.tenants.", okapi.proxi.", 
    okapi.env, okapi.env.", okapi.modules, okapi.deployment.", okapi.all, okapi.deploy, 
    okapi.tenants, okapi.tenantmodules, users.item.".

"- includes inner permissions; 

- Get userId

    Get permissionId using the userId

    Assign permissionId to userId

    The logic should be used within karate-config.js


- Change proper configuration file line about karate.env to line equals to:
var env = karate.env ? karate.env : 'local';
