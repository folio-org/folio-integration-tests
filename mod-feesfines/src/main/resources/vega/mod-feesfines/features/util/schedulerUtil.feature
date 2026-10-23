Feature: scheduler utility for mod-feesfines

  Background:
    * url baseUrl
    * configure headers = null

  @UpdateActualCostExpirationTimer
  Scenario: find actual-cost-expiration-by-timeout timer and update its delay
    # extToken       - required: sidecar-module-access-client Bearer token
    # extUnit        - required: delay unit ('second' or 'minute')
    # extDelay       - required: delay value (e.g. '1' or '20')
    # extTimerId     - optional: if provided, skip timer lookup
    # extModuleId    - optional: required when extTimerId is provided
    # extModuleName  - optional: required when extTimerId is provided

    * def lookupNeeded = !karate.get('extTimerId')

    # find (or create) timer when ID is not already known
    * def currentTimerId      = karate.get('extTimerId')
    * def currentModuleId     = karate.get('extModuleId')
    * def currentModuleName   = karate.get('extModuleName')
    * def currentTimerCreated = false

    * if (lookupNeeded) karate.call(true, 'classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@FindOrCreateActualCostExpirationTimer', { extToken: extToken, extUnit: extUnit, extDelay: extDelay })

    # update delay only when timer already existed (created timers already have the desired delay)
    * if (!currentTimerCreated) karate.call(true, 'classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@PutActualCostExpirationTimer', { extToken: extToken, extTimerId: currentTimerId, extModuleId: currentModuleId, extModuleName: currentModuleName, extUnit: extUnit, extDelay: extDelay })

  @FindOrCreateActualCostExpirationTimer
  Scenario: find actual-cost-expiration-by-timeout scheduler timer, or create it if not registered
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
    * def expirationTimers = karate.filter(response.timerDescriptors, function(m){ return m.routingEntry && m.routingEntry.pathPattern == '/circulation/actual-cost-expiration-by-timeout' })
    * print 'actual-cost-expiration-by-timeout timers found:', expirationTimers.length

    * def timerFound = expirationTimers.length > 0
    * def currentTimerId    = timerFound ? expirationTimers[0].id         : null
    * def currentModuleId   = timerFound ? expirationTimers[0].moduleId   : null
    * def currentModuleName = timerFound ? expirationTimers[0].moduleName : null

    # create the timer if not registered (fallback for environments without Kafka-registered timer)
    * if (!timerFound) karate.call(true, 'classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@CreateActualCostExpirationTimer', { extToken: extToken, extUnit: extUnit, extDelay: extDelay })

  @CreateActualCostExpirationTimer
  Scenario: create actual-cost-expiration-by-timeout scheduler timer via REST
    # extToken - required: sidecar-module-access-client Bearer token
    # extUnit  - required: delay unit
    # extDelay - required: delay value

    * def newTimer = { type: 'system', enabled: true, moduleName: 'mod-circulation', routingEntry: { methods: ['POST'], pathPattern: '/circulation/actual-cost-expiration-by-timeout', unit: '#(extUnit)', delay: '#(extDelay)' } }
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

  @PutActualCostExpirationTimer
  Scenario: update actual-cost-expiration-by-timeout timer delay
    # extToken      - required: sidecar-module-access-client Bearer token
    # extTimerId    - required
    # extModuleId   - required
    # extModuleName - required
    # extUnit       - required
    # extDelay      - required

    * def timerRequest = read('classpath:vega/mod-feesfines/features/samples/update-timer-request.json')
    * timerRequest.id = extTimerId
    * timerRequest.moduleId = extModuleId
    * timerRequest.moduleName = extModuleName
    * timerRequest.routingEntry.unit = extUnit
    * timerRequest.routingEntry.delay = extDelay
    Given path '/scheduler/timers', extTimerId
    And request timerRequest
    And header Authorization = 'Bearer ' + extToken
    And header x-okapi-tenant = testTenant
    And header Content-Type = 'application/json'
    When method PUT
    Then status 200

  @DeleteActualCostExpirationTimer
  Scenario: delete actual-cost-expiration-by-timeout scheduler timer
    # extToken   - required: sidecar-module-access-client Bearer token
    # extTimerId - required

    Given path '/scheduler/timers', extTimerId
    And header Authorization = 'Bearer ' + extToken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

