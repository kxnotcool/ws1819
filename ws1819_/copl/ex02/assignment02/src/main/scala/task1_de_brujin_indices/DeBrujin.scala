package task1_de_brujin_indices

object DeBrujin {
  sealed abstract class LAEDB
  case class NumDB(n: Int) extends LAEDB
  case class AddDB(lhs: LAEDB, rhs: LAEDB) extends LAEDB
  case class SubDB(lhs: LAEDB, rhs: LAEDB) extends LAEDB
  case class LetDB(namedExpr: LAEDB, body: LAEDB) extends LAEDB
  case class RefDB(n: Int) extends LAEDB

  sealed abstract class LAE
  case class Num(n: Int) extends LAE
  case class Add(lhs: LAE, rhs: LAE) extends LAE
  case class Sub(lhs: LAE, rhs: LAE) extends LAE
  case class Let(boundId: Symbol, namedExpr: LAE, body: LAE) extends LAE
  case class Id(name: Symbol) extends LAE

  // --------------------------------------------
  // --- PUT ALL YOUR CHANGES BELOW THIS LINE ---
  // --------------------------------------------

  def convert(expr: LAE, subs: List[Symbol] = List()): LAEDB = expr match {
    case Num(n) => NumDB(n)
    case Add(lhs, rhs) => AddDB(convert(lhs, subs), convert(rhs, subs))
    case Sub(lhs, rhs) => SubDB(convert(lhs, subs), convert(rhs, subs))
    case Let(boundId, namedExpr, body) => {
      val subs2 = boundId::subs
      LetDB(convert(namedExpr,subs), convert(body, subs2))
    }
    case Id(name) => {
      if(subs.indexOf(name) == -1)
        throw new IllegalStateException("Exception thrown")
      RefDB(subs.indexOf(name))

    }

  }

  def interp(expr: LAEDB, subs: List[Int] = List()): Int = expr match {
    case NumDB(n) => n
    case AddDB(lhs, rhs) => interp(lhs, subs) + interp(rhs, subs)
    case SubDB(lhs, rhs) => interp(lhs, subs) - interp(rhs, subs)
    case LetDB(namedExpr, body) =>  {

        val subs2 = interp(namedExpr, subs) :: subs
        interp(body, subs2)

    }
    case RefDB(n) => {
      if(n < subs.size || n == 0){
        return subs(n)
      }
      throw new IllegalStateException("Exception thrown")
    }
  }

}
