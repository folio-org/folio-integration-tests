Feature: Authority assignment check

  Background:
    * url baseUrl

    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

    * def personMarcString = karate.readAsString('classpath:citation/mod-linked-data/features/authority-assignment-check/samples/marc_authority_person.json')
    * def familyMarcString = karate.readAsString('classpath:citation/mod-linked-data/features/authority-assignment-check/samples/marc_authority_family.json')
    * def orgMarcString = karate.readAsString('classpath:citation/mod-linked-data/features/authority-assignment-check/samples/marc_authority_organization.json')
    * def jurisdictionMarcString = karate.readAsString('classpath:citation/mod-linked-data/features/authority-assignment-check/samples/marc_authority_jurisdiction.json')
    * def meetingMarcString = karate.readAsString('classpath:citation/mod-linked-data/features/authority-assignment-check/samples/marc_authority_meeting.json')
    * def topicMarcString = karate.readAsString('classpath:citation/mod-linked-data/features/authority-assignment-check/samples/marc_authority_topic.json')
    * def placeMarcString = karate.readAsString('classpath:citation/mod-linked-data/features/authority-assignment-check/samples/marc_authority_place.json')
    * def formMarcString = karate.readAsString('classpath:citation/mod-linked-data/features/authority-assignment-check/samples/marc_authority_form.json')
    * def hubMarcString = karate.readAsString('classpath:citation/mod-linked-data/features/authority-assignment-check/samples/marc_authority_hub.json')

  # SUBJECT_OF_WORK accepts range of authority types:
  # person, family, organization, jurisdiction, meeting, topic, place, form, and hub

  @Positive
  Scenario: PERSON authority is valid for SUBJECT_OF_WORK
    * def requestBody = ({ rawMarc: personMarcString, target: 'SUBJECT_OF_WORK' })

    Given path 'linked-data/authority-assignment-check'
    And request requestBody
    When method POST
    Then status 200

    * match response.validAssignment == true
    * match response.invalidAssignmentReason == '#notpresent'

  @Positive
  Scenario: FAMILY authority is valid for SUBJECT_OF_WORK
    * def requestBody = ({ rawMarc: familyMarcString, target: 'SUBJECT_OF_WORK' })

    Given path 'linked-data/authority-assignment-check'
    And request requestBody
    When method POST
    Then status 200

    * match response.validAssignment == true
    * match response.invalidAssignmentReason == '#notpresent'

  @Positive
  Scenario: ORGANIZATION authority is valid for SUBJECT_OF_WORK
    * def requestBody = ({ rawMarc: orgMarcString, target: 'SUBJECT_OF_WORK' })

    Given path 'linked-data/authority-assignment-check'
    And request requestBody
    When method POST
    Then status 200

    * match response.validAssignment == true
    * match response.invalidAssignmentReason == '#notpresent'

  @Positive
  Scenario: JURISDICTION authority is valid for SUBJECT_OF_WORK
    * def requestBody = ({ rawMarc: jurisdictionMarcString, target: 'SUBJECT_OF_WORK' })

    Given path 'linked-data/authority-assignment-check'
    And request requestBody
    When method POST
    Then status 200

    * match response.validAssignment == true
    * match response.invalidAssignmentReason == '#notpresent'

  @Positive
  Scenario: MEETING authority is valid for SUBJECT_OF_WORK
    * def requestBody = ({ rawMarc: meetingMarcString, target: 'SUBJECT_OF_WORK' })

    Given path 'linked-data/authority-assignment-check'
    And request requestBody
    When method POST
    Then status 200

    * match response.validAssignment == true
    * match response.invalidAssignmentReason == '#notpresent'

  @Positive
  Scenario: TOPIC authority is valid for SUBJECT_OF_WORK
    * def requestBody = ({ rawMarc: topicMarcString, target: 'SUBJECT_OF_WORK' })

    Given path 'linked-data/authority-assignment-check'
    And request requestBody
    When method POST
    Then status 200

    * match response.validAssignment == true
    * match response.invalidAssignmentReason == '#notpresent'

  @Positive
  Scenario: PLACE authority is valid for SUBJECT_OF_WORK
    * def requestBody = ({ rawMarc: placeMarcString, target: 'SUBJECT_OF_WORK' })

    Given path 'linked-data/authority-assignment-check'
    And request requestBody
    When method POST
    Then status 200

    * match response.validAssignment == true
    * match response.invalidAssignmentReason == '#notpresent'

  @Positive
  Scenario: FORM authority is valid for SUBJECT_OF_WORK
    * def requestBody = ({ rawMarc: formMarcString, target: 'SUBJECT_OF_WORK' })

    Given path 'linked-data/authority-assignment-check'
    And request requestBody
    When method POST
    Then status 200

    * match response.validAssignment == true
    * match response.invalidAssignmentReason == '#notpresent'

  @Positive
  Scenario: HUB authority is valid for SUBJECT_OF_WORK
    * def requestBody = ({ rawMarc: hubMarcString, target: 'SUBJECT_OF_WORK' })

    Given path 'linked-data/authority-assignment-check'
    And request requestBody
    When method POST
    Then status 200

    * match response.validAssignment == true
    * match response.invalidAssignmentReason == '#notpresent'

  # CREATOR_OF_WORK accepts person, family, organization, jurisdiction, and meeting authority types

  @Positive
  Scenario: PERSON authority is valid for CREATOR_OF_WORK
    * def requestBody = ({ rawMarc: personMarcString, target: 'CREATOR_OF_WORK' })

    Given path 'linked-data/authority-assignment-check'
    And request requestBody
    When method POST
    Then status 200

    * match response.validAssignment == true
    * match response.invalidAssignmentReason == '#notpresent'

  @Positive
  Scenario: FAMILY authority is valid for CREATOR_OF_WORK
    * def requestBody = ({ rawMarc: familyMarcString, target: 'CREATOR_OF_WORK' })

    Given path 'linked-data/authority-assignment-check'
    And request requestBody
    When method POST
    Then status 200

    * match response.validAssignment == true
    * match response.invalidAssignmentReason == '#notpresent'

  @Positive
  Scenario: ORGANIZATION authority is valid for CREATOR_OF_WORK
    * def requestBody = ({ rawMarc: orgMarcString, target: 'CREATOR_OF_WORK' })

    Given path 'linked-data/authority-assignment-check'
    And request requestBody
    When method POST
    Then status 200

    * match response.validAssignment == true
    * match response.invalidAssignmentReason == '#notpresent'

  @Positive
  Scenario: JURISDICTION authority is valid for CREATOR_OF_WORK
    * def requestBody = ({ rawMarc: jurisdictionMarcString, target: 'CREATOR_OF_WORK' })

    Given path 'linked-data/authority-assignment-check'
    And request requestBody
    When method POST
    Then status 200

    * match response.validAssignment == true
    * match response.invalidAssignmentReason == '#notpresent'

  @Positive
  Scenario: MEETING authority is valid for CREATOR_OF_WORK
    * def requestBody = ({ rawMarc: meetingMarcString, target: 'CREATOR_OF_WORK' })

    Given path 'linked-data/authority-assignment-check'
    And request requestBody
    When method POST
    Then status 200

    * match response.validAssignment == true
    * match response.invalidAssignmentReason == '#notpresent'

  # DEGREE_GRANTING_INSTITUTION exclusively accepts organization authority type

  @Positive
  Scenario: ORGANIZATION authority is valid for DEGREE_GRANTING_INSTITUTION
    * def requestBody = ({ rawMarc: orgMarcString, target: 'DEGREE_GRANTING_INSTITUTION' })

    Given path 'linked-data/authority-assignment-check'
    And request requestBody
    When method POST
    Then status 200

    * match response.validAssignment == true
    * match response.invalidAssignmentReason == '#notpresent'
