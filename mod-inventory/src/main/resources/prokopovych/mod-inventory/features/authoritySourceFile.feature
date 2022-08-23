Feature: Authority Source Files

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant':'#(testTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def samplesPath = 'classpath:prokopovych/mod-inventory/samples/'
    * def sourceFileSamplePath = samplesPath + 'authority-source-files/source-file.json'
    * def apiPath = '/authority-source-files'

  Scenario: Verify reference data loaded
    * print 'Retrieve authority source files'
    * def sourceFileSchema = { id: '#uuid', name: '#string', type: '#string', codes: '#array', metadata: '#notnull' }
    Given path apiPath
    When method GET
    Then status 200
    And match response.totalRecords == '#number? _ > 0'
    And match each response.authoritySourceFiles[*] == sourceFileSchema

  Scenario: Create authority source file
    * def sourceFileName = 'Test'
    * def sourceFileType = 'Subjects'

    * print 'Create authority source file'
    Given path apiPath
    And request read(sourceFileSamplePath)
    When method POST
    Then status 201
    And match response.id == '4cf17c3a-87ce-4532-ac14-9ef61a75f22c'
    And match response.name == sourceFileName
    And match response.type == sourceFileType
    And match response.codes[0] == 'tst1'
    And match response.codes[1] == 'tst2'

  Scenario: Update and retrieve authority source file
    * print 'Update authority source file'
    * def sourceFileName = 'Test updated'
    * def sourceFileType = 'Names'

    * def input = read(sourceFileSamplePath)
    * set input.codes = [ "upd1" ]
    Given path apiPath + '/4cf17c3a-87ce-4532-ac14-9ef61a75f22c'
    And request input
    When method PUT
    Then status 204

    * print 'Retrieve authority source file'
    Given path apiPath + '/4cf17c3a-87ce-4532-ac14-9ef61a75f22c'
    When method GET
    Then status 200
    And match response.id == '4cf17c3a-87ce-4532-ac14-9ef61a75f22c'
    And match response.name == sourceFileName
    And match response.type == sourceFileType
    And match response.codes == '#[1]'
    And match response.codes[0] == 'upd1'

  Scenario: Delete authority source file
    * print 'Delete authority source file'
    Given path apiPath + '/4cf17c3a-87ce-4532-ac14-9ef61a75f22c'
    When method DELETE
    Then status 204

    * print 'Verify authority source file is deleted'
    Given path apiPath + '/4cf17c3a-87ce-4532-ac14-9ef61a75f22c'
    When method GET
    Then status 404
