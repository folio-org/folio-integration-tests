Feature: Marc BIB Mapping Rules

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')

  Scenario: FAT-4701 check that default rules in karate tests matches what is in the SRM under test
    * def javaJsonUtils = Java.type('test.java.JsonUtils')
    Given path 'mapping-rules/marc-bib'
    And headers headersAdmin
    And def expectedJson = JSON.stringify(read('classpath:folijet/data-import/samples/samples_for_upload/default-marc-bib-rules.json'))
    When method GET
    Then status 200
    And def responseJson = JSON.stringify(response)
    And def isEqual = javaJsonUtils.compareJson(responseJson, expectedJson)
    And assert isEqual == true
