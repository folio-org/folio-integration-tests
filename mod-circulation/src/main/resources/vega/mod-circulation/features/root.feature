Feature: Root feature that runs all other mod-circulation features

  Background:
    * call read('classpath:vega/mod-circulation/features/root-setup.feature')

  Scenario: Run all mod-circulation features
    * call read('classpath:common/eureka/keycloak.feature@configureAccessTokenTime') { 'AccessTokenLifespance' : 3600 }
    * call read('classpath:vega/mod-circulation/features/loans.feature')
    * call read('classpath:vega/mod-circulation/features/requests.feature')
    * call read('classpath:vega/mod-circulation/features/print-events.feature')
    * call read('classpath:vega/mod-circulation/features/retrival-service-point.feature')
