Feature: scheduler system timers

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }

  @Negative
  Scenario: reject system timer creation through scheduler APIs
    * def futureSchedule = { cron: '0 0 0 1 1 ? 2099', zone: 'UTC' }
    * def timerId = uuid()
    * def suffix = nowMillis()
    * def systemTimerRequest =
      """
      {
        "id": "#(timerId)",
        "type": "system",
        "enabled": false,
        "moduleId": "#('mod-scheduler-karate-system-' + suffix + '-1.0.0')",
        "routingEntry": {
          "methods": [ "POST" ],
          "pathPattern": "#('/mod-scheduler-karate/' + suffix + '/system-api-timer')",
          "schedule": "#(futureSchedule)"
        }
      }
      """

    Given path 'scheduler/timers'
    And request systemTimerRequest
    When method POST
    Then status 400
    And match response.errors[0].code == 'validation_error'
    And match response.errors[0].parameters contains { key: 'type', value: 'SYSTEM' }

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

    # Verify public API protects SYSTEM timers from deletion.
    Given path 'scheduler/timers', expireUserTimers[0].id
    When method DELETE
    Then status 400
    And match response.errors[0].code == 'validation_error'
    And match response.errors[0].parameters contains { key: 'type', value: 'SYSTEM' }
