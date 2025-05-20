Feature: Root feature that runs all other mod-data-export-spring features

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce variables

    * def nextZonedTimeAsLocaleSettings = read('util/get-next-time-function.js')
    * def currentDayOfWeek = read('util/get-day-of-week-function.js')
    * def waitIfNecessary = read('util/determine-if-wait-necessary-function.js')

  Scenario: Edifact Orders Export
    * call read('classpath:thunderjet/mod-data-export-spring/features/edifact-orders-export.feature')

  Scenario: Claims Export
    * call read('classpath:thunderjet/mod-data-export-spring/features/claims-export.feature')
