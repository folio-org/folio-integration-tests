@ignore
Feature: Import records file
  # Util feature for records import
  # parameters: fileName, filePathFromSourceRoot, jobProfileInfo

  Background:
    * url baseUrl

    @importFile
    Scenario: Import records file
      * print 'Started loading from import-file feature: ', 'fineName: ', fileName, 'filePath: ', filePathFromSourceRoot, 'profileId: ', jobProfileInfo.id

      # Create uploadDefinition
      * def randomNumber = callonce random
      * def uiKey = fileName + randomNumber

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
      When method post
      Then status 201
      And def createdUploadDefinition = response

      * def uploadDefinitionId = createdUploadDefinition.fileDefinitions[0].uploadDefinitionId
      * def fileId = createdUploadDefinition.fileDefinitions[0].id
      * def jobExecutionId = createdUploadDefinition.fileDefinitions[0].jobExecutionId

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

      # revert url
      * url baseUrl

      Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId, 'assembleStorageFile'
      And headers headersUser
      And request { key: '#(s3UploadKey)', tags: ['#(s3Etag)'], uploadId: '#(s3UploadId)' }
      When method post
      Then status 204

      * print 'Uploaded file: ', fileName, ' to S3 storage as key: ', s3UploadKey

      Given path 'data-import/uploadDefinitions', uploadDefinitionId
      And headers headersUser
      When method get
      Then status 200
      And assert response.fileDefinitions[0].status == 'UPLOADED'
      And def uploadDefinition = response

      # Process file
      Given path '/data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
      And headers headersUser
      And request
      """
      {
        "uploadDefinition": "#(uploadDefinition)",
        "jobProfileInfo": "#(jobProfileInfo)"
      }
      """
      When method post
      Then status 204
