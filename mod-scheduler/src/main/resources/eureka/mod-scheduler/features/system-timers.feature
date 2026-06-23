Feature: scheduler system timers

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: allow system timer mutation through scheduler APIs when SCHEDULER_API_ALLOW_SYSTEM_TIMER_MUTATION is enabled
    # SCHEDULER_API_ALLOW_SYSTEM_TIMER_MUTATION is enabled in karate environment, so system timers can be mutated via scheduler APIs.
    * def futureSchedule = { cron: '0 0 0 1 1 ? 2099', zone: 'UTC' }
    * def timerId = uuid()
    * def suffix = nowMillis()
    * def moduleName = 'mod-scheduler-karate-system-' + suffix
    * def moduleId = moduleName + '-1.0.0'
    * def timerPath = '/mod-scheduler-karate/' + suffix + '/system-api-timer'
    * def systemTimerRequest =
      """
      {
        "id": "#(timerId)",
        "type": "system",
        "enabled": false,
        "moduleId": "#(moduleId)",
        "routingEntry": {
          "methods": [ "POST" ],
          "pathPattern": "#(timerPath)",
          "schedule": "#(futureSchedule)"
        }
      }
      """

    # Create the SYSTEM timer and verify persisted descriptor fields.
    Given path 'scheduler/timers'
    And request systemTimerRequest
    When method POST
    Then status 201
    And match response.id == timerId
    And match response.type == 'system'
    And match response.enabled == false
    And match response.moduleId == moduleId
    And match response.moduleName == moduleName
    And match response.routingEntry.pathPattern == timerPath
    And match response.routingEntry.schedule == futureSchedule

    # Update the SYSTEM timer.
    * set systemTimerRequest.enabled = true
    Given path 'scheduler/timers', timerId
    And request systemTimerRequest
    When method PUT
    Then status 200
    And match response.id == timerId
    And match response.enabled == true
    And match response.modified == true

    # Delete the SYSTEM timer.
    Given path 'scheduler/timers', timerId
    When method DELETE
    Then status 204

    # Verify the deleted timer is no longer available.
    Given path 'scheduler/timers', timerId
    When method GET
    Then status 404

  @Positive
  Scenario: verify scheduler timers collection is reachable
    Given path 'scheduler/timers'
    When method GET
    Then status 200
    And match response.timerDescriptors == '#array'
    And match response.totalRecords == '#number'

  @Positive
  Scenario: register mod-users system timers from scheduled-job events
    * configure retry = { count: 10, interval: 5000 }
    Given path 'scheduler/timers'
    And param limit = 500
    And retry until responseStatus == 200 && karate.filter(response.timerDescriptors, timer => timer.moduleName == 'mod-users').length >= 3
    When method GET
    Then status 200

    * def userTimers = karate.filter(response.timerDescriptors, timer => timer.moduleName == 'mod-users' && timer.type == 'system')

    * def expireUserTimers = karate.filter(userTimers, timer => timer.routingEntry.pathPattern == '/users/expire/timer')
    And match expireUserTimers == '#[1]'
    And match expireUserTimers[0] contains { enabled: true, moduleId: '#regex ^mod-users-.*' }
    And match expireUserTimers[0].routingEntry contains { methods: [ 'POST' ], unit: 'minute', delay: '1' }

    * def outboxProcessTimers = karate.filter(userTimers, timer => timer.routingEntry.pathPattern == '/users/outbox/process')
    And match outboxProcessTimers == '#[1]'
    And match outboxProcessTimers[0] contains { enabled: true, moduleId: '#regex ^mod-users-.*' }
    And match outboxProcessTimers[0].routingEntry contains { methods: [ 'POST' ], unit: 'minute', delay: '30' }

    * def profilePictureCleanupTimers = karate.filter(userTimers, timer => timer.routingEntry.pathPattern == '/users/profile-picture/cleanup')
    And match profilePictureCleanupTimers == '#[1]'
    And match profilePictureCleanupTimers[0] contains { enabled: true, moduleId: '#regex ^mod-users-.*' }
    And match profilePictureCleanupTimers[0].routingEntry contains { methods: [ 'POST' ], unit: 'hour', delay: '24' }
