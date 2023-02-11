Feature: post holdings

  Background:
    * url baseUrl
    * callonce variables
    * callonce login testAdmin

  Scenario: Create holdings
    * def servicePoints = karate.read('classpath:samples/holdings/service-points.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostServicePoints') servicePoints

    * def institutions = karate.read('classpath:samples/holdings/institutions.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostInstitutions') institutions

    * def campuses = karate.read('classpath:samples/holdings/campuses.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostCampuses') campuses

    * def libraries = karate.read('classpath:samples/holdings/libraries.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostLibraries') libraries

    * def location_main = karate.read('classpath:samples/holdings/location_main.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostLocationMain') location_main

    * def location_popular_reading = karate.read('classpath:samples/holdings/location_popular_reading.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostLocationPopularReading') location_popular_reading

    * def identifierTypes = karate.read('classpath:samples/holdings/identifier-types.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostIdentifierTypes') identifierTypes

    * def instanceTypes = karate.read('classpath:samples/holdings/instance-types.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostInstanceTypes') instanceTypes

    * def contributorNameTypes = karate.read('classpath:samples/holdings/contributor-name-types.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostContributorNameTypes') contributorNameTypes

    * def classificationTypes = karate.read('classpath:samples/holdings/classification-types.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostClassificationTypes') classificationTypes

    * def instances = karate.read('classpath:samples/holdings/instances.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostInstances') instances

    * def holdingsSources = karate.read('classpath:samples/holdings/holdings-sources.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostHoldingsSources') holdingsSources

    * def holdings = karate.read('classpath:samples/holdings/holdings.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostHoldings') holdings