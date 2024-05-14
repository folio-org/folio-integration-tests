package org.folio

import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._
import org.apache.commons.lang3.RandomUtils

import scala.concurrent.duration._
import scala.language.postfixOps

class ReadingRoomSimulation extends Simulation {

  def generateTenantId(): String = {
    val constantString = "testtenant"
    val randomLong = RandomUtils.nextLong
    constantString + randomLong
  }

  val protocol = karateProtocol(
    "/_/proxy/tenants/{tenant}" -> Nil,
    "/_/proxy/tenants/{tenant}/modules" -> Nil,
    "/_/proxy/tenants/{tenant}/install" -> Nil,
    "/service-points" -> Nil,
    "/reading-room" -> Nil,
    "/reading-room/{readingRoomId}" -> Nil,
    "/reading-room/{readingRoomId}/access-log" -> Nil,
  )
  protocol.runner.systemProperty("testTenant", generateTenantId())

  val before = scenario("before")
    .exec(karateFeature("classpath:volaris/mod-reading-room/reading-room-init.feature"))
  val readingRoom = scenario("readingRoom")
    .repeat(1) {
      exec(karateFeature("classpath:volaris/mod-reading-room/features/reading-room.feature"))
    }
  val patronPermission = scenario("patronPermission")
    .repeat(1) {
      exec(karateFeature("classpath:volaris/mod-reading-room/features/patron-permission.feature"))
    }
  val after = scenario("after").exec(karateFeature("classpath:common/destroy-data.feature"))

  setUp(
    before.inject(atOnceUsers(1))
      .andThen(readingRoom.inject(nothingFor(3 seconds), rampUsers(3) during (5 seconds)))
      .andThen(patronPermission.inject(nothingFor(3 seconds), rampUsers(3) during (5 seconds)))
      .andThen(after.inject(nothingFor(3 seconds), atOnceUsers(1))),
  ).protocols(protocol)

}
