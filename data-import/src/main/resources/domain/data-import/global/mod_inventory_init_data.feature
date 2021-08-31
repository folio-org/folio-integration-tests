Feature: init data for mod-inventory-storage

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }

  Scenario: create instance type
    * def instanceType =
    """
      {
        "id": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
        "name": "txt",
        "code": "txt",
        "source": "rdacontent"
      }
    """
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostInstanceType') {instanceType: #(instanceType)}

  Scenario: create holdings type
    * def holdingsType =
    """
       {
	     "source": "folio",
	     "name": "Electronic",
	     "id": "996f93e2-5b5e-4cf2-9168-33ced1f95eed"
       }

    """
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostHoldingsType') {holdingsType: #(holdingsType)}

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

  Scenario: setup common data
    #setup locations
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostInstitution')
    * json campuses = read('classpath:domain/data-import/samples/location/campus.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostCampus') {campus: #(campuses[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostCampus') {campus: #(campuses[1])}
    * json libraries = read('classpath:domain/data-import/samples/location/library.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLibrary') {library: #(libraries[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLibrary') {library: #(libraries[1])}
    * json locations = read('classpath:domain/data-import/samples/location/locations.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLocation') {location: #(locations[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLocation') {location: #(locations[1])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostLocation') {location: #(locations[2])}
    #setup call number type
    * json callNumberTypes = read('classpath:domain/data-import/samples/call_number/call_number_type.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostCallNumberType') {callNumberType: #(callNumberTypes[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostCallNumberType') {callNumberType: #(callNumberTypes[1])}
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
    #setup statistical code type
    * json statisticalCodeTypes = read('classpath:domain/data-import/samples/statistical_code/statistical_code_type.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostStatisticalCodeType') {statisticalCodeType: #(statisticalCodeTypes[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostStatisticalCodeType') {statisticalCodeType: #(statisticalCodeTypes[1])}
    #setup statistical code
    * json statisticalCodes = read('classpath:domain/data-import/samples/statistical_code/statistical_code.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostStatisticalCode') {statisticalCode: #(statisticalCodes[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostStatisticalCode') {statisticalCode: #(statisticalCodes[1])}
    #setup URL relationships
    * json relationships = read('classpath:domain/data-import/samples/url_relationship/url_relationship.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostUrlRelationship') {urlRelationship: #(relationships[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostUrlRelationship') {urlRelationship: #(relationships[1])}
    #setup instance status types
    * json instanceStatusTypes = read('classpath:domain/data-import/samples/instance_status_type/instance_status_type.json')
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostInstanceStatusType') {instanceStatusType: #(instanceStatusTypes[0])}
    * call read('classpath:domain/data-import/global/inventory_data_setup_util.feature@PostInstanceStatusType') {instanceStatusType: #(instanceStatusTypes[1])}









