Feature: scheduler utility for mod-circulation

  Background:
    * url baseUrl
    * configure headers = null

  @UpdateAgeToLostTimer
  Scenario: find age-to-lost timer and update its delay
    # extToken       - required: sidecar-module-access-client Bearer token
    # extUnit        - required: delay unit ('second' or 'minute')
    # extDelay       - required: delay value (e.g. '1' or '30')
    # extTimerId     - optional: if provided, skip timer lookup
    # extModuleId    - optional: required when extTimerId is provided
    # extModuleName  - optional: required when extTimerId is provided

    * def lookupNeeded = !karate.get('extTimerId')

    # find (or create) age-to-lost timer when ID is not already known
    * def currentTimerId      = karate.get('extTimerId')
    * def currentModuleId     = karate.get('extModuleId')
    * def currentModuleName   = karate.get('extModuleName')
    * def currentTimerCreated = false

    * if (lookupNeeded) karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@FindOrCreateAgeToLostTimer', { extToken: extToken, extUnit: extUnit, extDelay: extDelay })

    # skip PUT when timer was just created (already at the requested delay)
    * def skipPut = currentTimerCreated

    # build and send the timer update request (only when updating an existing timer)
    * if (!skipPut) karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@PutAgeToLostTimer', { extToken: extToken, extTimerId: currentTimerId, extModuleId: currentModuleId, extModuleName: currentModuleName, extUnit: extUnit, extDelay: extDelay })

  @FindOrCreateAgeToLostTimer
  Scenario: find age-to-lost scheduler timer, or create it if not registered
    # extToken - required: sidecar-module-access-client Bearer token
    # extUnit  - required: delay unit to use when creating
    # extDelay - required: delay value to use when creating

    Given path '/scheduler/timers'
    And param limit = 500
    And header Authorization = 'Bearer ' + extToken
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * print 'all timers:', response
    * def ageToLostTimers = karate.filter(response.timerDescriptors, function(m){ return m.routingEntry && m.routingEntry.pathPattern == '/circulation/scheduled-age-to-lost' })
    * print 'age-to-lost timers found with sidecar token:', ageToLostTimers.length

    * def timerFound = ageToLostTimers.length > 0
    * def currentTimerId    = timerFound ? ageToLostTimers[0].id         : null
    * def currentModuleId   = timerFound ? ageToLostTimers[0].moduleId   : null
    * def currentModuleName = timerFound ? ageToLostTimers[0].moduleName : null
    * def currentTimerCreated = false

    # create the timer if not registered (fallback for environments without Kafka-registered timer)
    * if (!timerFound) karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@CreateAgeToLostTimer', { extToken: extToken, extUnit: extUnit, extDelay: extDelay })

  @CreateAgeToLostTimer
  Scenario: create age-to-lost scheduler timer via REST
    # extToken - required: sidecar-module-access-client Bearer token
    # extUnit  - required: delay unit
    # extDelay - required: delay value

    * def newTimer = { type: 'system', enabled: true, moduleName: 'mod-circulation', routingEntry: { methods: ['POST'], pathPattern: '/circulation/scheduled-age-to-lost', unit: '#(extUnit)', delay: '#(extDelay)' } }
    Given path '/scheduler/timers'
    And request newTimer
    And header Authorization = 'Bearer ' + extToken
    And header x-okapi-tenant = testTenant
    And header Content-Type = 'application/json'
    When method POST
    Then status 201
    * def currentTimerId    = response.id
    * def currentModuleId   = response.moduleId
    * def currentModuleName = response.moduleName
    * def currentTimerCreated = true

  @PutAgeToLostTimer
  Scenario: update age-to-lost timer delay
    # extToken      - required: sidecar-module-access-client Bearer token
    # extTimerId    - required
    # extModuleId   - required
    # extModuleName - required
    # extUnit       - required
    # extDelay      - required

    * def ageToLostTimerRequest = read('classpath:vega/mod-circulation/features/samples/change-age-to-lost-processor-delay-time.json')
    * ageToLostTimerRequest.id = extTimerId
    * ageToLostTimerRequest.moduleId = extModuleId
    * ageToLostTimerRequest.moduleName = extModuleName
    * ageToLostTimerRequest.routingEntry.unit = extUnit
    * ageToLostTimerRequest.routingEntry.delay = extDelay
    Given path '/scheduler/timers', extTimerId
    And request ageToLostTimerRequest
    And header Authorization = 'Bearer ' + extToken
    And header x-okapi-tenant = testTenant
    And header Content-Type = 'application/json'
    When method PUT
    Then status 200

  @DeleteAgeToLostTimer
  Scenario: delete age-to-lost scheduler timer
    # extToken   - required: sidecar-module-access-client Bearer token
    # extTimerId - required

    Given path '/scheduler/timers', extTimerId
    And header Authorization = 'Bearer ' + extToken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204
