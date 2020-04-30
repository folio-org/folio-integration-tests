# Folio-Integration-Tests

## introduction
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

To run only specific test use `-Dtest=<TestName>` on localhost 
```
mvn test -Dtest=FinanceApiTest
```

Also possible to run integration tests trough IDE by:
- Any test runner like FinanceApiTest
- Directly from root feature file resources/domain/mod-orders/orders.feature
- A specific scenario if it contains all available variable as in above example

## Folder structure
```
├── src
│   ├── main
│   │   ├── java
│   │   └── resources
│   │       ├── common
│   │       │   ├── destroy-data.feature
│   │       │   ├── dev.feature
│   │       │   ├── global-finances.feature
│   │       │   ├── global-inventory.feature
│   │       │   ├── global-organizations.feature
│   │       │   ├── login.feature
│   │       │   ├── module.feature
│   │       │   ├── setup-users.feature
│   │       │   └── tenant.feature
│   │       ├── domain
│   │       │   ├── mod-finance
│   │       │   │   ├── cases
│   │       │   │   │   └── transactions.feature
│   │       │   │   └── finance.feature
│   │       │   └── mod-orders
│   │       │       ├── cases
│   │       │       │   └── composite-orders.feature
│   │       │       └── orders.feature
│   │       ├── examples
│   │       │   └── simple-data-driven.feature
│   │       ├── karate-config.js
│   │       └── samples
│   │           └── mod-orders 
│   │               └── order-line.json
│   └── test/java/org/folio 
│                   ├── FinanceApiTest.java
│                   ├── OrdersApiTest.java
│                   └── TestUtils.java
```
- src/main/java - folder for reusable java code or utils methods
- src/main/resources/common - folder for reusable feature files
- src/main/resources/domain - folder with domain specific integration tests
- src/main/resources/examples - folder with karate examples
- src/main/resources/karate-config.js - karate configuration file applicable for all feature files
- src/main/resources/samples - folder with domain specific reusable files like request data
- test/java/org/folio - folder with Test runners 

## Resources
- [Karate repository](https://github.com/intuit/karate)
- [Karate documentation](https://intuit.github.io/karate)
- [Karate examples](https://github.com/intuit/karate/tree/master/karate-demo)
