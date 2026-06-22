Feature: scheduler utility for mod-circulation

  Background:
    * url baseUrl
    * configure headers = null

  # ─── Generic timer scenarios (building blocks) ───────────────────────────────

  @FindOrCreateTimer
  Scenario: find a circulation scheduler timer, or create it if not registered
    # extToken       - required: sidecar-module-access-client Bearer token
    # extUnit        - required: delay unit to use when creating
    # extDelay       - required: delay value to use when creating
    # extPathPattern - required: timer routing entry path pattern

    * print '@FindOrCreateTimer: ' + extToken
    Given path '/scheduler/timers'
    And param limit = 500
    And header Authorization = 'Bearer ' + extToken
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * print 'all timers:', response
    * def matchingTimers = karate.filter(response.timerDescriptors, function(m){ return m.routingEntry && m.routingEntry.pathPattern == extPathPattern })
    * print 'timers found for ' + extPathPattern + ':', matchingTimers.length

    * def timerFound   = matchingTimers.length > 0
    * def currentTimer = timerFound ? matchingTimers[0] : null

    # create the timer if not registered (fallback for environments without Kafka-registered timer)
    * if (!timerFound) karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@CreateTimer', { extToken: extToken, extUnit: extUnit, extDelay: extDelay, extPathPattern: extPathPattern })

  @CreateTimer
  Scenario: create a circulation scheduler timer via REST
    # extToken       - required: sidecar-module-access-client Bearer token
    # extUnit        - required: delay unit
    # extDelay       - required: delay value
    # extPathPattern - required: timer routing entry path pattern

    * print '@CreateTimer: ' + extToken
    * def newTimer = { type: 'system', enabled: true, moduleName: 'mod-circulation', routingEntry: { methods: ['POST'], pathPattern: '#(extPathPattern)', unit: '#(extUnit)', delay: '#(extDelay)' } }
    Given path '/scheduler/timers'
    And request newTimer
    And header Authorization = 'Bearer ' + extToken
    And header x-okapi-tenant = testTenant
    And header Content-Type = 'application/json'
    When method POST
    Then status 201
    * def currentTimer        = response
    * def currentTimerCreated = true

  @PutTimer
  Scenario: update a circulation timer delay
    # extToken  - required: sidecar-module-access-client Bearer token
    # extTimer  - required: full timer JSON body (as returned by GET /scheduler/timers)
    # extUnit   - required
    # extDelay  - required

    * print '@PutTimer: ' + extToken
    * def timerRequest = extTimer
    * timerRequest.routingEntry.unit = extUnit
    * timerRequest.routingEntry.delay = extDelay
    Given path '/scheduler/timers', extTimer.id
    And request timerRequest
    And header Authorization = 'Bearer ' + extToken
    And header x-okapi-tenant = testTenant
    And header Content-Type = 'application/json'
    When method PUT
    Then status 200

  @DeleteTimer
  Scenario: delete a circulation scheduler timer
    # extToken   - required: sidecar-module-access-client Bearer token
    # extTimerId - required

    * print '@DeleteTimer: ' + extToken
    Given path '/scheduler/timers', extTimerId
    And header Authorization = 'Bearer ' + extToken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

  # ─── Age-to-lost timer scenarios ──────────────────────────────────────────────

  @UpdateAgeToLostTimer
  Scenario: find age-to-lost timer and update its delay
    # extToken - required: sidecar-module-access-client Bearer token
    # extUnit  - required: delay unit ('second' or 'minute')
    # extDelay - required: delay value (e.g. '1' or '30')
    # extTimer - optional: if provided, skip timer lookup (full timer JSON body)

    * print '@UpdateAgeToLostTimer: ' + extToken
    * def lookupNeeded = !karate.get('extTimer')

    # find (or create) age-to-lost timer when ID is not already known
    * def currentTimer        = karate.get('extTimer')
    * def currentTimerCreated = false

    * if (lookupNeeded) karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@FindOrCreateAgeToLostTimer', { extToken: extToken, extUnit: extUnit, extDelay: extDelay })

    # update delay only when timer already existed (created timers already have the desired delay)
    * if (!currentTimerCreated) karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@PutAgeToLostTimer', { extToken: extToken, extTimer: currentTimer, extUnit: extUnit, extDelay: extDelay })

  @FindOrCreateAgeToLostTimer
  Scenario: find age-to-lost scheduler timer, or create it if not registered
    # extToken - required: sidecar-module-access-client Bearer token
    # extUnit  - required: delay unit to use when creating
    # extDelay - required: delay value to use when creating

    * print '@FindOrCreateAgeToLostTimer: ' + extToken
    * karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@FindOrCreateTimer', { extToken: extToken, extUnit: extUnit, extDelay: extDelay, extPathPattern: '/circulation/scheduled-age-to-lost' })

  @CreateAgeToLostTimer
  Scenario: create age-to-lost scheduler timer via REST
    # extToken - required: sidecar-module-access-client Bearer token
    # extUnit  - required: delay unit
    # extDelay - required: delay value

    * print '@CreateAgeToLostTimer: ' + extToken
    * karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@CreateTimer', { extToken: extToken, extUnit: extUnit, extDelay: extDelay, extPathPattern: '/circulation/scheduled-age-to-lost' })

  @PutAgeToLostTimer
  Scenario: update age-to-lost timer delay
    # extToken  - required: sidecar-module-access-client Bearer token
    # extTimer  - required: full timer JSON body (as returned by GET /scheduler/timers)
    # extUnit   - required
    # extDelay  - required

    * print '@PutAgeToLostTimer: ' + extToken
    * karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@PutTimer', { extToken: extToken, extTimer: extTimer, extUnit: extUnit, extDelay: extDelay })

  @DeleteAgeToLostTimer
  Scenario: delete age-to-lost scheduler timer
    # extToken   - required: sidecar-module-access-client Bearer token
    # extTimerId - required

    * print '@DeleteAgeToLostTimer: ' + extToken
    * karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@DeleteTimer', { extToken: extToken, extTimerId: extTimerId })

  # ─── Loan-anonymization timer scenarios ───────────────────────────────────────

  @UpdateLoanAnonymizationTimer
  Scenario: find loan-anonymization timer and update its delay
    # extToken - required: sidecar-module-access-client Bearer token
    # extUnit  - required: delay unit ('second' or 'minute')
    # extDelay - required: delay value (e.g. '1' or '30')
    # extTimer - optional: if provided, skip timer lookup (full timer JSON body)

    * print '@UpdateLoanAnonymizationTimer: ' + extToken
    * def lookupNeeded = !karate.get('extTimer')

    # find (or create) loan-anonymization timer when ID is not already known
    * def currentTimer        = karate.get('extTimer')
    * def currentTimerCreated = false

    * if (lookupNeeded) karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@FindOrCreateLoanAnonymizationTimer', { extToken: extToken, extUnit: extUnit, extDelay: extDelay })

    # update delay only when timer already existed (created timers already have the desired delay)
    * if (!currentTimerCreated) karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@PutLoanAnonymizationTimer', { extToken: extToken, extTimer: currentTimer, extUnit: extUnit, extDelay: extDelay })

  @FindOrCreateLoanAnonymizationTimer
  Scenario: find loan-anonymization scheduler timer, or create it if not registered
    # extToken - required: sidecar-module-access-client Bearer token
    # extUnit  - required: delay unit to use when creating
    # extDelay - required: delay value to use when creating

    * print '@FindOrCreateLoanAnonymizationTimer: ' + extToken
    * karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@FindOrCreateTimer', { extToken: extToken, extUnit: extUnit, extDelay: extDelay, extPathPattern: '/circulation/scheduled-anonymize-processing' })

  @CreateLoanAnonymizationTimer
  Scenario: create loan-anonymization scheduler timer via REST
    # extToken - required: sidecar-module-access-client Bearer token
    # extUnit  - required: delay unit
    # extDelay - required: delay value

    * print '@CreateLoanAnonymizationTimer: ' + extToken
    * karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@CreateTimer', { extToken: extToken, extUnit: extUnit, extDelay: extDelay, extPathPattern: '/circulation/scheduled-anonymize-processing' })

  @PutLoanAnonymizationTimer
  Scenario: update loan-anonymization timer delay
    # extToken  - required: sidecar-module-access-client Bearer token
    # extTimer  - required: full timer JSON body (as returned by GET /scheduler/timers)
    # extUnit   - required
    # extDelay  - required

    * print '@PutLoanAnonymizationTimer: ' + extToken
    * karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@PutTimer', { extToken: extToken, extTimer: extTimer, extUnit: extUnit, extDelay: extDelay })

  @DeleteLoanAnonymizationTimer
  Scenario: delete loan-anonymization scheduler timer
    # extToken   - required: sidecar-module-access-client Bearer token
    # extTimerId - required

    * print '@DeleteLoanAnonymizationTimer: ' + extToken
    * karate.call(true, 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature@DeleteTimer', { extToken: extToken, extTimerId: extTimerId })
