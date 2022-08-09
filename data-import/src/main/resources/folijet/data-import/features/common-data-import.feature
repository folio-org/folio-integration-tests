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

    ## Upload marc-file
    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    * print 'FilePath ---', filePathFromSourceRoot
    And request read(filePathFromSourceRoot)
    When method POST
    Then status 200
    And assert response.status == 'LOADED'

    ## Verify upload definition
    * call pause 5000
    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method GET
    Then status 200

    * def sourcePath = response.fileDefinitions[0].sourcePath