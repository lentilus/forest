---
title: Paths and Equality
---

```agda
module 0Trinitarianism.Quest4 where

open import 0Trinitarianism.Preambles.P4

```

**The Identity Type**

`Id` denotes the identity type. We give a proof `rfl` for `Id x x`. In other words -- `Id` is reflexive.
```agda
data Id {A : Type} : (x y : A) -> Type where
  rfl : {x : A} -> Id x x
```

Since `rfl` is the only element of type `Id` it suffices to show that `rfl` is symmetric. We do this by casing on `p : Id` which only allows `rfl` thus judgementally equal `x` and `y`.
```agda
idSym : (A : Type) (x y : A) -> Id x y -> Id y x
idSym A x x rfl = rfl
```

Or implicitly (what we will use from now on).
```agda
Sym : {A : Type} {x y : A} → Id x y → Id y x
Sym rfl = rfl
```


```agda
-- transitivity
idTrans : (A : Type) (x y z : A) -> Id x y -> Id y z -> Id x z
idTrans A x y z rfl rfl = rfl
```

with implicit arguments
```
_*_ : {A : Type} {x y z : A}  -> Id x y -> Id y z -> Id x z
rfl * p = p
```

**Groupoid Laws**

concatenation is right neutral.
```agda
rfl* : {A : Type} {x y : A} (p : Id x y) → Id (rfl * p) p
rfl* p = rfl
```

concatenation with rfl is left neutral.
```
*rfl : {A : Type} {x y : A} (p : Id x y) → Id (p * rfl) p
*rfl rfl = rfl
```

Concatenation with `p` on the left and right gives `rfl`.

```agda
Sym* : {A : Type} {x y : A} (p : Id x y) → Id (Sym p * p) rfl
Sym* rfl = rfl

*Sym : {A : Type} {x y : A} (p : Id x y) → Id (p * Sym p) rfl
*Sym rfl = rfl
```

```agda
Assoc : {A : Type} {w x y z : A} (p : Id w x) (q : Id x y) (r : Id y z)
        → Id ((p * q) * r) (p * (q * r))
Assoc rfl q r = rfl
```

**Recursor - The Mapping Out Property of `Id`**

```agda
private
  variable
    A : Type
    x y : A
```

```agda
outOfId : (M : (y : A) → Id x y → Type) → M x rfl
  → {y : A} (p : Id x y) → M y p
outOfId M x rfl = x
```

## The Path Space

We will from now on use the _path space_ `x ≡ y` from cubical agda representing the same idea as our `Id`.

We equip `≡` with three axioms:
```agda
-- If `x` is a point in some space then `refl` is a proof of `x ≡ x`.
```

```agda
J : (M : (y : A) → x ≡ y → Type) → M x refl
  → {y : A} (p : x ≡ y) → M y p
```

```agda
JRefl : (M : (y : A) → x ≡ y → Type) (h : M x refl)
  → J M h refl ≡ h
```
