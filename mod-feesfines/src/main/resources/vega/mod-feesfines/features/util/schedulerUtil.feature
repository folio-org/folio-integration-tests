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

  @SetTimerByPath
  Scenario: find scheduler timer by path pattern and set its delay, or create it if not registered
    # extToken       - required: sidecar-module-access-client Bearer token
    # extPathPattern - required: routing entry path pattern, e.g. '/circulation/scheduled-age-to-lost'
    # extUnit        - required: delay unit ('second' or 'minute')
    # extDelay       - required: delay value
    # returns: currentTimerId, currentTimerCreated, originalTimer (null when the timer was created)

    Given path '/scheduler/timers'
    And param limit = 500
    And header Authorization = 'Bearer ' + extToken
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def foundTimers = karate.filter(response.timerDescriptors, function(t){ return t.routingEntry && t.routingEntry.pathPattern == extPathPattern })
    * def timerFound = foundTimers.length > 0
    * def originalTimer = timerFound ? foundTimers[0] : null
    * def currentTimerId = timerFound ? foundTimers[0].id : null
    * def currentTimerCreated = !timerFound

    * def newRoutingEntry = { methods: ['POST'], pathPattern: '#(extPathPattern)', unit: '#(extUnit)', delay: '#(extDelay)' }
    * def newTimer = { type: 'system', enabled: true, moduleName: 'mod-circulation', routingEntry: '#(newRoutingEntry)' }
    * if (timerFound) newTimer.id = foundTimers[0].id
    * if (timerFound) newTimer.moduleId = foundTimers[0].moduleId
    * if (timerFound) newTimer.moduleName = foundTimers[0].moduleName

    * if (timerFound) karate.call(true, 'classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@PutTimer', { extToken: extToken, extTimer: newTimer })
    * if (!timerFound) karate.call(true, 'classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@PostTimer', { extToken: extToken, extTimer: newTimer })

  @PutTimer
  Scenario: update scheduler timer from a full timer descriptor
    # extToken - required
    # extTimer - required: timer descriptor, must contain id

    Given path '/scheduler/timers', extTimer.id
    And request extTimer
    And header Authorization = 'Bearer ' + extToken
    And header x-okapi-tenant = testTenant
    And header Content-Type = 'application/json'
    When method PUT
    Then status 200

  @PostTimer
  Scenario: create scheduler timer from a timer descriptor
    # extToken - required
    # extTimer - required: timer descriptor
    # returns: currentTimerId

    Given path '/scheduler/timers'
    And request extTimer
    And header Authorization = 'Bearer ' + extToken
    And header x-okapi-tenant = testTenant
    And header Content-Type = 'application/json'
    When method POST
    Then status 201
    * def currentTimerId = response.id

  @RestoreTimer
  Scenario: restore a timer changed by SetTimerByPath (delete it if it was created, otherwise put the original back)
    # extToken        - required
    # extTimerId      - required
    # extTimerCreated - required: true when SetTimerByPath created the timer
    # extOriginalTimer - required when extTimerCreated is false

    * if (extTimerCreated) karate.call(true, 'classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@DeleteActualCostExpirationTimer', { extToken: extToken, extTimerId: extTimerId })
    * if (!extTimerCreated) karate.call(true, 'classpath:vega/mod-feesfines/features/util/schedulerUtil.feature@PutTimer', { extToken: extToken, extTimer: extOriginalTimer })

