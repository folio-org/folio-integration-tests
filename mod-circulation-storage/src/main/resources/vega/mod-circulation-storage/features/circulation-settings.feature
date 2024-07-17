Feature: Tests For Circulation Settings

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * call read('classpath:common/util/uuid1.feature')
    * call read('classpath:common/util/random_string.feature')

  Scenario:  EnableRequestPrintDetailsSetting
    * print 'create EnableRequestPrintDetailsSetting'
    * def id = call uuid1
    * def name = 'EnableRequestPrintDetails'
    * def requesterName = call random_string

    Given path  '/circulation-settings-storage/circulation-settings'
    And request
      """
      {
        "id": "#(id)",
        "name": "EnableRequestPrintDetailsSetting",
        "value": {
          "EnablePrintDetails": "true"
        }
      }
      """
    When method POST
    Then status 201

    Given path '/circulation-settings-storage/circulation-settings/' + id
    When method GET
    Then status 200
    And match response.circulationSettings[0].name == 'EnableRequestPrintDetails'
    And match response.totalRecords == 1

    Given path '/circulation-settings-storage/circulation-settings/' + id
    When method PUT


