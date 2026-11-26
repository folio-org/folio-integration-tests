@ignore
Feature: delete test applications (best effort)

  # Parameters: applicationIds (array of application ids), masterToken

  Scenario: delete every application in the list
    * def applicationIds = karate.get('applicationIds') || []
    * def masterToken = karate.get('masterToken')
    * def deleteArgs = karate.map(applicationIds, function(id) { return { applicationId: id, masterToken: masterToken } })
    * call read('classpath:eureka/mgr-applications/features/reusable/delete-application.feature') deleteArgs
