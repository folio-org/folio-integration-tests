Feature: init data for mod-inventory-storage

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  @Init
  Scenario: init data
    * def instance = read('samples/instance-entity.json')
    * def holdingsRecord = read('samples/holdings-record-entity.json')
    * def instanceType = read('samples/instance-type-entity.json')
    * def location = read('samples/location-entity.json')
    * def institution = read('samples/institution-entity.json')
    * def campus = read('samples/campus-entity.json')
    * def library = read('samples/library-entity.json')
    * def loanTypes = read('samples/loan-type-entity.json')
    * def circulationRules = read('samples/circulation-rules-entity.json')
    * def loanPolicy = read('samples/loan-policy-entity.json')
    * def overdueFinePolicy = read('samples/overdue-fine-policy-entity.json')
    * def lostItemFeePolicy = read('samples/lost-item-fee-policy-entity.json')
    * def requestPolicy = read('samples/request-policy-entity.json')
    * def patronNoticePolicy = read('samples/patron-notice-policy-entity.json')
    * def servicePoint = read('samples/service-point-entity.json')
    * instance.instanceTypeId = instanceType.id
    * instance.instanceTypeId = instanceType.id

    Given path 'service-points'
    And request servicePoint
    When method POST
    Then status 201
    
    Given path 'loan-policy-storage/loan-policies'
    And request loanPolicy
    When method POST
    Then status 201

    Given path 'overdue-fines-policies'
    And request overdueFinePolicy
    When method POST
    Then status 201

    Given path 'lost-item-fees-policies'
    And request lostItemFeePolicy
    When method POST
    Then status 201

    Given path 'request-policy-storage/request-policies'
    And request requestPolicy
    When method POST
    Then status 201

    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request patronNoticePolicy
    When method POST
    Then status 201

    Given path 'circulation-rules-storage'
    And request circulationRules
    When method PUT
    Then status 204

    Given path 'loan-types'
    And request loanTypes
    When method POST
    Then status 201

    Given path 'material-types'
    And request { name: 'book', id: '#(materialTypeId)'}
    When method POST
    Then status 201

    Given path 'location-units/institutions'
    And request institution
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request campus
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request library
    When method POST
    Then status 201

    Given path 'locations'
    And request location
    When method POST
    Then status 201

    Given path 'instance-types'
    And request instanceType
    When method POST
    Then status 201

    Given path 'inventory/instances'
    And request instance
    When method POST
    Then status 201

    Given path 'holdings-storage/holdings'
    And request holdingsRecord
    When method POST
    Then status 201

  @PutPatronBlockConditionById
  Scenario: put patron block condition
    * def req = read('samples/patron-block-condition-entity.json')
    * req.id = pbcId
    * req.name = pbcName
    * req.message = pbcMessage

    Given path 'patron-block-conditions/' + pbcId
    And request req
    When method PUT
    Then status 204

  @PostPatronBlocksLimitsByConditionId
  Scenario: post patron block limit by condition id
    Given path 'patron-block-limits'
    And request {id: '#(id)', patronGroupId: '#(patronGroupId)', conditionId: '#(pbcId)', value: '#(value)'}
    When method POST
    Then status 201

  @PutPatronBlocksLimitsByConditionId
  Scenario: put patron block limit by condition id
    Given path 'patron-block-limits/' + limitId
    And request {id: '#(id)', patronGroupId: '#(patronGroupId)', conditionId: '#(pbcId)', value: '#(value)'}
    When method PUT
    Then status 204