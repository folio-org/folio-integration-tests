Feature: Field protections

  Background:
    * url baseUrl
    * callonce login testAdmin

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser

    * def setting = { "field" : "500", "indicator1" : "a", "indicator2" : "a", "subfield" : "1", "data" : "*", "source" : "USER", "override" : false }
    * def invalidSetting = { "invalidField" : "500", "indicator1" : "1", "indicator2" : "a", "subfield" : "1", "data" : "*", "source" : "USER", "override" : false }
    * def emptySetting = { }
    * def invalidSettingId = '00000000-0000-0000-0000-000000000000'

  Scenario: Create new field protection setting for MARC Bib
    * print 'Create new field protection setting'

    ## Create field protection setting
    Given path 'field-protection-settings', 'marc'
    And request setting
    When method POST
    Then status 201

  Scenario: Get all existing field protection settings
    * print 'Retrieve all protection settings'

    ## Get all existing field protection settings
    Given path 'field-protection-settings', 'marc'
    When method GET
    Then status 200

  Scenario: Get existing field protection settings filtered by source
    * print 'Retrieve field protection settings created by User or System'

    ## Get all field protection settings created by System
    Given path 'field-protection-settings', 'marc'
    And param query = 'source=SYSTEM'
    When method GET
    Then status 200
    And assert response.totalRecords == '2'
    And assert response.marcFieldProtectionSettings[0].source == 'SYSTEM', response.marcFieldProtectionSettings[1].source == 'SYSTEM'

  Scenario: Fail to create a setting with invalid field/empty body
    * print 'Try to pass an invalid field/empty body while creating a setting, verify that it fails'

    ## Create field protection setting with invalid field 'field'
    Given path 'field-protection-settings', 'marc'
    And request invalidSetting
    When method POST
    Then status 422

    ## Create field protection setting with empty body
    Given path 'field-protection-settings', 'marc'
    And request emptySetting
    When method POST
    Then status 422


  Scenario: Update field protection setting
    * print 'Create and successfully update a field protection setting'

    ## Create field protection setting
    Given path 'field-protection-settings', 'marc'
    And request setting
    When method POST
    Then status 201

    * def settingId = $.id

    ## Update field protection setting
    Given path 'field-protection-settings', 'marc', settingId
    And request
    """
    {
      "id" : "#(settingId)",
      "field" : "500",
      "indicator1" : "1",
      "indicator2" : "a",
      "subfield" : "1",
      "data" : "*",
      "source" : "USER",
      "override" : false
    }
    """
    When method PUT
    Then status 200
    And assert response.id == settingId
    And assert response.field == '500'
    And assert response.indicator1 == '1'
    And assert response.indicator2 == 'a'
    And assert response.subfield == '1'
    And assert response.data == '*'


  Scenario: Fail to update a setting with invalid field/empty body
    * print 'Try to pass an invalid field/empty body while update a setting, verify that it fails'

    ## Update field protection setting with invalid field 'field'
    Given path 'field-protection-settings', 'marc', invalidSettingId
    And request invalidSetting
    When method PUT
    Then status 422

    ## Update field protection setting with empty body
    Given path 'field-protection-settings', 'marc', invalidSettingId
    And request emptySetting
    When method PUT
    Then status 422

  Scenario: Fail to get a setting by id if it does not exist
    * print 'Verify 404 on get by id if setting does not exist'

    ## Get field protection setting by id that does not exist
    Given path 'field-protection-settings', 'marc', invalidSettingId
    When method GET
    Then status 404

  Scenario: Fail to update/delete a setting with source System
    * print 'Try to update/delete a setting with source System, verify that it fails'

    ## Create field protection setting with source System
    Given path 'field-protection-settings', 'marc'
    And request
    """
    {
      "field" : "001",
      "indicator1" : "",
      "indicator2" : "",
      "subfield" : "",
      "data" : "*",
      "source" : "SYSTEM"
    }
    """
    When method POST
    Then status 201

    * def settingId = $.id

    ## Update field protection setting with source System
    Given path 'field-protection-settings', 'marc', settingId
    And request
    """
    {
      "id" : "#(settingId)",
      "field" : "001",
      "indicator1" : "3",
      "indicator2" : "",
      "subfield" : "",
      "data" : "*",
      "source" : "SYSTEM"
    }
    """
    When method PUT
    Then status 400

  Scenario: Delete field protection setting
    * print 'Delete field protection setting'

    ## Create field protection setting
    Given path 'field-protection-settings', 'marc'
    And request setting
    When method POST
    Then status 201

    * def settingId = $.id

    ## Delete field protection setting
    Given path 'field-protection-settings', 'marc', settingId
    When method DELETE
    Then status 204
