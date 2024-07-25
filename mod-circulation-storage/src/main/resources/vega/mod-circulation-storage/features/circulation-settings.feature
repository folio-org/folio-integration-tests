Feature: Tests For Circulation Settings

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * call read('classpath:common/util/uuid1.feature')

  Scenario:  EnableRequestPrintDetailsSetting

    # save circulation setting
    * def id = call uuid1
    * def circulationSettingRequest = read('samples/circulation-settings/print-event-setting.json')
    * circulationSettingRequest.id = id
    * circulationSettingRequest.name = 'EnableRequestPrintDetails'
    * circulationSettingRequest.value.enablePrintLog = 'true'
    Given path  '/circulation-settings-storage/circulation-settings'
    And request circulationSettingRequest
    When method POST
    Then status 201

    # get circulation setting by id
    Given path '/circulation-settings-storage/circulation-settings/' + id
    When method GET
    Then status 200
    And match response.name == 'EnableRequestPrintDetails'

    # update circulation setting by id
    * def circulationSettingRequest = read('samples/circulation-settings/print-event-setting.json')
    * circulationSettingRequest.id = id
    * circulationSettingRequest.name = 'printEventLogFeature'
    * circulationSettingRequest.value.enablePrintLog = 'true'
    Given path '/circulation-settings-storage/circulation-settings/' + id
    And request circulationSettingRequest
    When method PUT
    Then status 204

    # get circulation setting by query
    Given path '/circulation-settings-storage/circulation-settings'
    When method GET
    And param query = '(name=printEventLogFeature)'
    Then status 200
    And match response.circulationSettings[0].name == 'printEventLogFeature'
    And match response.totalRecords == 1

    # delete circulation setting
    Given path '/circulation-settings-storage/circulation-settings/' + id
    When method DELETE
    Then status 204

    # get all circulation settings
    Given path '/circulation-settings-storage/circulation-settings'
    When method GET
    Then status 200
    And match response.totalRecords == 0