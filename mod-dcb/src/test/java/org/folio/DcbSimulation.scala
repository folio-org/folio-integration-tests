package org.folio

import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._

import scala.concurrent.duration._
import scala.language.postfixOps
import scala.util.Random

class DcbSimulation extends Simulation {

  def generateTenantId(): String = {
    val constantString = "testtenant"
    val randomLong = Random.nextLong()
    constantString + randomLong
  }

  val protocol = karateProtocol(
    "/_/proxy/tenants/{tenant}" -> Nil,
    "/_/proxy/tenants/{tenant}/modules" -> Nil,
    "/_/proxy/tenants/{tenant}/install" -> Nil,
    "/transactions/{transactionId}" -> Nil,
    "/transactions/{transactionId}/status" -> Nil,
    "/request-storage/requests" -> Nil,
    "/circulation/requests/{requestId}" -> Nil,
    "/circulation-item/{itemId}" -> Nil,
    "/loan-storage/loans" -> Nil,
  )
  protocol.runner.systemProperty("testTenant", generateTenantId())

  val before = scenario("before")
    .exec(karateFeature("classpath:volaris/mod-dcb/mod-dcb-junit.feature"))
  val dcbBorrowingPickupFlow = scenario("borrowing-pickup")
    .repeat(10) {
      exec(karateFeature("classpath:volaris/mod-dcb/features/borrowing-pickup.feature"))
    }
  val after = scenario("after").exec(karateFeature("classpath:common/destroy-data.feature"))

  setUp(
    before.inject(atOnceUsers(1))
      .andThen(dcbBorrowingPickupFlow.inject(nothingFor(3 seconds), rampUsers(3) during (5 seconds)))
      .andThen(after.inject(nothingFor(3 seconds), atOnceUsers(1))),
  ).protocols(protocol)

}
