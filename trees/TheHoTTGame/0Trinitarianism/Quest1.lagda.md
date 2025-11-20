---
title: Dependent Types
---

```agda
module 0Trinitarianism.Quest1 where
open import 0Trinitarianism.Preambles.P1
```

# Predicates / Dependent Constructions / Bundles
```agda
isEven : ℕ → Type
isEven zero = ⊤  
isEven (suc zero) = ⊥
isEven (suc (suc n)) = isEven n
```
