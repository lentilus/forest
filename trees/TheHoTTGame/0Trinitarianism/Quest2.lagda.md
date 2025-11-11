---
title: Sigma Types
---

```agda
module 0Trinitarianism.Quest2 where

open import 0Trinitarianism.Preambles.P2

isEven : ℕ → Type
isEven zero = ⊤
isEven (suc zero) = ⊥
isEven (suc (suc n)) = isEven n
```

```agda
-- there exists an even natural number
existsEven : Σ ℕ isEven 
existsEven = zero , tt


_×_ : Type → Type → Type
A × C = Σ A (λ a → C)

div2 : Σ ℕ isEven → ℕ
div2 (zero , even) = 0
div2 (suc (suc n) , even_n) = suc ( div2 (n , even_n))
```

** A Tautology / Currying / Cartesian Closed **
```agda
private
  postulate
    A B C : Type


uncurry : (A → B → C) → (A × B → C)
uncurry f (a , b) = f a b

curry : (A × B → C) → (A → B → C)
curry f a b = f (a , b)
```


