@parallel=false
Feature: mod-audit integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                     |
      | 'mod-audit'                              |

    * table adminAdditionalPermissions
      | name                                     |

    * table userPermissions
      | name                                     |
      | 'audit.all'                              |

  Scenario: create tenant and users for testing
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }

  Scenario: Order Event
    Given call read('features/orderEvent.feature')

  Scenario: OrderLine Event
    Given call read('features/orderLineEvent.feature')
