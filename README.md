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

- For `m = 2`, this corresponds to the classical Pell sequence approximations to √2.  
- For **general m > 1**, this same recurrence still generates rational approximations to `1 + √m`.  

This extends the Pell-type approach beyond √2 to arbitrary square roots, **using one and only one recurrence form**.

---

## Novelty & Verification

- In 2009, the OEIS sequence [A164544](https://oeis.org/A164544) was contributed by **Kyle MacLean Smith**, demonstrating the recurrence for √2.  
- In 2019, Smith recognized and published that this same recurrence pattern **generalizes to all √m**, not just √2.  
- Based on a review of existing literature and OEIS entries, there is **no prior record of a single integer recurrence systematically approximating √m for arbitrary m**.  
- Thus, this contribution establishes the first explicit use of a **single integer recurrence** to approximate roots beyond √2.

---

## Applications in AMMs

Automated Market Makers (AMMs) often require square root computations, e.g., in invariant calculations.  

This recurrence-based method offers:  
- **Deterministic integer math** (avoids floating-point issues).  
- **Gas efficiency** (no division or Newton iteration needed at first).  
- **Progressive accuracy** (sequence converges with each step).  

**Practical strategy for AMMs:**  
1. Use the integer recurrence for an efficient *first approximation*.  
2. Apply **Newton–Raphson refinement** only if higher precision is required.  

This hybrid approach minimizes gas while maintaining mathematical rigor.

---

## Roadmap

- [ ] Extend contract for configurable `m` values.  
- [ ] Implement Newton–Raphson fallback for high-precision finalization.  
- [ ] Explore integration with Uniswap v3-style tick math.  
- [ ] Benchmark gas efficiency vs. existing sqrt implementations.  

---

## Citation

If using this work, please cite as:

> Kyle MacLean Smith (2019). *Integer Recurrence Approximation of 1 + √m via Single Linear Recurrence.* Extended from [OEIS A164544](https://oeis.org/A164544). First generalization of Pell-type recurrences beyond √2 into a single, universal form.

---
