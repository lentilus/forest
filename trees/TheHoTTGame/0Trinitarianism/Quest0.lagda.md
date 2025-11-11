---
title : Terms and Types
---

```agda
module 0Trinitarianism.Quest0 where
open import 0Trinitarianism.Preambles.P0
```
**True / Unit / Terminal Object**

```agda
data ⊤ : Type where
  tt : ⊤

TrueToTrue : ⊤ → ⊤
TrueToTrue = λ { x → x }

TrueToTrue' : ⊤ → ⊤
TrueToTrue' x = tt
```

**False / Empty / Initial Object**

```agda
data ⊥ : Type where

explosion : ⊥ → ⊤
explosion ()
```

**Natural Numbers**

```agda
data ℕ : Type where
  zero : ℕ
  suc : ℕ → ℕ
```

**Universes**

