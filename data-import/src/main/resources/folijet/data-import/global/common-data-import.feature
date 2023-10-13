Feature: Do Data Import Using Parameters

  Background:
    * url baseUrl

    * def parameters =
    """
    {
      uiKey: "#(uiKey)",
      name: "#(fileName)",
      filePath: "#(filePathFromSourceRoot)"
    }
    """

  Scenario: Import File as per requirement

    * print 'Started Loading From Common-Data-Import : ', 'uiKey : ', uiKey, 'name : ',fileName, 'filePath : ', filePathFromSourceRoot
    ## Create file definition
    Given path 'data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
      "fileDefinitions": [
        {
          "uiKey": "#(uiKey)",
          "size": 2,
          "name": "#(fileName)"
        }
      ]
    }
    """
    When method POST
    Then status 201
    * def response = $

    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id
    * def jobExecutionId = response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = response.metaJobExecutionId
    * def createDate = response.fileDefinitions[0].createDate
    * def uploadedDate = createDate

    Given path 'data-import/uploadUrl'
    And headers headersUser
    And param filename = fileName
    When method get
    Then status 200
    And def s3UploadKey = response.key
    And def s3UploadId = response.uploadId
    And def uploadUrl = response.url

    Given url uploadUrl
    And headers headersUser
    And header Content-Type = 'application/octet-stream'
    And request read(filePathFromSourceRoot)
    When method put
    Then status 200
    And def s3Etag = responseHeaders['ETag'][0]

    # reset
    * url baseUrl

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId, 'assembleStorageFile'
    And request { key: '#(s3UploadKey)', tags: ['#(s3Etag)'], uploadId: '#(s3UploadId)' }
    When method post
    Then status 204

    * print 'Uploaded filename :', fileName, ' to S3 as key:', s3UploadKey

    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method get
    Then status 200
    * def uploadDefinition = $
    * def sourcePath = response.fileDefinitions[0].sourcePath
