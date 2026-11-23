Feature: Packages

  Background:
    * url baseUrl
    * call login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/vnd.api+json' }
    * def samplesPath = 'classpath:promin/mod-kb-ebsco-java/features/samples/packages/'

    * def existPackageId = karate.properties['packageId']
    * def existPackageName = karate.properties['packageName']
    * def existTitleName = karate.properties['titleName']
    # managed package of the EBSCO catalog which is not selected in the test account
    * def managedPackageId = '186-3150130'
    * def managedProviderId = 186
    * def visibilityCategories = ['PF', 'FTF', 'MARC']

#   ================= positive test cases =================

  Scenario: Get all Packages
    Given path "/eholdings/packages"
    When method GET
    Then status 200
    And match responseType == 'json'

  Scenario: GET all custom Packages with 200 on success
    Given path "/eholdings/packages"
    And param filter[custom] = true
    When method GET
    Then status 200
    And match response.data[0].attributes.isCustom == true

  Scenario: POST Packages should create a custom package with 200 on success
    Given path "/eholdings/packages"
    When method GET
    Then status 200
    And def initial_num_records = response.meta.totalResults

    Given path "/eholdings/packages"
    And def packageName = random_string()
    And request read(samplesPath + 'createPackage.json')
    When method POST
    Then status 200
    And def packageId = response.data.id

    #waiting for package creation
    * eval sleep(15000)

    Given path "/eholdings/packages"
    And retry until response.meta.totalResults == initial_num_records + 1
    When method GET
    Then status 200

    #destroy package
    Given path '/eholdings/packages', packageId
    When method DELETE
    Then status 204

    #should not find deleted package
    Given path '/eholdings/packages', packageId
    When method GET
    Then status 404

  Scenario: GET Package by id with 200 on success
    Given path '/eholdings/packages', existPackageId
    When method GET
    Then status 200
    And match response.data.id == existPackageId

  Scenario: PUT Package by id with 200 on success
    Given path '/eholdings/packages'
    And def randomPrefix = random_string()
    And def packageName = randomPrefix + 'TEST_PACKAGE_BEFORE_UPDATE'
    And request read(samplesPath + 'createPackage.json')
    When method POST
    Then status 200
    And def packageId = response.data.id

    Given path '/eholdings/packages', packageId
    And def packageName = randomPrefix + 'UPDATED_TEST_PACKAGE'
    And def requestEntity = read(samplesPath + 'updatePackage.json')
    And request requestEntity
    When method PUT
    Then status 200

    Given path '/eholdings/packages', packageId
    When method GET
    Then status 200
    And match response.data.attributes.name == requestEntity.data.attributes.name

    Given path '/eholdings/packages', packageId
    When method DELETE
    Then status 204

  Scenario: DELETE Package by id with 204 on success
    Given path '/eholdings/packages'
    And def randomPrefix = random_string()
    And def packageName = randomPrefix + 'PACKAGE_FOR_REMOVING'
    And request read(samplesPath + 'createPackage.json')
    When method POST
    Then status 200
    And def packageId = response.data.id

    Given path '/eholdings/packages', packageId
    When method DELETE
    Then status 204

  Scenario: PUT Tags by Package id with 200 on success
    Given path '/eholdings/packages/', existPackageId, 'tags'
    And request read(samplesPath + 'tags.json')
    When method PUT
    Then status 200

  Scenario: POST Fetch packages in bulk with 200 on success
    Given path '/eholdings/packages/bulk/fetch'
    And request read(samplesPath + 'bulkFetchPackages.json')
    When method POST
    Then status 200

  Scenario: GET all Packages searched by name with 200 on success
    * configure retry = { count: 10, interval: 5000 }
    Given path '/eholdings/packages'
    And param q = existPackageName
    And param q[field] = 'name'
    And param q[type] = 'exactphrase'
    And retry until response.meta.totalResults >= 1
    When method GET
    Then status 200
    And match response.data[*].id contains existPackageId
    And match response.data[*].attributes.name contains existPackageName

  Scenario: GET all Packages searched by keyword with 200 on success
    * configure retry = { count: 10, interval: 5000 }
    Given path '/eholdings/packages'
    And param q = existPackageName
    And param q[field] = 'keyword'
    And param q[type] = 'exactphrase'
    And retry until response.meta.totalResults >= 1
    When method GET
    Then status 200
    And match response.data[*].id contains existPackageId

  Scenario: GET all Packages filtered by selection status, content type and custom flag with 200 on success
    Given path '/eholdings/packages'
    And param filter[selected] = 'true'
    And param filter[type] = 'unknown'
    And param filter[custom] = 'true'
    And param count = 5
    When method GET
    Then status 200
    And match response.data == '#[_ > 0]'
    And match each response.data[*].attributes contains { isSelected: true, isCustom: true, contentType: 'Unknown' }

  Scenario: GET all Packages filtered by not selected status with 200 on success
    Given path '/eholdings/packages'
    And param filter[selected] = 'false'
    And param count = 5
    When method GET
    Then status 200
    And match response.data == '#[_ > 0]'
    And match each response.data[*].attributes.isSelected == false

  Scenario: GET all Packages filtered by hidden visibility with 200 on success
    * def hasHiddenCategory = function(pkg) { return pkg.attributes.visibility.some(function(v) { return v.hidden == true }) }
    Given path '/eholdings/packages'
    And param filter[selected] = 'true'
    And param filter[visibility] = 'hiddenSomewhere'
    And param count = 5
    When method GET
    Then status 200
    And match response.data == '#[_ > 0]'
    And match each response.data == '#? hasHiddenCategory(_)'

  Scenario: GET all Packages filtered by visible in PF visibility with 200 on success
    * def isVisibleInPf = function(pkg) { return pkg.attributes.visibility.some(function(v) { return v.category == 'PF' && v.hidden == false }) }
    Given path '/eholdings/packages'
    And param filter[selected] = 'true'
    And param filter[visibility] = 'visibleInPF'
    And param count = 5
    When method GET
    Then status 200
    And match response.data == '#[_ > 0]'
    And match each response.data == '#? isVisibleInPf(_)'

  Scenario: GET all Packages filtered by public access with 200 on success
    Given path '/eholdings/packages'
    And param filter[access] = 'public'
    And param count = 5
    When method GET
    Then status 200
    And match response.data == '#[_ > 0]'
    And match each response.data[*].attributes.isFreeAccess == true

  Scenario: GET all Packages filtered by controlled access with 200 on success
    Given path '/eholdings/packages'
    And param filter[access] = 'controlled'
    And param count = 5
    When method GET
    Then status 200
    And match response.data == '#[_ > 0]'
    And match each response.data[*].attributes.isFreeAccess == false

  Scenario: GET all Packages sorted by name and paginated with 200 on success
    Given path '/eholdings/packages'
    And param sort = 'name'
    And param count = 2
    And param page = 1
    When method GET
    Then status 200
    And match response.data == '#[2]'
    And match response.meta.totalResults == '#? _ > 2'
    And def firstPageIds = response.data[*].id

    Given path '/eholdings/packages'
    And param sort = 'name'
    And param count = 2
    And param page = 2
    When method GET
    Then status 200
    And match response.data == '#[2]'
    And match response.data[*].id !contains firstPageIds[0]
    And match response.data[*].id !contains firstPageIds[1]

  Scenario: GET Package by id with 200 on success returns custom Package attributes
    Given path '/eholdings/packages', existPackageId
    When method GET
    Then status 200
    And def attributes = response.data.attributes
    And match attributes.isCustom == true
    And match attributes.isSelected == true
    And match attributes.contentType == 'Unknown'
    And match attributes.customCoverage == { beginCoverage: '2003-01-01', endCoverage: '2004-01-01' }
    And match attributes.visibility[*].category contains only visibilityCategories
    And match each attributes.visibility[*].hidden == false
    And match response.data.type == 'packages'

  Scenario: GET managed Package by id with 200 on success returns managed Package attributes
    Given path '/eholdings/packages', managedPackageId
    When method GET
    Then status 200
    And def attributes = response.data.attributes
    And match response.data.id == managedPackageId
    And match attributes.isCustom == false
    And match attributes.isSelected == false
    And match attributes.providerId == managedProviderId
    And match attributes.contentType == 'AggregatedFullText'
    And match attributes.isAvailableForSelection == true
    And match attributes.managedDescription == '#string'
    And match attributes.visibility[*].category contains only visibilityCategories
    And match each attributes.visibility[*].hidden == false

  Scenario: PUT Package by id with visibility updates visibility of all categories with 200 on success
    Given path '/eholdings/packages'
    And def packageName = random_string() + 'TEST_PACKAGE_VISIBILITY'
    And request read(samplesPath + 'createPackage.json')
    When method POST
    Then status 200
    And def packageId = response.data.id

    Given path '/eholdings/packages', packageId
    And def requestEntity = read(samplesPath + 'updatePackage.json')
    And request requestEntity
    When method PUT
    Then status 200

    Given path '/eholdings/packages', packageId
    When method GET
    Then status 200
    And match response.data.attributes.visibility[*].category contains only visibilityCategories
    And match each response.data.attributes.visibility[*].hidden == true
    And match each response.data.attributes.visibility[*].reason == 'Hidden by Customer'

    Given path '/eholdings/packages', packageId
    When method DELETE
    Then status 204

  Scenario: PUT Package by id without visibility keeps current visibility with 200 on success
    Given path '/eholdings/packages'
    And def packageName = random_string() + 'TEST_PACKAGE_NO_VISIBILITY'
    And request read(samplesPath + 'createPackage.json')
    When method POST
    Then status 200
    And def packageId = response.data.id

    Given path '/eholdings/packages', packageId
    And def requestEntity = read(samplesPath + 'updatePackage.json')
    And remove requestEntity.data.attributes.visibility
    And request requestEntity
    When method PUT
    Then status 200

    Given path '/eholdings/packages', packageId
    When method GET
    Then status 200
    And match response.data.attributes.visibility[*].category contains only visibilityCategories
    And match each response.data.attributes.visibility[*].hidden == false

    Given path '/eholdings/packages', packageId
    When method DELETE
    Then status 204

  Scenario: PUT Package by id updates custom attributes with 200 on success
    Given path '/eholdings/packages'
    And def packageName = random_string() + 'TEST_PACKAGE_CUSTOM_ATTRIBUTES'
    And request read(samplesPath + 'createPackage.json')
    When method POST
    Then status 200
    And def packageId = response.data.id

    Given path '/eholdings/packages', packageId
    And def requestEntity = read(samplesPath + 'updatePackage.json')
    And set requestEntity.data.attributes.customDisplayName = 'Karate custom display name'
    And set requestEntity.data.attributes.url = 'https://karate.example.com'
    And request requestEntity
    When method PUT
    Then status 200

    Given path '/eholdings/packages', packageId
    When method GET
    Then status 200
    And match response.data.attributes.customDisplayName == 'Karate custom display name'
    And match response.data.attributes.url == 'https://karate.example.com'

    Given path '/eholdings/packages', packageId
    When method DELETE
    Then status 204

  Scenario: GET Resources of a Package with 200 on success
    * configure retry = { count: 10, interval: 5000 }
    Given path '/eholdings/packages', existPackageId, 'resources'
    And retry until response.meta.totalResults == 1
    When method GET
    Then status 200
    And def attributes = response.data[0].attributes
    And match response.data[0].type == 'resources'
    And match attributes.name == existTitleName
    And match attributes.packageId == existPackageId
    And match attributes.isSelected == true
    And match attributes.isPackageCustom == true
    And match attributes.visibility[*].category contains only visibilityCategories
    And match each attributes.visibility[*].hidden == false

  Scenario: GET Resources of a managed Package with 200 on success
    Given path '/eholdings/packages', managedPackageId, 'resources'
    And param count = 3
    When method GET
    Then status 200
    And match response.data == '#[3]'
    And match response.meta.totalResults == '#? _ > 3'
    And match each response.data[*].attributes.packageId == managedPackageId
    And match each response.data[*].attributes.isSelected == false

  Scenario: GET Resources of a Package searched by name with 200 on success
    Given path '/eholdings/packages', managedPackageId, 'resources'
    And param count = 1
    When method GET
    Then status 200
    And def resourceName = response.data[0].attributes.name
    And def resourceId = response.data[0].id

    Given path '/eholdings/packages', managedPackageId, 'resources'
    And param q = resourceName
    And param q[field] = 'name'
    When method GET
    Then status 200
    And match response.data[*].id contains resourceId

  Scenario: GET Resources of a Package filtered by selection status with 200 on success
    Given path '/eholdings/packages', managedPackageId, 'resources'
    And param filter[selected] = 'false'
    And param count = 3
    When method GET
    Then status 200
    And match response.data == '#[3]'
    And match each response.data[*].attributes.isSelected == false

    Given path '/eholdings/packages', managedPackageId, 'resources'
    And param filter[selected] = 'true'
    When method GET
    Then status 200
    And match response.meta.totalResults == 0
    And match response.data == '#[0]'

  Scenario: GET Resources of a Package filtered by publication type with 200 on success
    Given path '/eholdings/packages', managedPackageId, 'resources'
    And param filter[type] = 'book'
    And param count = 3
    When method GET
    Then status 200
    And match response.data == '#[3]'
    And match each response.data[*].attributes.publicationType == 'Book'

  Scenario: GET Resources of a Package sorted by name and paginated with 200 on success
    Given path '/eholdings/packages', managedPackageId, 'resources'
    And param sort = 'name'
    And param count = 2
    And param page = 1
    When method GET
    Then status 200
    And match response.data == '#[2]'
    And def firstPageIds = response.data[*].id

    Given path '/eholdings/packages', managedPackageId, 'resources'
    And param sort = 'name'
    And param count = 2
    And param page = 2
    When method GET
    Then status 200
    And match response.data == '#[2]'
    And match response.data[*].id !contains firstPageIds[0]
    And match response.data[*].id !contains firstPageIds[1]

