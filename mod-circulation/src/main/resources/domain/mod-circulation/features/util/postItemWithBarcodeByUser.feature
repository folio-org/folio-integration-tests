Feature: post item with barcode by certain user

  @PostItemWithBarcodeByUser
  Scenario: Post an item
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { varItemBarcode: '#(varItemBarcode)' }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostPolicies')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { varUserBarcode: '#(varUserBarcode)' }