# Integer Recurrence Square Root Approximator for AMMs

## Overview

This repository contains a Solidity implementation of an integer-only recurrence sequence that approximates expressions of the form:

```
1 + √m
```

and, more generally:

```
1 + k√m
```

Unlike traditional square root methods, this contract relies on **a single linear recurrence with integer coefficients** to generate successive rational approximations. This makes it gas-efficient, deterministic, and well-suited for smart contracts where floating-point arithmetic is unavailable.

Contract on Arbitrum:  
[`0x21c142d0e7cfDBB435C6DC4ef08f4E1F7313D0f6`](https://arbitrum.blockscout.com/address/0x21c142d0e7cfDBB435C6DC4ef08f4E1F7313D0f6?tab=contract)

---

## Mathematical Background

The core recurrence is:

```
a(n) = 2a(n-1) + (m - 1)a(n-2)
```

- For `m = 2`, the ratio `a(n)/a(n-1)` converges to `1 + √2`.  
- More generally, the same recurrence converges to `1 + √m`.  
- With scaling, it converges to `1 + k√m`.  

The **“+1” term is essential**: it shifts the recurrence so that √m is captured inside a *single integer recurrence*. Without this shift, approximations require at least two interleaved sequences (as in Pell’s classical method).  

Thus, this formula represents the **first known way to approximate arbitrary √m using a single integer recurrence sequence**.

---

## Novelty & Verification

- The Pell recurrence was long known to approximate √2, but it required interleaved sequences or paired ratios.  
- In 2009, OEIS sequence [A164544](https://oeis.org/A164544) (Kyle MacLean Smith) captured a special case approximating `1 + 2√2`.  
- In 2019, Smith recognized that this structure **generalizes beyond √2 to all √m** — with `a(n)/a(n-1)` converging to `1 + √m` and more generally `1 + k√m`.  
- Based on review of OEIS and Pell-related literature, there is no prior documentation of **a single-sequence integer recurrence systematically approximating √m for arbitrary m**.  

This marks a novel contribution in recurrence-based number theory with practical blockchain applications.

---

## Applications in AMMs

Automated Market Makers (AMMs) often require square root computations, e.g., in invariant and tick calculations.  

This recurrence-based method offers:  
- **Deterministic integer math** (no floats).  
- **Gas efficiency** (no division, just additions and multiplications).  
- **Progressive accuracy** (each step refines the approximation).  

**Practical AMM strategy:**  
1. Use the recurrence as a fast, gas-cheap approximation of `√m`.  
2. Apply **Newton–Raphson refinement** if higher precision is needed.  

This hybrid approach balances speed and accuracy while minimizing gas.

---

## Roadmap

- [ ] Extend contract for configurable `m` and `k`.  
- [ ] Benchmark recurrence-only vs Newton-enhanced hybrid.  
- [ ] Explore AMM tick integration (Uniswap v3 and beyond).  
- [ ] Compare gas savings against current sqrt libraries.  

---

## Citation

If using this work, please cite as:

> Kyle MacLean Smith (2019). *Single Integer Recurrence Approximation of 1 + √m.* Extended from [OEIS A164544](https://oeis.org/A164544). First generalization of Pell-type recurrences beyond √2 into a single universal recurrence.

---
