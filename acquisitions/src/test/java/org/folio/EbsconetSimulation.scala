package org.folio

import com.intuit.karate.gatling.KarateProtocol
import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._
import io.gatling.core.structure.ScenarioBuilder

import java.util.concurrent.ThreadLocalRandom
import scala.concurrent.duration._
import scala.language.postfixOps
import scala.util.Random

class EbsconetSimulation extends Simulation {

  def generateTenantId(): String = {
    val constantString = "testtenant"
    val randomLong = Random.nextLong()
    constantString + randomLong
  }

  val protocol: KarateProtocol = karateProtocol(
    "/_/proxy/tenants/{tenant}" -> Nil,
    "/_/proxy/tenants/{tenant}/modules" -> Nil,
    "/_/proxy/tenants/{tenant}/install" -> Nil,
    "/orders/composite-orders" -> Nil,
    "/orders/order-lines/{poLineId}" -> Nil,
    "/ebsconet/orders/order-lines/{poLineId}" -> Nil,
  )
  protocol.runner.systemProperty("testTenant", generateTenantId())

  val before: ScenarioBuilder = scenario("before")
    .exec(karateFeature("classpath:thunderjet/mod-ebsconet/ebsconet-junit.feature"))
  val create: ScenarioBuilder = scenario("create")
    .repeat(10) {
      exec(karateFeature("classpath:thunderjet/mod-ebsconet/features/get-ebsconet-order-line.feature"))
    }
  val after: ScenarioBuilder = scenario("after").exec(karateFeature("classpath:common/destroy-data.featuree"))

  setUp(
    before.inject(atOnceUsers(1))
      .andThen(create.inject(nothingFor(3 seconds), rampUsers(3) during (5 seconds)))
      .andThen(after.inject(nothingFor(3 seconds), atOnceUsers(1))),
  ).protocols(protocol)

}
