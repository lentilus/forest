---
title: Pi Types
---

```agda
module 0Trinitarianism.Quest3 where

open import 0Trinitarianism.Preambles.P3
```

# Defining Addition

We can define addition of natural numbers by induction on one of the arguments.
This yields two defitions for addition.

```agda
_+_ : ℕ → ℕ → ℕ
zero + m   = m
suc n + m = suc (n + m)

_+'_ : ℕ → ℕ → ℕ
n +' zero = n
n +' suc m = suc (n +' m)
```

# Sum of even natural numbers

Using the definition `_+_` for addition it is easiest to do induction on the
first argument it is easiest to do induction on `x`.
```agda
sumEven : ( x y : Σ ℕ isEven) -> isEven (x .fst + y .fst)
sumEven (zero , hx) y = y .snd
sumEven (suc (suc x) , hx) y = sumEven (x , hx ) y
```

Analogously we can do induction on `y` since `_+'_` is defined by induction
on the second argument.
```agda
sumEven' : ( x y : Σ ℕ isEven) -> isEven (x .fst +' y .fst)
sumEven' x (zero , hy) = x .snd
sumEven' x (suc (suc y) , hy) = sumEven' x (y , hy )
```
(Interestingly the second proof gets accepted for `_+_` too.)
