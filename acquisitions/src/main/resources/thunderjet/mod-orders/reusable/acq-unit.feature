@Ignore
Feature: Reusable components for acquisition units

  Background:
    * url baseUrl
    * def randomAcqUnitId = call uuid

  @CreateAcqUnit
  Scenario: Create acquisition unit
    * def id = karate.get('id', randomAcqUnitId)
    * def name = karate.get('name', 'Acq Unit 1')
    * def protectCreate = karate.get('protectCreate', true)
    * def protectRead = karate.get('protectRead', true)
    * def protectUpdate = karate.get('protectUpdate', true)
    * def protectDelete = karate.get('protectDelete', true)
    * def isDeleted = karate.get('isDeleted', false)

    Given path 'acquisitions-units-storage/units'
    And request
      """
      {
        id: '#(id)',
        name: '#(name)',
        isDeleted: false,
        protectCreate: '#(protectCreate)',
        protectRead: '#(protectRead)',
        protectUpdate: '#(protectUpdate)',
        protectDelete: '#(protectDelete)'
      }
      """
    When method POST
    Then status 201


  @AssignUserToAcqUnit
  Scenario: Assign user to acquisition unit
    * def acqUnitId = karate.get('acqUnitId', randomAcqUnitId)

    Given path 'acquisitions-units-storage/memberships'
    And request
      """
      {
        "userId": "#(userId)",
        "acquisitionsUnitId": "#(acqUnitId)"
      }
      """
    When method POST
    Then status 201


  @DeleteUserFromAcqUnit
  Scenario: Delete user from acquisition unit
    * def acqUnitId = karate.get('acqUnitId', randomAcqUnitId)

    Given path 'acquisitions-units-storage/memberships'
    And param query = 'acquisitionsUnitId==' + acqUnitId + ' and userId==' + userId
    When method GET
    Then status 200

    * def acqMember = $.acquisitionsUnitMemberships[0]
    * def acqMemberId = acqMember.id

    # Note: this requires a 'text/plain' Accept header
    Given path 'acquisitions-units-storage/memberships', acqMemberId
    When method DELETE
    Then status 204
