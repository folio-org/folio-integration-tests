Feature: Packages

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }
    * def samplesPath = 'classpath:spitfire/mod-kb-ebsco-java/features/samples/export/'

    * def credentialId = karate.properties['credentialId']
    * def packageId = karate.properties['packageId']

  Scenario: Export package
    Given path 'data-export-spring/jobs'
    And request read(samplesPath + 'job.json')
    When method POST
    Then status 201
    And def jobId = $.id

    #get job until status SUCCESSFUL and validate
    Given path 'data-export-spring/jobs', jobId
    And retry until response.status == 'SUCCESSFUL' || response.status == 'FAILED'
    When method GET
    Then status 200
    And match $.startTime == '#present'
    And match $.endTime == '#present'
    And assert response.files.length == 1
    And def fileLink = $.files[0]

    #verfiy downloaded file
    Given url fileLink
    When method GET
    Then status 200
    And def expectedCsvFile = karate.readAsString(samplesPath + 'csv/package.csv')
    And match expectedCsvFile == response

