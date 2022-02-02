Feature: File upload

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiAdminToken)', 'Accept': 'application/json'  }

    * def randomNumber = callonce random

  Scenario: Upload EDIFACT .edi file

    * print 'Upload .edi file'

    * def uiKey = 'FAT-139_1.edi' + randomNumber

    Given path '/data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
      "fileDefinitions": [
        {
          "uiKey": "#(uiKey)",
          "size": 1,
          "name": "FAT-139_1.edi"
        }
      ]
    }
    """
    When method POST
    Then status 201

    * def response = $
    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request read('classpath:folijet/data-import/samples/samples_for_upload/FAT-139_1.edi')
    When method POST
    Then status 200

    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method GET
    Then status 200

  Scenario: Upload EDIFACT .inv file

    * print 'Upload .inv file'

    * def uiKey = 'FAT-139_2.inv' + randomNumber

    Given path '/data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
      "fileDefinitions": [
        {
          "uiKey": "#(uiKey)",
          "size": 1,
          "name": "FAT-139_2.inv"
        }
      ]
    }
    """
    When method POST
    Then status 201

    * def response = $
    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request read('classpath:folijet/data-import/samples/samples_for_upload/FAT-139_2.inv')
    When method POST
    Then status 200

    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method GET
    Then status 200

  Scenario: Upload MARC .mrc file

    * print 'Move already implemented Upload MARC file test from data-import-integration.feature'

    * def uiKey = 'FAT-139_3.mrc' + randomNumber

    Given path '/data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
      "fileDefinitions": [
        {
          "uiKey": "#(uiKey)",
          "size": 2,
          "name": "FAT-139_3.mrc"
        }
      ]
    }
    """
    When method POST
    Then status 201

    * def response = $
    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request read('classpath:folijet/data-import/samples/samples_for_upload/FAT-139_3.mrc')
    When method POST
    Then status 200

    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method GET
    Then status 200

  Scenario: Upload MARC .json file

    * print 'Upload .json file'

    * def uiKey = 'FAT-139_4.json' + randomNumber

    Given path '/data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
      "fileDefinitions": [
        {
          "uiKey": "#(uiKey)",
          "size": 2,
          "name": "FAT-139_4.json"
        }
      ]
    }
    """
    When method POST
    Then status 201

    * def response = $
    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request read('classpath:folijet/data-import/samples/samples_for_upload/FAT-139_4.json')
    When method POST
    Then status 200

    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method GET
    Then status 200

  Scenario: Upload MARC .xml file

    * print 'Upload .xml file'

    * def uiKey = 'FAT-139_5.xml' + randomNumber

    Given path '/data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
      "fileDefinitions": [
        {
          "uiKey": "#(uiKey)",
          "size": 2,
          "name": "FAT-139_5.xml"
        }
      ]
    }
    """
    When method POST
    Then status 201

    * def response = $
    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request read('classpath:folijet/data-import/samples/samples_for_upload/FAT-139_5.xml')
    When method POST
    Then status 200

    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method GET
    Then status 200