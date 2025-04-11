Feature: Set for deletion

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant':'#(testTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def utilsPath = 'classpath:folijet/mod-inventory/eureka-features/utils.feature'

    Scenario: Set instance for deletion and back
      Given def instance = call read(utilsPath + '@CreateInstance') { source:'MARC', title:'InstanceForDeletion' }
      And def instanceId = instance.id

      * def instanceHrid = 'in' + ("00000000000" + Math.floor(Math.random() * 10000000000)).slice(-11)
      Given def snapshot = call read(utilsPath + '@CreateSnapshot')
      And def snapshotId = snapshot.id

      Given def record = call read(utilsPath + '@CreateRecord')
      And def recordId = record.id

      Given path 'inventory/instances/' + instanceId
      When method GET
      Then status 200
      And def createdInstance = response

      * eval createdInstance['deleted'] = true
      * eval createdInstance['discoverySuppress'] = true

      * call read(utilsPath + '@UpdateInstance') { instanceId: '#(instanceId)', instance: '#(createdInstance)' }

      Given path 'inventory/instances/' + instanceId
      When method GET
      Then status 200
      And match response.discoverySuppress == true
      And match response.deleted == true

      Given path 'source-storage/records/' + recordId
      When method GET
      Then status 200
      And match response.state == "DELETED"
      And match response.deleted == true
      And match response.additionalInfo.suppressDiscovery == true
      And match response.leaderRecordStatus == "d"
      And match response.parsedRecord.content.leader.charAt(5) == "d"

      * eval createdInstance['deleted'] = false
      * eval createdInstance['discoverySuppress'] = false
      * eval createdInstance['_version'] = 2

      * call read(utilsPath + '@UpdateInstance') { instanceId: '#(instanceId)', instance: '#(createdInstance)' }

      Given path 'inventory/instances/' + instanceId
      When method GET
      Then status 200
      And match response.discoverySuppress == false
      And match response.deleted == false

      Given path 'source-storage/records/' + recordId
      When method GET
      Then status 200
      And match response.state == "ACTUAL"
      And match response.deleted == false
      And match response.additionalInfo.suppressDiscovery == false
      And match response.leaderRecordStatus == "c"
      And match response.parsedRecord.content.leader.charAt(5) == "c"
      And def updatedDateValue = get[0] response.parsedRecord.content.fields[?(@['005'])].005


      ## Send update request wihtout changing flags values
      ## Updated date (005) must not be changed
      * eval createdInstance['_version'] = 3
      * call read(utilsPath + '@UpdateInstance') { instanceId: '#(instanceId)', instance: '#(createdInstance)' }

      Given path 'inventory/instances/' + instanceId
      When method GET
      Then status 200
      And match response.discoverySuppress == false
      And match response.deleted == false

      Given path 'source-storage/records/' + recordId
      When method GET
      Then status 200
      And match response.state == "ACTUAL"
      And match response.deleted == false
      And match response.additionalInfo.suppressDiscovery == false
      And match response.leaderRecordStatus == "c"
      And match response.parsedRecord.content.leader.charAt(5) == "c"
      And match response.parsedRecord.content.fields[*].005 contains only updatedDateValue
