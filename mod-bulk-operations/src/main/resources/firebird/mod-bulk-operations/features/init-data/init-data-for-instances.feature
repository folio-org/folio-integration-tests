Feature: init data for instances

  Background:
    * url baseUrl
    * callonce variables
    * callonce login testAdmin

  Scenario: setup test data for instances
    * def servicePoints = karate.read('classpath:samples/instances/service-points.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostServicePoints') servicePoints

    * def institutions = karate.read('classpath:samples/instances/institutions.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostInstitutions') institutions

    * def campuses = karate.read('classpath:samples/instances/campuses.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostCampuses') campuses

    * def libraries = karate.read('classpath:samples/instances/libraries.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostLibraries') libraries

    * def location_main = karate.read('classpath:samples/instances/location_main.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostLocationMain') location_main

    * def location_popular_reading = karate.read('classpath:samples/instances/location_popular_reading.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostLocationPopularReading') location_popular_reading

    * def identifierTypes = karate.read('classpath:samples/instances/identifier-types.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostIdentifierTypes') identifierTypes

    * def instanceTypes = karate.read('classpath:samples/instances/instance-types.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostInstanceTypes') instanceTypes

    * def contributorNameTypes = karate.read('classpath:samples/instances/contributor-name-types.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostContributorNameTypes') contributorNameTypes

    * def classificationTypes = karate.read('classpath:samples/instances/classification-types.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostClassificationTypes') classificationTypes

    * def instances = karate.read('classpath:samples/instances/instances.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostInstances') instances

    * def holdingsSources = karate.read('classpath:samples/instances/holdings-sources.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostHoldingsSources') holdingsSources

    * def holdings = karate.read('classpath:samples/instances/holdings.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostHoldings') holdings

    * def item = karate.read('classpath:samples/instances/item.json')
    * call read('init-data/mod-items-util.feature@PostItems') item

    * call read('init-data/srs-util.feature@PostSnapshot')

    * def instances = karate.read('classpath:samples/instances/instances-for-marc.json')
    * call read('init-data/mod-inventory-storage-util.feature@PostInstances') instances

    * def marcInstances = karate.read('classpath:samples/instances/marc-instances.json')
    * call read('init-data/srs-util.feature@PostMarcInstances') marcInstances

    * def marcInstances = karate.read('classpath:samples/instances/marc-instances-duplicate.json')
    * call read('init-data/srs-util.feature@PostMarcInstances') marcInstances