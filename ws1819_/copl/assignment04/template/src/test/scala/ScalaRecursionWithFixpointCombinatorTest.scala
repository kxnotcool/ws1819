import org.scalatest.FunSuite
import org.scalatest.prop.TableDrivenPropertyChecks._
import ScalaRecursionWithFixpointCombinator._

class ScalaRecursionWithFixpointCombinatorTest extends FunSuite {

  val lengths = Table(("n", "r"), (List(), 0), (List(1), 1), (List(5,1), 2), (List(8,3,6), 3), (List(52), 1))

  forAll (lengths) { (n: List[Int], r: Int) => test(s"length($n)") { assertResult(r) { lengthWithFix(n) } } }

}
