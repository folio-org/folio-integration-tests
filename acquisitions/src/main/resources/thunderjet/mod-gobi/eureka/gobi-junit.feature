Feature: mod-gobi integration tests

  Background:
    * url baseUrl
    * def requiredApplications = ['app-acquisitions', 'app-platform-complete', 'app-platform-minimal', 'app-fqm', 'app-consortia']

    * table userPermissions
      | name |
      | 'acquisitions-units.memberships.item.delete' |
      | 'acquisitions-units.memberships.item.post' |
      | 'acquisitions-units.units.item.post' |
      | 'acquisitions-units-storage.memberships.collection.get' |
      | 'acquisitions-units-storage.memberships.item.put' |
      | 'acquisitions-units-storage.memberships.item.delete' |
      | 'acquisitions-units-storage.memberships.item.post' |
      | 'acquisitions-units-storage.units.item.get' |
      | 'acquisitions-units-storage.units.item.post' |
      | 'acquisitions-units-storage.units.item.put' |
      | 'acquisitions-units-storage.units.item.delete' |
      | 'configuration.entries.collection.get' |
      | 'configuration.entries.item.delete' |
      | 'configuration.entries.item.post' |
      | 'configuration.entries.item.put' |
      | 'finance.budgets.collection.get' |
      | 'finance.budgets.item.delete' |
      | 'finance.budgets.item.get' |
      | 'finance.budgets.item.post' |
      | 'finance.budgets.item.put' |
      | 'finance.budgets-expense-classes-totals.collection.get' |
      | 'finance.expense-classes.item.post' |
      | 'finance.ledger-rollovers-budgets.item.get' |
      | 'finance.funds.budget.item.get' |
      | 'finance.finance-data.collection.get' |
      | 'finance.fiscal-years.item.delete' |
      | 'finance.fiscal-years.item.get' |
      | 'finance.fiscal-years.item.post' |
      | 'finance.fiscal-years.item.put' |
      | 'finance.fund-types.item.post' |
      | 'finance.funds.collection.get' |
      | 'finance.funds.item.get' |
      | 'finance.funds.item.put' |
      | 'finance.groups-expense-classes-totals.collection.get' |
      | 'finance.groups-expense-classes-totals.collection.post' |
      | 'finance.groups.item.post' |
      | 'finance.group-fiscal-year-summaries.collection.get' |
      | 'finance.group-fiscal-year-summaries.collection.post' |
      | 'finance.group-fund-fiscal-years.item.post' |
      | 'finance.ledger-rollovers-budgets.collection.get' |
      | 'finance.ledger-rollovers-budgets.item.get' |
      | 'finance.ledger-rollovers-errors.collection.get' |
      | 'finance.ledger-rollovers-logs.collection.get' |
      | 'finance.ledger-rollovers-logs.item.get' |
      | 'finance.ledger-rollovers.item.post' |
      | 'finance.ledger-rollovers-progress.collection.get' |
      | 'finance.ledger-rollovers-progress.item.put' |
      | 'finance.ledgers.current-fiscal-year.item.get' |
      | 'finance.ledgers.collection.get' |
      | 'finance.ledgers.item.delete' |
      | 'finance.ledgers.item.get' |
      | 'finance.ledgers.item.post' |
      | 'finance.release-encumbrance.item.post' |
      | 'finance.transactions.batch.execute' |
      | 'finance.transactions.collection.get' |
      | 'finance.transactions.item.delete' |
      | 'finance.transactions.item.get' |
      | 'finance-storage.budget-expense-classes.collection.get' |
      | 'finance-storage.budget-expense-classes.item.post' |
      | 'finance-storage.group-fund-fiscal-years.item.post' |
      | 'finance-storage.budgets.item.post' |
      | 'finance-storage.funds.item.delete' |
      | 'finance-storage.funds.item.post' |
      | 'finance-storage.budgets.item.get' |
      | 'finance-storage.group-fund-fiscal-years.collection.get' |
      | 'finance-storage.ledger-rollovers-errors.collection.get' |
      | 'finance-storage.ledger-rollovers.item.delete' |
      | 'finance-storage.ledgers.item.post' |
      | 'finance-storage.transactions.batch.execute' |
      | 'finance-storage.transactions.collection.get' |
      | 'finance.finance-data.collection.put' |
      | 'inventory-storage.contributor-name-types.item.post' |
      | 'inventory-storage.electronic-access-relationships.item.post' |
      | 'inventory-storage.holdings-sources.item.post' |
      | 'inventory-storage.holdings.item.post' |
      | 'inventory-storage.identifier-types.item.post' |
      | 'inventory-storage.instance-statuses.item.post' |
      | 'inventory-storage.instance-types.item.post' |
      | 'inventory-storage.loan-types.item.post' |
      | 'inventory-storage.location-units.campuses.item.post' |
      | 'inventory-storage.location-units.institutions.item.post' |
      | 'inventory-storage.location-units.libraries.item.post' |
      | 'inventory-storage.locations.item.post' |
      | 'inventory-storage.material-types.item.post' |
      | 'inventory-storage.service-points.item.post' |
      | 'inventory.instances.item.post' |
      | 'invoice.invoices.item.get' |
      | 'invoice.invoice-lines.item.post' |
      | 'invoice.invoices.item.post' |
      | 'invoice.invoices.item.put' |
      | 'organizations-storage.organizations.item.post' |
      | 'organizations.organizations.item.get' |
      | 'organizations.organizations.item.post' |
      | 'organizations.organizations.item.put' |
      | 'gobi.validate.item.get' |
      | 'gobi.orders.item.post' |
      | 'gobi.custom-mappings.collection.post' |
      | 'gobi.custom-mappings.collection.get' |
      | 'gobi.custom-mappings.item.get' |
      | 'gobi.custom-mappings.item.post' |
      | 'gobi.custom-mappings.item.put' |
      | 'gobi.validate.item.post' |
      | 'gobi.custom-mappings.item.delete' |
      | 'orders.collection.get' |
      | 'orders.po-lines.collection.get' |
      | 'inventory-storage.holdings.collection.get' |


    # Test tenant name creation:
    * def random = callonce randomMillis
    * def testTenant = 'testmodgobi' + random
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

  Scenario: Create tenant and users for testing
    # Create tenant and users for testing:
    * def testUser = testAdmin
    * call read('classpath:common/eureka/setup-users.feature')

  Scenario: init global data
    * call login testAdmin
    * callonce variables

    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/organizations.feature')

  Scenario: GOBI api tests
    Given call read('features/gobi-api-tests.feature')

  Scenario: Find holdings by location and instance
    Given call read('features/find-holdings-by-location-and-instance.feature')

  Scenario: Wipe data
    Given call read('classpath:common/eureka/destroy-data.feature')
