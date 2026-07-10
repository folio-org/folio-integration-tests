Feature: create instances via data import

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

  Scenario: create three local MARC instances
    # create upload definition
    * def uploadDefinition =
      """
      {
        "fileDefinitions": [
          {
            "name": "three-marc-records.mrc"
          }
        ]
      }
      """

    Given path 'data-import/uploadDefinitions'
    And request uploadDefinition
    When method POST
    Then status 201
    * def uploadDefinition = response
    * def fileDefinition = uploadDefinition.fileDefinitions[0]

    # get upload URL
    Given path 'data-import/uploadUrl'
    And param filename = "three-marc-records.mrc"
    When method GET
    Then status 200
    * def uploadUrl = response.url
    * def key = response.key
    * def uploadId = response.uploadId

    # upload file
    * def content = karate.readAsBytes('classpath:samples/three-marc-records.mrc')

    Given url uploadUrl
    And header Content-Type = 'application/octet-stream'
    And request content
    When method PUT
    Then status 200
    * def eTag = responseHeaders['ETag'][0]

    # assemble storage file
    * url baseUrl
    * def assembleRequest =
      """
      {
        "uploadId": "#(uploadId)",
        "key": "#(key)",
        "tags": ["#(eTag)"]
      }
      """
    Given path 'data-import/uploadDefinitions', uploadDefinition.id, 'files', fileDefinition.id, 'assembleStorageFile'
    And request assembleRequest
    When method POST
    Then status 204

    # get upload definition
    Given path 'data-import/uploadDefinitions', uploadDefinition.id
    When method GET
    Then status 200
    * def uploadDefinition = response

    # process file
    * def assembleRequest =
      """
      {
        "uploadDefinition": "#(uploadDefinition)",
        "jobProfileInfo": {
          "id": "e34d7b92-9b83-11eb-a8b3-0242ac130003",
          "name": "Default - Create instance and SRS MARC Bib",
          "dataType": "MARC"
        }
      }
      """
    Given path 'data-import/uploadDefinitions', uploadDefinition.id, 'processFiles'
    And request assembleRequest
    When method POST
    Then status 204

    * pause(20000)

    * configure retry = { count: 12, interval: 5000 }
    Given path 'metadata-provider/jobExecutions'
    And retry until responseStatus == 200 && response.jobExecutions && karate.filter(response.jobExecutions, function(job) { return job.sourcePath == key && (job.status == 'COMMITTED' || job.status == 'ERROR') }).length > 0
    When method GET
    Then status 200
    * def jobExecution = karate.filter(response.jobExecutions, function(job) { return job.sourcePath == key })[0]
    * assert jobExecution.status == 'COMMITTED'
    * assert jobExecution.totalRecordsInFile == 3

    # wait until imported MARC instances are available in inventory
    * def isAvailableSummerlandMarc =
      """
      function(instance) {
        return instance.source == 'MARC'
          && instance.title
          && instance.title.indexOf('Summerland') == 0
          && !instance.deleted
          && !instance.discoverySuppress
          && !instance.staffSuppress;
      }
      """
    Given path 'inventory/instances'
    And param limit = 1000
    And retry until responseStatus == 200 && karate.filter(response.instances, isAvailableSummerlandMarc).length >= 3
    When method GET
    Then status 200
