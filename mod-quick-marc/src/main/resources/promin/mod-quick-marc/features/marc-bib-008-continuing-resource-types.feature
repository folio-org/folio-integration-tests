# For MODQM-530, https://foliotest.testrail.io/index.php?/cases/view/1632022, https://foliotest.testrail.io/index.php?/cases/view/1632023
Feature: MARC Bib 008 Specification - Types Of Continuing Resource

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json' }

  @C1632022
  @Positive
  Scenario: New types of continuing resource are available for 008 field of MARC bibliographic record
    # 1. Open The Specification Of Field 008 For MARC Bibliographic Records
    Given path 'marc-specifications', 'bibliographic', '008'
    And headers headersUser
    When method GET
    Then status 200
    And match response.tag == '008'
    And match response.format == 'BIBLIOGRAPHIC'
    * def continuingResources = karate.filter(response.spec.types, function(t){ return t.code == 'continuing_resources' })
    And match continuingResources == '#[1]'

    # 2. Check The Values Allowed In Type Of Continuing Resource (SrTp, Position 21)
    * def srTp = karate.filter(continuingResources[0].items, function(i){ return i.code == 'SrTp' })
    And match srTp == '#[1]'
    And match srTp[0].position == 21
    And match srTp[0].name == 'Type of continuing resource'
    And match srTp[0].allowedValues contains { code: 'a', name: 'Activity report' }
    And match srTp[0].allowedValues contains { code: 'i', name: 'Serial zine' }
    And match srTp[0].allowedValues contains { code: 'q', name: 'Serial podcast' }

  @C1632023
  @Positive
  Scenario: Existing types of continuing resource stay unchanged in 008 field of MARC bibliographic record after specification update
    # 1. Open The Specification Of Field 008 For MARC Bibliographic Records
    Given path 'marc-specifications', 'bibliographic', '008'
    And headers headersUser
    When method GET
    Then status 200
    * def continuingResources = karate.filter(response.spec.types, function(t){ return t.code == 'continuing_resources' })
    And match continuingResources == '#[1]'
    * def identifiedBy = continuingResources[0].identifiedBy.or
    And match identifiedBy contains deep { tag: 'LDR', positions: { '6': ['a'], '7': ['b', 'i', 's'] } }
    And match identifiedBy contains deep { tag: 'LDR', positions: { '6': ['s'] } }

    # 2. Check The Values Allowed In Type Of Continuing Resource (SrTp, Position 21)
    * def srTp = karate.filter(continuingResources[0].items, function(i){ return i.code == 'SrTp' })
    And match srTp == '#[1]'
    * def earlierValues =
      """
      [
        { "code": "|", "name": "No attempt to code" },
        { "code": "\\", "name": "None of the following" },
        { "code": "d", "name": "Updating database" },
        { "code": "g", "name": "Magazine" },
        { "code": "h", "name": "Blog" },
        { "code": "j", "name": "Journal" },
        { "code": "l", "name": "Updating loose-leaf" },
        { "code": "m", "name": "Monographic series" },
        { "code": "n", "name": "Newspaper" },
        { "code": "p", "name": "Periodical" },
        { "code": "r", "name": "Repository" },
        { "code": "s", "name": "Newsletter" },
        { "code": "t", "name": "Directory" },
        { "code": "w", "name": "Updating Web site" }
      ]
      """
    And match srTp[0].allowedValues contains earlierValues
    And match srTp[0].allowedValues == '#[17]'
