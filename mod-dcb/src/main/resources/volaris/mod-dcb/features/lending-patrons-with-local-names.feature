Feature: Lender role with virtual patron information

  Background:
    * url baseUrl
    * def proxyCall = karate.get('proxyCall', false)
    * def user = proxyCall == true ? testUser : testAdmin
    * print 'user  is', user
    * callonce login user
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def key = ''
    * configure headers = headersUser
    * callonce read('classpath:volaris/mod-dcb/global/variables.feature')
    * def payloadGeneratorFeatureName = 'classpath:volaris/mod-dcb/reusable/generate-dcb-transaction.feature@CreateLenderPayloadWithLocalNames'
    * def virtualPatronId = uuid1()
    * def virtualPatronBarcode = 'dcb_patron_' + random_string()

  @createTransactionWithSingleValueInLocalNames
  Scenario: Create DCB Transaction with patron.localNames: Last Name
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def args = { localNames: '[TestLastName]' }
    * def response = call read(payloadGeneratorFeatureName) args
    * def payload = response.dcbTransaction
    * def transactionId = response.randomTransactionId

    * def orgPath = '/transactions/' + transactionId
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request payload
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == payload.item.id
    And match $.patron.id == payload.patron.id

    Given path '/users/' + payload.patron.id
    When method GET
    Then status 200
    And match $.barcode == payload.patron.barcode
    And match $.type == 'dcb'
    And match $.personal.firstName == "#notpresent"
    And match $.personal.middleName == "#notpresent"
    And match $.personal.lastName == 'TestLastName'

  @createTransactionWithTwoValueInLocalNames
  Scenario: Create DCB Transaction with patron.localNames: First Name + Last Name
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def args = { localNames: '[TestFirstName, TestLastName]' }
    * def response = call read(payloadGeneratorFeatureName) args
    * def payload = response.dcbTransaction
    * def transactionId = response.randomTransactionId

    * def orgPath = '/transactions/' + transactionId
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request payload
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == payload.item.id
    And match $.patron.id == payload.patron.id

    Given path '/users/' + payload.patron.id
    When method GET
    Then status 200
    And match $.barcode == payload.patron.barcode
    And match $.type == 'dcb'
    And match $.personal.firstName == 'TestFirstName'
    And match $.personal.middleName == "#notpresent"
    And match $.personal.lastName == 'TestLastName'

  @createTransactionWithThreeValuesInLocalNames
  Scenario: Create DCB Transaction with patron.localNames: First Name + Middle Name + Last Name
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def args = { localNames: '[TestFirstName, TestMiddleName, TestLastName]' }
    * def response = call read(payloadGeneratorFeatureName) args

    * def payload = response.dcbTransaction
    * def transactionId = response.randomTransactionId
    * payload.patron.id = virtualPatronId
    * payload.patron.barcode = virtualPatronBarcode

    * def orgPath = '/transactions/' + transactionId
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request payload
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == payload.item.id
    And match $.patron.id == virtualPatronId
    And match $.patron.barcode == virtualPatronBarcode

    Given path '/users/' + virtualPatronId
    When method GET
    Then status 200
    And match $.barcode == virtualPatronBarcode
    And match $.type == 'dcb'
    And match $.personal.firstName == 'TestFirstName'
    And match $.personal.middleName == 'TestMiddleName'
    And match $.personal.lastName == 'TestLastName'

  @updatePatronPersonalDataByCreatingNewTransaction
  Scenario: Create DCB Transaction with new patron.localNames for previous patron
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def args = { localNames: '[NewFirstName, NewMiddleName, NewLastName]' }
    * def dcbTransaction = call read(payloadGeneratorFeatureName) args

    * def payload = dcbTransaction.dcbTransaction
    * def transactionId = dcbTransaction.randomTransactionId
    * payload.patron.id = virtualPatronId
    * payload.patron.barcode = virtualPatronBarcode

    * def orgPath = '/transactions/' + transactionId
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request payload
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == payload.item.id
    And match $.patron.id == virtualPatronId
    And match $.patron.barcode == virtualPatronBarcode

    Given path '/users/' + virtualPatronId
    When method GET
    Then status 200
    And match $.barcode == virtualPatronBarcode
    And match $.type == 'dcb'
    And match $.personal.firstName == 'NewFirstName'
    And match $.personal.middleName == 'NewMiddleName'
    And match $.personal.lastName == 'NewLastName'
