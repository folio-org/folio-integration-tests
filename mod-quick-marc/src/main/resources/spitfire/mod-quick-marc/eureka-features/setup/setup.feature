Feature: Setup quickMARC

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }

    * def samplePath = 'classpath:spitfire/mod-quick-marc/eureka-features/setup/samples/'

    * def snapshotId = '7dbf5dcf-f46c-42cd-924b-04d99cd410b9'
    * def instanceId = '337d160e-a36b-4a2b-b4c1-3589f230bd2c'
    * def sourceId = '036ee84a-6afd-4c3c-9ad3-4a12ab875f59'
    * def instanceHrid = 'in00000000001'
    * def linkedAuthorityId = 'e7537134-0724-4720-9b7d-bddec65c0fad'
    * def authorityNaturalId = 'n00001263'
    * def bibSpecificationId = '6eefa4c6-bbf7-4845-ad82-de7fc4abd0e3'

  Scenario: Set-up record specifications
    Given path 'specification-storage/specifications', bibSpecificationId
    And param include = "all"
    And headers headersUser
    When method GET
    Then status 200
    And def bibSpecification = response
    # * setSystemProperty('bibSpecification', bibSpecification)
    * def field245 = bibSpecification.fields.find(field => field.tag == "245")
    * def field100 = bibSpecification.fields.find(field => field.tag == "100")
    * def field245subfieldA = field245.subfields.find(subfield => subfield.code == "a")

    # standard required a subfield for standard 245 field
    Given path 'specification-storage/subfields', field245subfieldA.id
    And headers headersUser
    And request
    """
      {
       "code": "#(field245subfieldA.code)",
       "label": "#(field245subfieldA.label)",
       "repeatable": #(field245subfieldA.repeatable),
       "required": true,
       "deprecated": #(field245subfieldA.deprecated)
      }
    """
    When method PUT
    Then status 202

    # local required 249 field
    * def field249 = karate.call('setup.feature@CreateSpecificationField', {tag: "249", required: true}).response;
    # local a subfield for 249 field
    * call read('setup.feature@CreateSpecificationSubfield') {fieldId: #(field249.id), code: "a", repeatable: false, required: false}
    # local 0 code for ind1 for local 249 field
    * def f249ind1 = karate.call('setup.feature@CreateSpecificationIndicator', {fieldId: field249.id, order: "1"}).response;
    * call read('setup.feature@CreateSpecificationIndicatorCode') {indicatorId: #(f249ind1.id), code: "0"}
    # local 0 code for ind2 for local 249 field
    * def f249ind2 = karate.call('setup.feature@CreateSpecificationIndicator', {fieldId: field249.id, order: "2"}).response;
    * call read('setup.feature@CreateSpecificationIndicatorCode') {indicatorId: #(f249ind2.id), code: "0"}

    # local required 1 subfield for standard 245 field
    * call read('setup.feature@CreateSpecificationSubfield') {fieldId: #(field245.id), code: "1", repeatable: false, required: true}
    # local repeatable 2 subfield for standard 245 field
    * call read('setup.feature@CreateSpecificationSubfield') {fieldId: #(field245.id), code: "2", repeatable: true, required: false}

    # local 248 field
    * def field248 = karate.call('setup.feature@CreateSpecificationField', {tag: "248", required: false}).response;
    # local required a subfield for local 248 field
    * call read('setup.feature@CreateSpecificationSubfield') {fieldId: #(field248.id), code: "a", repeatable: false, required: true}
    # local repeatable b subfield for local 248 field
    * call read('setup.feature@CreateSpecificationSubfield') {fieldId: #(field248.id), code: "b", repeatable: true, required: false}
    # local a code for ind1 for local 248 field
    * def ind1 = karate.call('setup.feature@CreateSpecificationIndicator', {fieldId: field248.id, order: "1"}).response;
    * call read('setup.feature@CreateSpecificationIndicatorCode') {indicatorId: #(ind1.id), code: "a"}
    # local b code for ind2 for local 248 field
    * def ind2 = karate.call('setup.feature@CreateSpecificationIndicator', {fieldId: field248.id, order: "2"}).response;
    * call read('setup.feature@CreateSpecificationIndicatorCode') {indicatorId: #(ind2.id), code: "b"}

  Scenario: Setup locations
    Given path 'location-units/institutions'
    And headers headersUser
    And request read(samplePath + 'locations/institution.json')
    When method POST

    Given path 'location-units/campuses'
    And headers headersUser
    And request read(samplePath + 'locations/campus.json')
    When method POST

    Given path 'location-units/libraries'
    And headers headersUser
    And request read(samplePath + 'locations/library.json')
    When method POST

    Given path 'locations'
    And headers headersUser
    And request read(samplePath + 'locations/location.json')
    When method POST

  @SetupTypes
  Scenario: Setup record types
    Given path 'holdings-sources'
    And headers headersUser
    And request
    """
      {
       "id": "#(sourceId)",
       "name": "MARC"
      }
    """
    When method POST

    Given path 'instance-types'
    And headers headersUser
    And request read(samplePath + 'record-types/instance-type.json')
    When method POST

    Given path 'holdings-types'
    And headers headersUser
    And request read(samplePath + 'record-types/holdings-type.json')
    When method POST

  @CreateSnapshot
  Scenario: Create snapshot
    Given path 'source-storage/snapshots'
    And request { 'jobExecutionId':'#(snapshotId)', 'status':'PARSING_IN_PROGRESS' }
    And headers headersUser
    When method POST
    Then status 201

    * setSystemProperty('snapshotId', snapshotId)

  Scenario: Create Authority Source FIle
    Given path 'authority-source-files'
    And request read(samplePath + 'setup-records/authority-source-file.json')
    And headers headersUser
    When method POST
    Then status 201

  Scenario: Create MARC-AUTHORITY records
    * call read('setup.feature@CreateAuthority') {recordName: 'authorityId'}
    * call read('setup.feature@CreateAuthority') {recordName: 'authorityIdForDelete'}
    * call read('setup.feature@CreateAuthority') {recordName: 'linkedAuthorityId', id: #(linkedAuthorityId)}

  Scenario: Create MARC-BIB record
    * call read('setup.feature@CreateMarcBib') {id: #(instanceId), hrid: #(instanceHrid)}
    * setSystemProperty('instanceId', instanceId)

  Scenario: Create MARC-HOLDINGS record
    * def holdingsId = uuid()
    Given path 'holdings-storage/holdings'
    And request read(samplePath + 'setup-records/holdings.json')
    And headers headersUser
    When method POST
    Then status 201

    * def recordId = uuid()
    Given path 'source-storage/records'
    And request read(samplePath + 'setup-records/marc-holdings.json')
    And headers headersUser
    When method POST
    Then status 201

    * setSystemProperty('holdingsId', holdingsId)

  Scenario: Create Instance-Authority links
    Given path 'records-editor/records'
    And param externalId = instanceId
    And headers headersUser
    When method GET
    Then status 200
    And def record = response

    * def linkContent = ' $0 ' + authorityNaturalId + ' $9 ' + linkedAuthorityId
    * def tag100 = {"tag": "100", "content":'#("$a Johnson" + linkContent)', "indicators": ["\\","1"], "linkDetails":{ "authorityId": #(linkedAuthorityId),"authorityNaturalId": #(authorityNaturalId), "linkingRuleId": 1} }
    * def tag600 = {"tag": "600", "content":'#("$a Johnson" + linkContent)', "indicators": ["\\","\\"], "linkDetails":{ "authorityId": #(linkedAuthorityId),"authorityNaturalId": #(authorityNaturalId), "linkingRuleId": 8} }

    * record.fields = record.fields.filter(field => field.tag != "100")
    * record.fields.push(tag100)
    * record.fields.push(tag600)
    * set record.relatedRecordVersion = 1
    * set record._actionType = 'edit'

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 202

    * setSystemProperty('authorityNaturalId', authorityNaturalId)

  @Ignore #Util scenario, accept 'tag', 'required' parameters
  @CreateSpecificationField
  Scenario: Create Specification Field
    Given path 'specification-storage/specifications', bibSpecificationId, 'fields'
    And headers headersUser
    And request
    """
      {
       "tag": #(tag),
       "label": "local field #(tag)",
       "url": "https://www.test.gov/test.html",
       "repeatable": true,
       "required": #(required),
       "deprecated": false
      }
    """
    When method POST
    Then status 201

  @Ignore #Util scenario, accept 'fieldId', 'code', 'repeatable', 'required' parameters
  @CreateSpecificationSubfield
  Scenario: Create Specification Field Subfield
    Given path 'specification-storage/fields', fieldId, 'subfields'
    And headers headersUser
    And request
    """
      {
       "code": #(code),
       "label": "local #(code) #(repeatable) #(required)",
       "repeatable": #(repeatable),
       "required": #(required),
       "deprecated": false
      }
    """
    When method POST
    Then status 201

  @Ignore #Util scenario, accept 'fieldId', 'order' parameters
  @CreateSpecificationIndicator
  Scenario: Create Specification Field Indicator
    Given path 'specification-storage/fields', fieldId, 'indicators'
    And headers headersUser
    And request
    """
      {
       "order": #(order),
       "label": "local ind #(order)"
      }
    """
    When method POST
    Then status 201

  @Ignore #Util scenario, accept 'indicatorId', 'code' parameters
  @CreateSpecificationIndicatorCode
  Scenario: Create Specification Field Indicator Code
    Given path 'specification-storage/indicators', indicatorId, 'indicator-codes'
    And headers headersUser
    And request
    """
      {
       "code": #(code),
       "label": "local ind #(indicatorId) code #(code)"
      }
    """
    When method POST
    Then status 201

  @Ignore #Util scenario, accept 'id', 'hrid' parameters
  @CreateMarcBib
  Scenario: Create Instance and MARC-BIB record
    * def instanceId = id
    * def instanceHrid = hrid
    Given path 'instance-storage/instances'
    And request read(samplePath + 'setup-records/instance.json')
    And headers headersUser
    When method POST
    Then status 201

    * def recordId = uuid()
    Given path 'source-storage/records'
    And request read(samplePath + 'setup-records/marc-bib.json')
    And headers headersUser
    When method POST
    Then status 201

  @Ignore #Util scenario, accept 'recordName' parameter
  @CreateAuthority
  Scenario: Create MARC-AUTHORITY record
    * def authorityId = karate.get('id', uuid())
    Given path 'authority-storage/authorities'
    And request read(samplePath + 'setup-records/authority.json')
    And headers headersUser
    When method POST
    Then status 201

    * def recordId = uuid()
    Given path 'source-storage/records'
    And request read(samplePath + 'setup-records/marc-authority.json')
    And headers headersUser
    When method POST
    Then status 201
    * def externalId = response.externalIdsHolder.authorityId

    And eval if (typeof recordName != 'undefined') setSystemProperty(recordName, externalId)
