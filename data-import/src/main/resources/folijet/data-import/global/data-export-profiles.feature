@ignore
Feature: Util feature for creating data export job and mapping profiles.
  # parameters: mappingProfile, jobProfileName, dataExportMappingProfileId
  # returns: created job and mapping profiles id

  Background:
    * url baseUrl

  @createMappingProfile
  Scenario: Create mapping profile for data-export
    # parameters: mappingProfile
    # returns: created mapping profile id

    # Create mapping profile for data-export
    Given path 'data-export/mapping-profiles'
    And headers headersUser
    And request __arg.mappingProfile
    When method POST
    Then status 201
    * def dataExportMappingProfileId = response.id

  @createJobProfile
  Scenario: Create job profile for data-export
    # parameters: jobProfileName, dataExportMappingProfileId
    # returns: created job profile id

    # Create job profile for data-export
    Given path 'data-export/job-profiles'
    And headers headersUser
    And request
      """
      {
        "name": "#(__arg.jobProfileName)",
        "destination": "fileSystem",
        "description": "Job profile for instance, holdings, item export",
        "mappingProfileId": "#(__arg.dataExportMappingProfileId)"
      }
      """
    When method POST
    Then status 201
    * def dataExportJobProfileId = response.id