Feature: import MARC record

  Background:
    * url baseUrl
    * callonce read(login) consortiaAdmin
    * def headersJson = { 'Content-Type': 'application/json', 'x-okapi-tenant': '#(centralTenant)' ,'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }
    * configure headers = headersJson
    * def headersOctetStream = {'Content-Type': 'application/octet-stream', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'}
    * configure retry = { count: 10, interval: 5000 }

  Scenario: Import MARC record
    # post uploadDefinition
    Given path 'data-import/uploadDefinitions'
    And header x-okapi-tenant = centralTenant
    And request {'fileDefinitions': [{'name':'summerland.mrc'}]}
    When method POST
    Then status 201
    And def uploadDefinitionId = response.id
    And def fileDefinitionId = response.fileDefinitions[0].id

    # get upload URL
    Given path 'data-import/uploadUrl'
    And header x-okapi-tenant = centralTenant
    And param filename = 'sample_instance.mrc'
    When method GET
    Then status 200
    And def uploadUrl = response.url
    And def uploadKey = response.key
    And def uploadId = response.uploadId

    # upload MARC file
    Given url uploadUrl
    And configure headers = headersOctetStream
    And request karate.readAsString('classpath:samples/instances/summerland.mrc')
    When method PUT
    Then status 200
    And def eTag = responseHeaders['ETag'][0]

    # assemble storage file
    Given url baseUrl
    And path 'data-import/uploadDefinitions/', uploadDefinitionId, '/files/', fileDefinitionId, '/assembleStorageFile'
    And configure headers = headersJson
    And request {'uploadId': '#(uploadId)', 'key': '#(uploadKey)', 'tags': [ '#(eTag)' ] }
    When method POST
    Then status 204

    # update uploadDefinition
    Given path 'data-import/uploadDefinitions/', uploadDefinitionId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And def uploadDefinition = response

    # launch data-import processing
    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And param defaultMapping = true
    And header x-okapi-tenant = centralTenant
    And request {'uploadDefinition': '#(uploadDefinition)', 'jobProfileInfo': {'id':'e34d7b92-9b83-11eb-a8b3-0242ac130003', 'name':'#(jobProfileName)', 'dataType':'MARC'}}
    When method POST
    Then status 204

    # wait for data-import processing completion
    Given path '/metadata-provider/jobExecutions'
    And header x-okapi-tenant = centralTenant
    And param subordinationTypeNotAny = 'COMPOSITE_PARENT'
    And param subordinationTypeNotAny = 'PARENT_SINGLE'
    And retry until response.jobExecutions[0].status == 'COMMITTED'
    When method GET
    Then status 200

    # get instance HRID
    Given path 'inventory/instances'
    And header x-okapi-tenant = centralTenant
    And param query = 'title == "Summerland / Michael Chabon."'
    When method GET
    Then status 200
    And def instanceHrid = response.instances[0].hrid
