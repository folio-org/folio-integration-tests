Feature: scheduler user timers

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: create, update, and delete a user timer through scheduler APIs
    # Build a USER timer with a future cron so CRUD does not trigger execution.
    * def futureSchedule = { cron: '0 0 0 1 1 ? 2099', zone: 'UTC' }
    * def timerId = uuid()
    * def suffix = nowMillis()
    * def moduleName = 'mod-scheduler-karate-api-' + suffix
    * def moduleId = moduleName + '-1.0.0'
    * def timerPath = '/mod-scheduler-karate/' + suffix + '/api-timer'
    * def timerRequest =
      """
      {
        "id": "#(timerId)",
        "type": "user",
        "enabled": true,
        "moduleId": "#(moduleId)",
        "routingEntry": {
          "methods": [ "POST" ],
          "pathPattern": "#(timerPath)",
          "schedule": "#(futureSchedule)"
        }
      }
      """

    # Create the USER timer and verify persisted descriptor fields.
    Given path 'scheduler/timers'
    And request timerRequest
    When method POST
    Then status 201
    And match response.id == timerId
    And match response.type == 'user'
    And match response.enabled == true
    And match response.moduleId == moduleId
    And match response.moduleName == moduleName
    And match response.routingEntry.pathPattern == timerPath
    And match response.routingEntry.schedule == futureSchedule
    And match response.metadata.createdDate == '#present'
    And match response.metadata.updatedDate == '#present'

    # Confirm the timer appears in the collection endpoint.
    Given path 'scheduler/timers'
    And param limit = 500
    When method GET
    Then status 200
    And match response.timerDescriptors == '#array'
    And match response.totalRecords == '#number'
    * def createdTimers = karate.filter(response.timerDescriptors, timer => timer.id == timerId)
    And match createdTimers == '#[1]'

    # Retrieve the timer by id.
    Given path 'scheduler/timers', timerId
    When method GET
    Then status 200
    And match response.id == timerId
    And match response.routingEntry.pathPattern == timerPath

    # Disable the timer and verify updated state.
    * set timerRequest.enabled = false
    Given path 'scheduler/timers', timerId
    And request timerRequest
    When method PUT
    Then status 200
    And match response.id == timerId
    And match response.enabled == false
    And match response.modified == true

    # Delete the timer.
    Given path 'scheduler/timers', timerId
    When method DELETE
    Then status 204

    # Verify the deleted timer is no longer available.
    Given path 'scheduler/timers', timerId
    When method GET
    Then status 404

  @Positive
  Scenario: invoke a user timer according to delay schedule
    # Build a target USER timer that should be deleted by a scheduled timer.
    * configure retry = { count: 10, interval: 1000 }
    * def suffix = nowMillis()
    * def futureSchedule = { cron: '0 0 0 1 1 ? 2099', zone: 'UTC' }
    * def targetTimerId = uuid()
    * def targetTimerRequest =
      """
      {
        "id": "#(targetTimerId)",
        "type": "user",
        "enabled": true,
        "moduleId": "#('mod-scheduler-karate-target-' + suffix + '-1.0.0')",
        "routingEntry": {
          "methods": [ "POST" ],
          "pathPattern": "#('/mod-scheduler-karate/' + suffix + '/target-timer')",
          "schedule": "#(futureSchedule)"
        }
      }
      """

    # Create the target timer.
    Given path 'scheduler/timers'
    And request targetTimerRequest
    When method POST
    Then status 201
    And match response.id == targetTimerId
    And match response.type == 'user'
    And match response.enabled == true

    # Build a second USER timer that deletes the target timer after one second.
    * def deleteTimerId = uuid()
    * def deleteTimerPath = '/scheduler/timers/' + targetTimerId
    * def deleteTimerRequest =
      """
      {
        "id": "#(deleteTimerId)",
        "type": "user",
        "enabled": true,
        "moduleName": "mod-scheduler",
        "routingEntry": {
          "methods": [ "DELETE" ],
          "pathPattern": "#(deleteTimerPath)",
          "unit": "second",
          "delay": "1"
        }
      }
      """

    # Create the deletion timer with a one-second delay.
    Given path 'scheduler/timers'
    And request deleteTimerRequest
    When method POST
    Then status 201
    And match response.id == deleteTimerId
    And match response.type == 'user'
    And match response.enabled == true
    And match response.moduleName == 'mod-scheduler'
    And match response.routingEntry.pathPattern == deleteTimerPath
    And match response.routingEntry.delay == '1'
    And match response.routingEntry.unit == 'second'

    # Poll until the scheduled DELETE request has removed the target timer.
    Given path 'scheduler/timers', targetTimerId
    And retry until responseStatus == 404
    When method GET
    Then status 404

    # Clean up the deletion timer.
    Given path 'scheduler/timers', deleteTimerId
    When method DELETE
    Then status 204
