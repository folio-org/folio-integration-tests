Feature: Remove generated instances
  Scenario: Tear down case
    * def instancesRequest = karate.read('samples/instances.json')
    * def mapper = function(instance) { return {'instanceId': instance.id} }
    * def instanceIdsWrapped = karate.map(instancesRequest.instances, mapper)
    * call read('drop-instance.feature') instanceIdsWrapped