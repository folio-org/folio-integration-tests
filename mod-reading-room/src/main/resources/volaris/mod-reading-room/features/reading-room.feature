Feature: ReadingRoom tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json','x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * def util1 = call read('classpath:common/util/uuid1.feature')
    * def util2 = call read('classpath:common/util/uuid1.feature')
    * def readingRoomId = util1.uuid1()
    * def readingRoomName = 'reading-room-1'
    * def servicePointId = util2.uuid1()
    * def servicePointName = 'Circ Desk 1'

  Scenario: Create a new reading room
    * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostServicePoint')
    * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostReadingRoom')




