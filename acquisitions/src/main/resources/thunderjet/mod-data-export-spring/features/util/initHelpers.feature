Feature: Shared init for mod-data-export-spring test features
  Loads global variables used across data-export-spring scenarios.

  Scenario: init
    * callonce variables

    * def nextZonedTimeAsLocaleSettings = read('classpath:thunderjet/mod-data-export-spring/features/util/get-next-time-function.js')
    * def currentDayOfWeek = read('classpath:thunderjet/mod-data-export-spring/features/util/get-day-of-week-function.js')
    * def waitIfNecessary = read('classpath:thunderjet/mod-data-export-spring/features/util/determine-if-wait-necessary-function.js')

