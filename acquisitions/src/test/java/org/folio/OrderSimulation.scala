package org.folio

import com.intuit.karate.gatling.KarateProtocol
import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._
import io.gatling.core.structure.ScenarioBuilder

import scala.concurrent.duration._
import scala.language.postfixOps
import scala.util.Random

class OrderSimulation extends Simulation {

  def generateTenantId(): String = {
    val constantString = "testtenant"
    val randomLong = Random.nextLong()
    constantString + randomLong
  }

  val protocol: KarateProtocol = karateProtocol(
    "/_/proxy/tenants/{tenant}" -> Nil,
    "/_/proxy/tenants/{tenant}/modules" -> Nil,
    "/_/proxy/tenants/{tenant}/install" -> Nil,
    "/orders/composite-orders/{orderId}" -> Nil,
    "/finance/transactions" -> Nil,
  )
  protocol.runner.systemProperty("testTenant", generateTenantId())

  val before: ScenarioBuilder = scenario("before")
    .exec(karateFeature("classpath:thunderjet/mod-orders/init-orders.feature"))
  val create: ScenarioBuilder = scenario("create")
    .repeat(10) {
      exec(karateFeature("classpath:thunderjet/mod-orders/features/cancel-and-delete-order.feature"))
    }
  val after: ScenarioBuilder = scenario("after").exec(karateFeature("classpath:common/eureka/destroy-data.feature"))

  setUp(
    before.inject(atOnceUsers(1))
      .andThen(create.inject(nothingFor(3 seconds), rampUsers(3) during (5 seconds)))
      .andThen(after.inject(nothingFor(3 seconds), atOnceUsers(1))),
  ).protocols(protocol)

}
