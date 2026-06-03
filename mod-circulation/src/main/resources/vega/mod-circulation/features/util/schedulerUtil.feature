Feature: scheduler utility for mod-circulation

  Background:
    * url baseUrl

  @UpdateAgeToLostTimer
  Scenario: find age-to-lost timer and update its delay
    # extSidecarToken  - required: sidecar-module-access-client Bearer token
    # extUnit          - required: delay unit ('second' or 'minute')
    # extDelay         - required: delay value (e.g. '1' or '30')
    # extTimerId       - optional: if provided, skip timer lookup
    # extModuleId      - optional: required when extTimerId is provided
    # extModuleName    - optional: required when extTimerId is provided

    * def lookupNeeded = !karate.get('extTimerId')

    # find age-to-lost timer when ID is not already known
    * if (lookupNeeded) karate.call('classpath:vega/mod-circulation/features/util/schedulerUtil.feature@FindAgeToLostTimer', { extSidecarToken: extSidecarToken })
    * def currentTimerId    = lookupNeeded ? foundTimerId    : extTimerId
    * def currentModuleId   = lookupNeeded ? foundModuleId   : extModuleId
    * def currentModuleName = lookupNeeded ? foundModuleName : extModuleName

    # build and send the timer update request
    * def ageToLostTimerRequest = read('classpath:vega/mod-circulation/features/samples/change-age-to-lost-processor-delay-time.json')
    * ageToLostTimerRequest.id = currentTimerId
    * ageToLostTimerRequest.moduleId = currentModuleId
    * ageToLostTimerRequest.moduleName = currentModuleName
    * ageToLostTimerRequest.routingEntry.unit = extUnit
    * ageToLostTimerRequest.routingEntry.delay = extDelay
    Given path '/scheduler/timers', currentTimerId
    And request ageToLostTimerRequest
    And header Authorization = 'Bearer ' + extSidecarToken
    And header x-okapi-token = extSidecarToken
    And header x-okapi-tenant = testTenant
    When method PUT
    Then status 200

  @FindAgeToLostTimer
  Scenario: find age-to-lost scheduler timer using a sidecar token
    # extSidecarToken - required: sidecar-module-access-client Bearer token

    Given path '/scheduler/timers'
    And param limit = 500
    And header Authorization = 'Bearer ' + extSidecarToken
    And header x-okapi-token = extSidecarToken
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def ageToLostTimers = karate.filter(response.timerDescriptors, function(m){ return m.routingEntry && m.routingEntry.pathPattern == '/circulation/scheduled-age-to-lost' })
    * print 'age-to-lost timers found with sidecar token:', ageToLostTimers.length
    * if (ageToLostTimers.length == 0) karate.abort()
    * def foundTimerId    = ageToLostTimers[0].id
    * def foundModuleId   = ageToLostTimers[0].moduleId
    * def foundModuleName = ageToLostTimers[0].moduleName

