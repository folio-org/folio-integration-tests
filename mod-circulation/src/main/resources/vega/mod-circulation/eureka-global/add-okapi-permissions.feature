Feature: Prepare data for running API tests locally

  Background:
    * url baseUrl

    * table userPermissions
      | name                                         |
      | 'calendar.endpoint.calendars.calendarId.delete'   |
      | 'scheduler.collection.get'                        |
      | 'scheduler.item.put'                              |
      | 'calendar.endpoint.calendars.post'                |
      | 'calendar.endpoint.calendars.surroundingOpenings.get'|
      | 'circulation.requests.queue.item-reorder.collection.post'|
      | 'circulation.requests.allowed-service-points.get'|
      | 'circulation-storage.request-policies.item.get'|
      | 'circulation.requests.queue.instance-reorder.collection.post'|
      | 'circulation.requests.queue-instance.collection.get'|


  Scenario: Grant additional permissions to the  user
    Given call read('classpath:common/eureka/setup-users.feature@addUserCapabilities')

