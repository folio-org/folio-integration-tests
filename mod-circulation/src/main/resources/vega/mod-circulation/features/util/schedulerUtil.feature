Feature: scheduler utility for mod-circulation

  Background:
    * url baseUrl
    * configure headers = null

  @UpdateAgeToLostTimer
  Scenario: find age-to-lost timer and update its delay
    # extToken       - required: okapi token with scheduler.item.get and scheduler.item.put permissions
    # extUnit        - required: delay unit ('second' or 'minute')
    # extDelay       - required: delay value (e.g. '1' or '30')
    # extTimerId     - optional: if provided, skip timer lookup
    # extModuleId    - optional: required when extTimerId is provided
    # extModuleName  - optional: required when extTimerId is provided

    * def lookupNeeded = !karate.get('extTimerId')

    # find age-to-lost timer when ID is not already known
    * def currentTimerId    = karate.get('extTimerId')
    * def currentModuleId   = karate.get('extModuleId')
    * def currentModuleName = karate.get('extModuleName')

    * if (lookupNeeded) karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@FindAgeToLostTimer', { extToken: extToken })

    # build and send the timer update request
    * def ageToLostTimerRequest = read('classpath:vega/mod-circulation/features/samples/change-age-to-lost-processor-delay-time.json')
    * ageToLostTimerRequest.id = currentTimerId
    * ageToLostTimerRequest.moduleId = currentModuleId
    * ageToLostTimerRequest.moduleName = currentModuleName
    * ageToLostTimerRequest.routingEntry.unit = extUnit
    * ageToLostTimerRequest.routingEntry.delay = extDelay
    Given path '/scheduler/timers', currentTimerId
    And request ageToLostTimerRequest
    And header x-okapi-token = extToken
    And header x-okapi-tenant = testTenant
    And header Content-Type = 'application/json'
    When method PUT
    Then status 200

  @FindAgeToLostTimer
  Scenario: find age-to-lost scheduler timer
    # extToken - required: okapi token with scheduler.collection.get permission

    Given path '/scheduler/timers'
    And param limit = 500
    And header x-okapi-token = extToken
    And header x-okapi-tenant = testTenant
    And header Content-Type = 'application/json'
    When method GET
    Then status 200
    * print 'all timers:', response
    * def ageToLostTimers = karate.filter(response.timerDescriptors, function(m){ return m.routingEntry && m.routingEntry.pathPattern == '/circulation/scheduled-age-to-lost' })
    * print 'age-to-lost timers found:', ageToLostTimers.length
    * if (ageToLostTimers.length == 0) karate.abort()
    * def currentTimerId    = ageToLostTimers[0].id
    * def currentModuleId   = ageToLostTimers[0].moduleId
    * def currentModuleName = ageToLostTimers[0].moduleName
