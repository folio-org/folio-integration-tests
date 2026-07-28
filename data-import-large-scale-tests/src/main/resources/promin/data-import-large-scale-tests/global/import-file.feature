@ignore
Feature: Import records file
  # Util feature for records import
  # parameters: fileName, filePathFromSourceRoot, jobProfileInfo

  Background:
    * url baseUrl

    @importFile
    Scenario: Import records file
      * print 'Started loading from import-file feature: ', 'fileName: ', fileName, 'filePath: ', filePathFromSourceRoot, 'profileId: ', jobProfileInfo.id
      * print 'File name: ', filePathFromSourceRoot
      * def fileResourcePath = filePathFromSourceRoot.replace('classpath:', '')
      * def fileBytes = karate.read(filePathFromSourceRoot)

      * configure headers = null
      * call login testUser
      * def okapitokenUser = okapitoken
      * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(tenant)', 'Accept': '*/*' }
      * configure headers = headersUser

      # Create uploadDefinition
      * def randomNumber = callonce random
      * def uiKey = fileName + randomNumber

      Given path 'data-import/uploadDefinitions'
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
      And param filename = fileName
      When method get
      Then status 200
      And def s3UploadKey = response.key
      And def s3UploadId = response.uploadId
      And def uploadUrl = response.url

      * print 'Starting upload file: ', fileName
      * def FileUploader = Java.type('org.folio.FileUploader')
      * def uploadResponse = FileUploader.uploadBytes(uploadUrl, 'application/octet-stream', fileBytes)
      * def status = uploadResponse.getStatusLine().getStatusCode()
      * match status == 200

      * def allHeaders = uploadResponse.getAllHeaders()
      * eval var s3Etag = null; for(var i=0;i<allHeaders.length;i++){var h=allHeaders[i]; if(h.getName().toLowerCase()==='etag'){s3Etag=h.getValue(); break;} }
      * match s3Etag != null && s3Etag != ''

      # revert url
      * url baseUrl

      Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId, 'assembleStorageFile'
      And request { key: '#(s3UploadKey)', tags: ['#(s3Etag)'], uploadId: '#(s3UploadId)' }
      When method post
      Then status 204

      * print 'Uploaded file: ', fileName, ' to S3 storage as key: ', s3UploadKey

      Given path 'data-import/uploadDefinitions', uploadDefinitionId
      When method get
      Then status 200
      And assert response.fileDefinitions[0].status == 'UPLOADED'
      And def uploadDefinition = response

      # Process file
      Given path '/data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
      And request
      """
      {
        "uploadDefinition": "#(uploadDefinition)",
        "jobProfileInfo": "#(jobProfileInfo)"
      }
      """
      When method post
      Then status 204
