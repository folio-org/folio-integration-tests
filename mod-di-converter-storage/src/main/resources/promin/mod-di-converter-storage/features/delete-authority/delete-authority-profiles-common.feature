@ignore
Feature: Util feature for the Settings - Delete MARC Authority profiles scenarios (FAT-28854)

  Background:
    * url baseUrl

  @RestoreMatchProfile
  Scenario: Put a match profile back to the given state
    Given path 'data-import-profiles/matchProfiles', profile.id
    And headers headersUser
    And request { profile: '#(profile)', addedRelations: [], deletedRelations: [] }
    When method PUT
    Then status 200

  @CountJobProfilesByName
  Scenario: Count job profiles with the given name
    Given path 'data-import-profiles/jobProfiles'
    And param query = 'name=="' + name + '"'
    And headers headersUser
    When method GET
    Then status 200
    * def totalRecords = response.totalRecords

  @GetJobProfileLayout
  Scenario: Get the match and actions a single-match job profile is built of
    # returns: layout - { matchProfileId, actions: [{ actionProfileId, reactTo }] }
    Given path 'data-import-profiles/jobProfileSnapshots', jobProfileId
    And headers headersUser
    When method POST
    Then status 201
    And match response.childSnapshotWrappers == '#[1]'
    * def matchWrapper = response.childSnapshotWrappers[0]
    * def actions = karate.map(matchWrapper.childSnapshotWrappers, function(w) { return { actionProfileId: w.profileId, reactTo: w.reactTo } })
    * def layout = { matchProfileId: '#(matchWrapper.profileId)', actions: '#(actions)' }
