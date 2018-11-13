package task3_zip

object Zip {
  def zipop[A, B, C](f: (A, B) => C): (List[A], List[B]) => List[C] = {
    (l1: List[A], l2: List[B]) =>
      if (l1.isEmpty || l2.isEmpty)
        List.empty
      else
        f(l1.head, l2.head) :: zipop(f)(l1.tail, l2.tail)
  }

  // --------------------------------------------
  // --- PUT ALL YOUR CHANGES BELOW THIS LINE ---
  // --------------------------------------------

  def zipadd(lhs: List[Int], rhs: List[Int]): List[Int] = zipop((a: Int, b: Int) => a + b)(lhs, rhs)

  def zip[A, B](lhs: List[A], rhs: List[B]): List[(A, B)] = zipop((a: A, b: B) => (a, b))(lhs, rhs)

  def addMatrix(lhs: List[List[Int]], rhs: List[List[Int]]): List[List[Int]] = zipop((lhs: List[Int], rhs: List[Int]) => zipadd(lhs, rhs))(lhs, rhs)
}
