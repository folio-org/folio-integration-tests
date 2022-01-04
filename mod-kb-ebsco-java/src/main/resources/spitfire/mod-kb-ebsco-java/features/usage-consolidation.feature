Feature: Usage Consolidation

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }
    * def samplesPath = 'classpath:spitfire/mod-kb-ebsco-java/features/samples/usage-consolidation/'

    * def credentialId = karate.properties['credentialId']
    * def customerKeyAnonymized = '****************************************'

 #   ================= positive test cases =================

  Scenario: GET Usage Consolidation credentials with 200 on success
    Given path '/eholdings/uc-credentials'
    When method GET
    Then status 200
    And match responseType == 'json'
    And match response.attributes.isPresent == false

  Scenario: PUT Usage Consolidation credentials with 204 on success
    Given path '/eholdings/uc-credentials'
    And def requestEntity = read(samplesPath + 'ucCredentials.json')
    And request requestEntity
    When method PUT
    Then status 204

    Given path '/eholdings/uc-credentials'
    When method GET
    Then status 200
    And match responseType == 'json'
    And match response.attributes.isPresent == true

  Scenario: POST Usage Consolidation settings by KB credentials id with 201 on success
    Given path '/eholdings/kb-credentials', credentialId, 'uc'
    And def requestEntity = read(samplesPath + 'ucSettings.json')
    And request requestEntity
    When method POST
    Then status 201
    And match response.attributes.customerKey == customerKeyAnonymized
    And match response.attributes.startMonth == requestEntity.data.attributes.startMonth
    And match response.attributes.currency == requestEntity.data.attributes.currency
    And match response.attributes.platformType == requestEntity.data.attributes.platformType

  Scenario: GET Usage Consolidation settings by KB credentials id with 200 on success
    Given path '/eholdings/kb-credentials', credentialId, 'uc'
    And def requestEntity = read(samplesPath + 'ucSettings.json')
    When method GET
    Then status 200
    And match response.attributes.customerKey == customerKeyAnonymized
    And match response.attributes.startMonth == requestEntity.data.attributes.startMonth
    And match response.attributes.currency == requestEntity.data.attributes.currency
    And match response.attributes.platformType == requestEntity.data.attributes.platformType

  Scenario: PATCH Usage Consolidation settings by KB credentials id with 204 on success
    Given path '/eholdings/kb-credentials', credentialId, 'uc'
    And def requestEntity = read(samplesPath + 'ucSettings.json')
    And set requestEntity.data.attributes.startMonth = 'feb'
    And set requestEntity.data.attributes.currency = 'EUR'
    And request requestEntity
    When method PATCH
    Then status 204

    Given path '/eholdings/kb-credentials', credentialId, 'uc'
    When method GET
    Then status 200
    And match response.attributes.customerKey == customerKeyAnonymized
    And match response.attributes.startMonth == requestEntity.data.attributes.startMonth
    And match response.attributes.currency == requestEntity.data.attributes.currency
    And match response.attributes.platformType == requestEntity.data.attributes.platformType

  Scenario: GET Usage Consolidation settings customer key by KB credentials id with 200 on success
    Given path '/eholdings/kb-credentials', credentialId, 'uc/key'
    And def requestEntity = read(samplesPath + 'ucSettings.json')
    When method GET
    Then status 200
    And match response.attributes.credentialsId == credentialId
    And match response.attributes.customerKey == requestEntity.data.attributes.customerKey

  Scenario: GET Usage Consolidation settings with 200 on success
    Given path '/eholdings/uc'
    And def requestEntity = read(samplesPath + 'ucSettings.json')
    When method GET
    Then status 200
    And match response.attributes.customerKey == customerKeyAnonymized

