Feature: create instance

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    Scenario: create instance and holdings record
      * def instance = read('samples/instance-entity.json')
      * def holdingsRecord = read('samples/holdings-record-entity.json')
      * def instanceType = read('samples/instance-type-entity.json')
      * instance.instanceTypeId = instanceType.id

      Given path 'instance-types'
      And request instanceType
      When method POST
      Then status 201

      Given path 'inventory/instances'
      And request instance
      When method POST
      Then status 201

      Given path '/holdings-storage/holdings/holdingsRecords'
      And request holdingsRecord
      When method POST
      Then status 201
