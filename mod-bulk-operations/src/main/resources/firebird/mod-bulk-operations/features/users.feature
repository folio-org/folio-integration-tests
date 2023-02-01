Feature: mod bulk operations user features

  Background:
    * url baseUrl
    * callonce read('init-data/init-data-for-users.feature')
    * callonce login testUser
    * callonce variables

  Scenario: Inn-App approach bulk edit of user
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'USER'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/users-barcodes.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