#   ================= negative test cases =================

  Scenario: GET Usage Consolidation settings by KB credentials id should return 404 if no settings present
    Given path '/eholdings/kb-credentials', uuid(), 'uc'
    When method GET
    Then status 404

  Scenario: POST Usage Consolidation settings by KB credentials id should return 422 if no request data attributes provided
    Given path '/eholdings/kb-credentials', credentialId, 'uc'
    And def requestEntity = read(samplesPath + 'ucSettings.json')
    And remove requestEntity.data.attributes
    And request requestEntity
    When method POST
    Then status 422
    And match response.errors[0].message == 'must not be null'
    And match response.errors[0].parameters[0].key == 'data.attributes'

  Scenario: POST Usage Consolidation settings by KB credentials id should return 422 if no request data attributes currency provided
    Given path '/eholdings/kb-credentials', credentialId, 'uc'
    And def requestEntity = read(samplesPath + 'ucSettings.json')
    And remove requestEntity.data.attributes.currency
    And request requestEntity
    When method POST
    Then status 422
    And match response.errors[0].message == 'must not be null'
    And match response.errors[0].parameters[0].key == 'data.attributes.currency'

  Scenario: POST Usage Consolidation settings by KB credentials id should return 422 if empty request data attributes currency provided
    Given path '/eholdings/kb-credentials', credentialId, 'uc'
    And def requestEntity = read(samplesPath + 'ucSettings.json')
    And set requestEntity.data.attributes.currency = ''
    And request requestEntity
    When method POST
    Then status 422
    And match response.errors[0].title == 'Invalid value'

  Scenario: POST Usage Consolidation settings by KB credentials id should return 400 if invalid request data attributes startMonth provided
    Given path '/eholdings/kb-credentials', credentialId, 'uc'
    And def requestEntity = read(samplesPath + 'ucSettings.json')
    And set requestEntity.data.attributes.startMonth = 'invalid'
    And request requestEntity
    When method POST
    Then status 400

  Scenario: POST Usage Consolidation settings by KB credentials id should return 400 if invalid request data attributes platformType provided
    Given path '/eholdings/kb-credentials', credentialId, 'uc'
    And def requestEntity = read(samplesPath + 'ucSettings.json')
    And set requestEntity.data.attributes.platformType = 'invalid'
    And request requestEntity
    When method POST
    Then status 400

  Scenario: POST Usage Consolidation settings by KB credentials id should return 400 if invalid request data attributes metricType provided
    Given path '/eholdings/kb-credentials', credentialId, 'uc'
    And def requestEntity = read(samplesPath + 'ucSettings.json')
    And set requestEntity.data.attributes.metricType = 'invalid'
    And request requestEntity
    When method POST
    Then status 400

  Scenario: PATCH Usage Consolidation settings by KB credentials id should return 404 if no settings found
    Given path '/eholdings/kb-credentials', uuid(), 'uc'
    And def requestEntity = read(samplesPath + 'ucSettings.json')
    And request requestEntity
    When method PATCH
    Then status 404

  Scenario: PATCH Usage Consolidation settings by KB credentials id should return 400 if invalid request data attributes startMonth provided
    Given path '/eholdings/kb-credentials', credentialId, 'uc'
    And def requestEntity = read(samplesPath + 'ucSettings.json')
    And set requestEntity.data.attributes.startMonth = 'invalid'
    And request requestEntity
    When method PATCH
    Then status 400

  Scenario: PATCH Usage Consolidation settings by KB credentials id should return 400 if invalid request data attributes platformType provided
    Given path '/eholdings/kb-credentials', credentialId, 'uc'
    And def requestEntity = read(samplesPath + 'ucSettings.json')
    And set requestEntity.data.attributes.platformType = 'invalid'
    And request requestEntity
    When method PATCH
    Then status 400

  Scenario: GET Usage Consolidation settings customer key by KB credentials id should return 404 if no customer key found
    Given path '/eholdings/kb-credentials', uuid(), 'uc/key'
    When method GET
    Then status 404

  Scenario: GET Usage Consolidation settings should return 404 if no settings found
    Given path '/eholdings/kb-credentials', uuid(), 'uc'
    When method GET
    Then status 404

  Scenario: PUT Usage Consolidation credentials should return 422 if no clientId provided
    Given path '/eholdings/uc-credentials'
    And def requestEntity = read(samplesPath + 'ucCredentials.json')
    And remove requestEntity.attributes.clientId
    And request requestEntity
    When method PUT
    Then status 422
    And match response.errors[0].message == 'must not be null'
    And match response.errors[0].parameters[0].key == 'attributes.clientId'

  Scenario: PUT Usage Consolidation credentials should return 422 if empty clientId provided
    Given path '/eholdings/uc-credentials'
    And def requestEntity = read(samplesPath + 'ucCredentials.json')
    And set requestEntity.attributes.clientId = ''
    And request requestEntity
    When method PUT
    Then status 422
    And match response.errors[0].title == 'Invalid Usage Consolidation Credentials'

  Scenario: PUT Usage Consolidation credentials should return 422 if no clientSecret provided
    Given path '/eholdings/uc-credentials'
    And def requestEntity = read(samplesPath + 'ucCredentials.json')
    And remove requestEntity.attributes.clientSecret
    And request requestEntity
    When method PUT
    Then status 422
    And match response.errors[0].message == 'must not be null'
    And match response.errors[0].parameters[0].key == 'attributes.clientSecret'

  Scenario: PUT Usage Consolidation credentials should return 422 if empty clientSecret provided
    Given path '/eholdings/uc-credentials'
    And def requestEntity = read(samplesPath + 'ucCredentials.json')
    And set requestEntity.attributes.clientSecret = ''
    And request requestEntity
    When method PUT
    Then status 422
    And match response.errors[0].title == 'Invalid Usage Consolidation Credentials'
