Feature: Util for hrid in mod-inventory consortia api tests

  Background:
    * url baseUrl
    * configure retry = { count: 20, interval: 40000 }

  @UpdateHrId
  Scenario: Update hrId settings
    * def tenant = karate.get('tenant')
    * def prefix = karate.get('prefix')

    * def instancePrefix = prefix + 'in'
    * def holdingsPrefix = prefix + 'ho'
    * def itemPrefix = prefix + 'it'

    Given path 'hrid-settings-storage/hrid-settings'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = tenant
    And request
     """
     {
       "instances": {
         "prefix": '#(instancePrefix)',
         "startNumber": 1,
         "currentNumber": 0
       },
       "holdings": {
         "prefix": '#(holdingsPrefix)',
         "startNumber": 1,
         "currentNumber": 0
       },
       "items": {
         "prefix": '#(itemPrefix)',
         "startNumber": 1,
         "currentNumber": 0
       },
       "commonRetainLeadingZeroes": true
     }
     """
    When method PUT
    Then status 204