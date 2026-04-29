package org.folio

import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._

import scala.concurrent.duration._
import scala.language.postfixOps
import scala.util.Random

class FolioEcsCirculationSimulation extends Simulation {

  def generateTenantId(): String = {
    val constantString = "testtenant"
    val randomLong = Random.nextLong()
    constantString + randomLong
  }

  val protocol = karateProtocol(
    "/_/proxy/tenants/{tenant}" -> Nil,
    "/_/proxy/tenants/{tenant}/modules" -> Nil,
    "/_/proxy/tenants/{tenant}/install" -> Nil,
    "/users" -> Nil,
  )
  protocol.runner.systemProperty("testTenant", generateTenantId())

  val before = scenario("before")
    .exec(karateFeature("classpath:vega/systemwide-service-points/features/systemwide-service-points.feature"))
  val systemwideServicePoints = scenario("systemwideServicePoints")
    .repeat(10) {
      exec(karateFeature("classpath:vega/systemwide-service-points/features/systemwide-service-points.feature"))
    }
  val after = scenario("after").exec(karateFeature("classpath:vega/systemwide-service-points/destroy-consortia.feature"))

  setUp(
    before.inject(atOnceUsers(1))
      .andThen(systemwideServicePoints.inject(nothingFor(3 seconds), rampUsers(3) during (5 seconds)))
      .andThen(after.inject(nothingFor(3 seconds), atOnceUsers(1))),
  ).protocols(protocol)

}
