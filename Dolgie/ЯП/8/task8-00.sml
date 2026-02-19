signature RATIO = sig
  (* тип данных *)
  type ratio

  (* конструктор (инфиксный) *)
  val :/: : int * int -> ratio

  (* селекторы *)
  val numerator : ratio -> int
  val denominator : ratio -> int

  (* основные функции *)
  val toString : ratio -> string
  val isEq : ratio * ratio -> bool
  val add : ratio * ratio -> ratio
  val mul : ratio * ratio -> ratio
  val negate : ratio -> ratio
  val abs : ratio -> ratio
  val sign : ratio -> ratio
  val sub : ratio * ratio -> ratio
  val fromInt : int -> ratio
  val isGT : ratio * ratio -> bool
  val isLT : ratio * ratio -> bool
  val recip : ratio -> ratio
end

structure Ratio :> RATIO = struct
  (* объявляем, что конструктор будет инфиксным внутри модуля *)
  infix 7 :/:

  (* тип данных в виде контейнера *)
  datatype ratio = :/: of int * int

  (* вспомогательная функция для нахождения НОД *)
  fun gcd a 0 = a
    | gcd a b = gcd b (a mod b)

  (* нормализация дроби:
   * - сокращение на НОД
   * - знаменатель всегда положительный *)
  fun normalize (a :/: b) =
    if b = 0 then raise Div
    else
      let
        val g = gcd (Int.abs a) (Int.abs b)
        val a' = a div g
        val b' = b div g
      in
        if b' < 0 then (~a') :/: (~b')
        else a' :/: b'
      end

  (* селекторы (возвращают значения из нормализованной дроби) *)
  fun numerator r =
    let val a :/: _ = normalize r
    in a
    end

  fun denominator r =
    let val _ :/: b = normalize r
    in b
    end

  (* преобразование в строку *)
  fun toString r =
    let
      val a = numerator r
      val b = denominator r
    in
      Int.toString a ^ " / " ^ Int.toString b
    end

  (* из целого числа: n = n/1 *)
  fun fromInt n = normalize (n :/: 1)

  (* сравнение на равенство: a1/b1 = a2/b2 <=> a1*b2 = a2*b1 *)
  fun isEq (r1, r2) =
    let
      val a1 :/: b1 = normalize r1
      val a2 :/: b2 = normalize r2
    in
      a1 * b2 = a2 * b1
    end

  (* сложение: a1/b1 + a2/b2 = (a1*b2 + a2*b1)/(b1*b2) *)
  fun add (r1, r2) =
    let
      val a1 :/: b1 = normalize r1
      val a2 :/: b2 = normalize r2
    in
      normalize ((a1 * b2 + a2 * b1) :/: (b1 * b2))
    end

  (* умножение: a1/b1 * a2/b2 = (a1*a2)/(b1*b2) *)
  fun mul (r1, r2) =
    let
      val a1 :/: b1 = normalize r1
      val a2 :/: b2 = normalize r2
    in
      normalize ((a1 * a2) :/: (b1 * b2))
    end

  (* смена знака: -(a/b) = (-a)/b *)
  fun negate r =
    let val a :/: b = normalize r
    in normalize ((~a) :/: b)
    end

  (* модуль: |a/b| = |a|/|b| *)
  fun abs r =
    let val a :/: b = normalize r
    in normalize ((Int.abs a) :/: (Int.abs b))
    end

  (* знак числа: sign(a/b) = sign(a) * sign(b)/1 *)
  fun sign r =
    let
      val a :/: b = normalize r
      val signA = if a > 0 then 1 else if a < 0 then ~1 else 0
      val signB = if b > 0 then 1 else if b < 0 then ~1 else 0
    in
      fromInt (signA * signB)
    end

  (* разность: a - b = a + (-b) *)
  fun sub (r1, r2) = add (r1, negate r2)

  (* больше чем: a1/b1 > a2/b2 <=> a1*b2 > a2*b1 *)
  fun isGT (r1, r2) =
    let
      val a1 :/: b1 = normalize r1
      val a2 :/: b2 = normalize r2
    in
      a1 * b2 > a2 * b1
    end

  (* меньше чем: a1/b1 < a2/b2 <=> a1*b2 < a2*b1 *)
  fun isLT (r1, r2) =
    let
      val a1 :/: b1 = normalize r1
      val a2 :/: b2 = normalize r2
    in
      a1 * b2 < a2 * b1
    end

  (* обратный элемент: 1/(a/b) = b/a *)
  fun recip r =
    let val a :/: b = normalize r
    in
      if a = 0 then raise Div
      else normalize (b :/: a)
    end
end

(* создаем псевдонимы для использования вне модуля *)
infix 7 :/:
val (op :/:) = Ratio.:/:

(* тестовые примеры *)
val r1 = 3 :/: 4
val r2 = 5 :/: 6
val r3 = ~2 :/: 3
val r4 = 4 :/: 8  (* сократимая дробь *)

(* основные операции *)
val r1_str = Ratio.toString r1
val r2_str = Ratio.toString r2
val r3_str = Ratio.toString r3
val r4_str = Ratio.toString r4

val test_isEq1 = Ratio.isEq (r1, 6 :/: 8)
val test_isEq2 = Ratio.isEq (r1, r2)

val sum = Ratio.toString (Ratio.add (r1, r2))
val product = Ratio.toString (Ratio.mul (r1, r2))
val difference = Ratio.toString (Ratio.sub (r1, r3))

val neg = Ratio.toString (Ratio.negate r1)
val abs_val = Ratio.toString (Ratio.abs r3)
val sign_val1 = Ratio.toString (Ratio.sign r1)
val sign_val2 = Ratio.toString (Ratio.sign r3)
val sign_val3 = Ratio.toString (Ratio.sign (0 :/: 5))

val from_int = Ratio.toString (Ratio.fromInt 7)

val isGT_test1 = Ratio.isGT (r1, r2)
val isGT_test2 = Ratio.isGT (r2, r1)
val isLT_test1 = Ratio.isLT (r1, r2)

val recip_val = Ratio.toString (Ratio.recip r2)

(* проверка нормализации *)
val test_normalize1 = Ratio.toString (4 :/: 8)
val test_normalize2 = Ratio.toString (~4 :/: 8)
val test_normalize3 = Ratio.toString (4 :/: ~8)
val test_normalize4 = Ratio.toString (~4 :/: ~8)

(* проверка недоступности вспомогательных функций
 * (раскомментировать для проверки - должны быть ошибки компиляции) *)
(* val test_gcd = Ratio.gcd 12 8 *)
(* val test_normalize = Ratio.normalize (3 :/: 4) *)

(* операции с сократимыми дробями *)
val r5 = 2 :/: 4
val r6 = 3 :/: 9
val sum2 = Ratio.toString (Ratio.add (r5, r6))
val mul2 = Ratio.toString (Ratio.mul (r5, r6))

(* деление на ноль - должно вызывать исключение *)
(* val div_by_zero = Ratio.recip (0 :/: 1) *)
(* val zero_denom = 1 :/: 0 *)