#   ================= negative test cases =================

  Scenario: GET all Packages should return 400 if filter parameter is invalid
    Given path "/eholdings/packages"
    And param filter[custom] = 'null'
    When method GET
    Then status 400

  Scenario: POST Packages should return 400 if Package with the provided name already exists
    Given path '/eholdings/packages', existPackageId
    When method GET
    Then status 200
    And def packageName = response.data.attributes.name

    Given path '/eholdings/packages'
    And request read(samplesPath + 'createPackage.json')
    When method POST
    Then status 400

  Scenario: POST Packages should return 422 if name is empty
    Given path '/eholdings/packages'
    And def packageName = ' '
    And request read(samplesPath + 'createPackage.json')
    When method POST
    Then status 422

  Scenario: GET Package by id should return 400 if Package or provider id are invalid
    Given path '/eholdings/packages/wrongId'
    When method GET
    Then status 400

  Scenario: PUT Package by id should return 400 if Attribute is missing
    Given path '/eholdings/packages', existPackageId
    And def packageName = random_string()
    And def requestEntity = read(samplesPath + 'updatePackage.json')
    And remove requestEntity.data.attributes.isSelected
    And request requestEntity
    When method PUT
    Then status 400

  Scenario: PUT Package by id should return 422 if Coverage is invalid
    Given path '/eholdings/packages', existPackageId
    And def packageName = random_string()
    And def requestEntity = read(samplesPath + 'updatePackage.json')
    And set requestEntity.data.attributes.customCoverage.beginCoverage = ' '
    And request requestEntity
    When method PUT
    Then status 422

  Scenario: DELETE Package by id should return 400 if Package id is invalid
    Given path '/eholdings/packages/wrongId'
    When method DELETE
    Then status 400

  Scenario: PUT Tags assigned to Provider by id should return 422 if name is not provided
    Given path '/eholdings/packages/', existPackageId, 'tags'
    And def requestEntity = read(samplesPath + 'tags.json')
    And set requestEntity.data.attributes.name = ''
    And request requestEntity
    When method PUT
    Then status 422

  Scenario: POST Fetch packages in bulk should return 422 if id format is invalid
    Given path '/eholdings/packages/bulk/fetch'
    And def requestEntity = read(samplesPath + 'bulkFetchPackages.json')
    And set requestEntity.packages[0] = 'wrongId'
    And request requestEntity
    When method POST
    Then status 422

  Scenario Outline: GET all Packages should return 400 if <param> is invalid
    Given path '/eholdings/packages'
    And param <param> = '<value>'
    When method GET
    Then status 400
    And match response.errors[0].title == '<message>'

    Examples:
      | param             | value  | message                                           |
      | q[field]          | bogus  | Invalid Query Parameter for q[field]              |
      | q[type]           | bogus  | Invalid Query Parameter for q[type]               |
      | sort              | bogus  | Invalid Query Parameter for sort                  |
      | filter[selected]  | bogus  | Invalid Query Parameter for filter[selected]      |
      | filter[type]      | bogus  | Invalid Query Parameter for filter[type]          |
      | filter[visibility]| bogus  | Invalid Query Parameter for filter[visibility]    |
      | filter[access]    | bogus  | Invalid Query Parameter for filter[access]        |

  Scenario: GET Package by id should return 404 if Package does not exist
    Given path '/eholdings/packages/123355-999999999'
    When method GET
    Then status 404

  Scenario: PUT managed Package by id should return 422 if not selected Package has visibility
    Given path '/eholdings/packages', managedPackageId
    And def requestEntity = { data: { type: 'packages', attributes: { isCustom: false, isSelected: false } } }
    And set requestEntity.data.attributes.visibility = [{ category: 'PF', hidden: true }]
    And request requestEntity
    When method PUT
    Then status 422
    And match response.errors[0].title == 'Invalid visibility'

  Scenario: PUT managed Package by id should return 422 if not selected Package allows KB to add titles
    Given path '/eholdings/packages', managedPackageId
    And def requestEntity = { data: { type: 'packages', attributes: { isCustom: false, isSelected: false, allowKbToAddTitles: true } } }
    And request requestEntity
    When method PUT
    Then status 422
    And match response.errors[0].title == 'Invalid allowKbToAddTitles'

  Scenario: PUT managed Package by id should return 422 if not selected Package has custom coverage
    Given path '/eholdings/packages', managedPackageId
    And def requestEntity = { data: { type: 'packages', attributes: { isCustom: false, isSelected: false } } }
    And set requestEntity.data.attributes.customCoverage = { beginCoverage: '2003-01-01', endCoverage: '2004-01-01' }
    And request requestEntity
    When method PUT
    Then status 422
    And match response.errors[0].title == 'Invalid customCoverage.beginCoverage'

  Scenario: PUT managed Package by id should return 422 if not selected Package has package token
    Given path '/eholdings/packages', managedPackageId
    And def requestEntity = { data: { type: 'packages', attributes: { isCustom: false, isSelected: false } } }
    And set requestEntity.data.attributes.packageToken = { value: 'token' }
    And request requestEntity
    When method PUT
    Then status 422
    And match response.errors[0].title == 'Invalid packageToken.value'

  Scenario: PUT Package by id should return 422 if isCustom does not match the Package
    Given path '/eholdings/packages', managedPackageId
    And def requestEntity = { data: { type: 'packages', attributes: { isCustom: true, isSelected: false } } }
    And request requestEntity
    When method PUT
    Then status 422
    And match response.errors[0].title == 'Package isCustom not matched'

  Scenario Outline: GET Resources of a Package should return 400 if <param> is invalid
    Given path '/eholdings/packages', existPackageId, 'resources'
    And param <param> = '<value>'
    When method GET
    Then status 400
    And match response.errors[0].title == '<message>'

    Examples:
      | param             | value  | message                                           |
      | q[field]          | bogus  | Invalid Query Parameter for q[field]              |
      | sort              | bogus  | Invalid Query Parameter for sort                  |
      | filter[selected]  | bogus  | Invalid Query Parameter for filter[selected]      |
      | filter[type]      | bogus  | Invalid Query Parameter for filter[type]          |
      | filter[access]    | bogus  | Invalid Query Parameter for filter[access]        |

  Scenario: GET Resources of a Package should return 400 if Package id is invalid
    Given path '/eholdings/packages/wrongId/resources'
    When method GET
    Then status 400
