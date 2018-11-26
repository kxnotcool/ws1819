object TranslateToFix {
  sealed abstract class RCFLAE
  case class Num(n: Int) extends RCFLAE
  case class Add(lhs: RCFLAE, rhs: RCFLAE) extends RCFLAE
  case class Sub(lhs: RCFLAE, rhs: RCFLAE) extends RCFLAE
  case class Mult(lhs: RCFLAE, rhs: RCFLAE) extends RCFLAE
  case class Let(name: Symbol, namedExpr: RCFLAE, body: RCFLAE) extends RCFLAE
  case class Id(name: Symbol) extends RCFLAE
  case class Fun(param: Symbol, body: RCFLAE) extends RCFLAE
  case class If0(test: RCFLAE, posBody: RCFLAE, negBody: RCFLAE) extends RCFLAE
  case class LetRec(name: Symbol, namedExpr: RCFLAE, body: RCFLAE) extends RCFLAE
  case class App(funExpr: RCFLAE, argExpr: RCFLAE) extends RCFLAE

  type Env = scala.collection.Map[Symbol, Val]

  sealed abstract class Val
  case class NumV(n: Int) extends Val
  case class Closure(param: Symbol, body: RCFLAE, env: Env) extends Val

  def interp(expr: RCFLAE, env: Env = Map()): Val = expr match {
    case Num(n) => NumV(n)

    case Add(lhs, rhs) => {
      val lhsV = interp(lhs, env)
      val rhsV = interp(rhs, env)
      (lhsV, rhsV) match {
        case (NumV(n1), NumV(n2)) => NumV(n1 + n2)
        case _ => sys.error("can only add numbers, but got: " + (lhsV, rhsV))
      }
    }

    case Sub(lhs, rhs) => {
      val lhsV = interp(lhs, env)
      val rhsV = interp(rhs, env)
      (lhsV, rhsV) match {
        case (NumV(n1), NumV(n2)) => NumV(n1 - n2)
        case _ =>
          sys.error("can only subtract numbers, but got: " + (lhsV, rhsV))
      }
    }

    case Mult(lhs, rhs) => {
      val lhsV = interp(lhs, env)
      val rhsV = interp(rhs, env)
      (lhsV, rhsV) match {
        case (NumV(n1), NumV(n2)) => NumV(n1 * n2)
        case _ =>
          sys.error("can only multiply numbers, but got: " + (lhsV, rhsV))
      }
    }

    case Let(boundId, namedExpr, boundBody) => {
      interp(boundBody, env + (boundId -> interp(namedExpr, env)))
    }

    case Id(name) => env(name)

    case Fun(arg, body) => Closure(arg, body, env)

    case If0(testExpr, thenExpr, elseExpr) => {
      val testV = interp(testExpr, env)
      testV match {
        case NumV(n) => {
          if (n == 0)
            interp(thenExpr, env)
          else
            interp(elseExpr, env)
        }
        case _ => sys.error("can only test numbers, but got: " + testV)
      }
    }

    case LetRec(boundId, namedExpr, boundBody) => {
      val recEnv = collection.mutable.Map() ++ env
      recEnv += boundId -> interp(namedExpr, recEnv)
      interp(boundBody, recEnv)
    }

    case App(funExpr, argExpr) => {
      val funV = interp(funExpr, env)
      funV match {
        case Closure(fParam, fBody, fEnv) => {
          interp(fBody, fEnv + (fParam -> interp(argExpr, env)))
        }
        case _ => sys.error("can only apply functions, but got: " + funV)
      }
    }
  }

  implicit def symbolToExpr(symbol: Symbol) = Id(symbol)
  implicit def intToExpr(n: Int) = Num(n)

  // ===========================
  // Put your changes below here
  // ===========================

  // Z combinator
  val Z = ???

  def translate2Fix(e: RCFLAE): RCFLAE = e match {
    case LetRec(name, namedExpr, body) => {
      Let(???, ???, ???)
      sys.error("todo: transform into a use of Z")
    }
    case _ => sys.error("todo: recurse into subtrees")
  }

}
