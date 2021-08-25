Feature: init data for mod-inventory-storage

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }
    * def recordId = uuid()
    * def snapshotId = uuid()
    * def holdingId = uuid()
    * def instanceId = '1762b035-f87b-4b6f-80d8-c02976e03575'

  Scenario: create instance type
    * def instanceType =
    """
      {
        "id": "fe19bae4-da28-472b-be90-d442e2428ead",
        "name": "txt",
        "code": "text",
        "source": "rdacontent"
      }
    """
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostInstanceType') {instanceType: #(instanceType)}

  Scenario: create identifier type
    * def identifierType =
    """
      {
        "id": "8261054f-be78-422d-bd51-4ed9f33c3422",
        "name": "ISBN",
        "source": "folio"
      }
    """
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostIdentifierType') {identifierType: #(identifierType)}

  Scenario: create base instance
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostInstance') {instanceId:'b73eccf0-57a6-495e-898d-32b9b2210f2f'}

  Scenario: setup common data
    #setup locations
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostInstitution')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostCampus')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLibrary')
    * json locations = read('classpath:domain/data-import/samples/location/locations.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLocation') {location: #(locations[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLocation') {location: #(locations[1])}
    #setup call number type
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostCallNumberType')
    #setup ill policy type
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostIllPolicy')
    #setup loan types
    * json loans = read('classpath:domain/data-import/samples/loan/item_loan_types.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLoanType') {loanType: #(loans[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLoanType') {loanType: #(loans[1])}
    #setup material type
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostMaterialType')
    #setup note types
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostHoldingNoteType')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostItemNoteType')
    #setup statistical code
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostItemStatisticalCodeType')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostItemStatisticalCode')









