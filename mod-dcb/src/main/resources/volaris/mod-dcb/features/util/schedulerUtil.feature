Feature: scheduler utility for mod-dcb (request-expiration timer)

  Background:
    * url baseUrl
    * configure headers = null

  @UpdateRequestExpirationTimer
  Scenario: find request-expiration timer and update its delay
    # extToken       - required: sidecar-module-access-client Bearer token
    # extUnit        - required: delay unit ('second' or 'minute')
    # extDelay       - required: delay value (e.g. '1' or '30')
    # extTimerId     - optional: if provided, skip timer lookup
    # extModuleId    - optional: required when extTimerId is provided
    # extModuleName  - optional: required when extTimerId is provided

    * def lookupNeeded = !karate.get('extTimerId')

    # find (or create) request-expiration timer when ID is not already known
    * def currentTimerId      = karate.get('extTimerId')
    * def currentModuleId     = karate.get('extModuleId')
    * def currentModuleName   = karate.get('extModuleName')
    * def currentTimerCreated = false

    * if (lookupNeeded) karate.call(true, 'classpath:volaris/mod-dcb/features/util/schedulerUtil.feature@FindOrCreateRequestExpirationTimer', { extToken: extToken, extUnit: extUnit, extDelay: extDelay })

    # update delay only when timer already existed (created timers already have the desired delay)
    * if (!currentTimerCreated) karate.call(true, 'classpath:volaris/mod-dcb/features/util/schedulerUtil.feature@PutRequestExpirationTimer', { extToken: extToken, extTimerId: currentTimerId, extModuleId: currentModuleId, extModuleName: currentModuleName, extUnit: extUnit, extDelay: extDelay })

  @FindOrCreateRequestExpirationTimer
  Scenario: find request-expiration scheduler timer, or create it if not registered
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
    * def requestExpirationTimers = karate.filter(response.timerDescriptors, function(m){ return m.routingEntry && m.routingEntry.pathPattern == '/scheduled-request-expiration' })
    * print 'request-expiration timers found with sidecar token:', requestExpirationTimers.length

    * def timerFound = requestExpirationTimers.length > 0
    * def currentTimerId    = timerFound ? requestExpirationTimers[0].id         : null
    * def currentModuleId   = timerFound ? requestExpirationTimers[0].moduleId   : null
    * def currentModuleName = timerFound ? requestExpirationTimers[0].moduleName : null

    # create the timer if not registered (fallback for environments without Kafka-registered timer)
    * if (!timerFound) karate.call(true, 'classpath:volaris/mod-dcb/features/util/schedulerUtil.feature@CreateRequestExpirationTimer', { extToken: extToken, extUnit: extUnit, extDelay: extDelay })

  @CreateRequestExpirationTimer
  Scenario: create request-expiration scheduler timer via REST
    # extToken - required: sidecar-module-access-client Bearer token
    # extUnit  - required: delay unit
    # extDelay - required: delay value

    * def newTimer = { type: 'system', enabled: true, moduleName: 'mod-circulation-storage', routingEntry: { methods: ['POST'], pathPattern: '/scheduled-request-expiration', unit: '#(extUnit)', delay: '#(extDelay)' } }
    Given path '/scheduler/timers'
    And request newTimer
    And header Authorization = 'Bearer ' + extToken
    And header x-okapi-tenant = testTenant
    And header Content-Type = 'application/json'
    When method POST
    Then status 201
    * def currentTimerId      = response.id
    * def currentModuleId     = response.moduleId
    * def currentModuleName   = response.moduleName
    * def currentTimerCreated = true

  @PutRequestExpirationTimer
  Scenario: update request-expiration timer delay
    # extToken      - required: sidecar-module-access-client Bearer token
    # extTimerId    - required
    # extModuleId   - required
    # extModuleName - required
    # extUnit       - required
    # extDelay      - required

    * def timerRequest = { id: '#(extTimerId)', type: 'system', enabled: true, moduleId: '#(extModuleId)', moduleName: '#(extModuleName)', routingEntry: { methods: ['POST'], pathPattern: '/scheduled-request-expiration', unit: '#(extUnit)', delay: '#(extDelay)' } }
    Given path '/scheduler/timers', extTimerId
    And request timerRequest
    And header Authorization = 'Bearer ' + extToken
    And header x-okapi-tenant = testTenant
    And header Content-Type = 'application/json'
    When method PUT
    Then status 200

  @DeleteRequestExpirationTimer
  Scenario: delete request-expiration scheduler timer
    # extToken   - required: sidecar-module-access-client Bearer token
    # extTimerId - required

    Given path '/scheduler/timers', extTimerId
    And header Authorization = 'Bearer ' + extToken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204
