# Volatility-Aware Ticks in AMMs (Solidity Experiment)

# Author's Note

This is a first draft with AI. It is a minimum viable demo by an individual inventor meant to encourage others to get involved academically or in industry.

## Intro

This README, with active links locally at [Volatility-Aware Ticks in AMMs (Solidity Experiment).pdf](./Volatility-Aware%20Ticks%20in%20AMMs%20(Solidity%20Experiment.pdf) and globally at [https://chatgpt.com/s/dr_68ba59016a54819190f1d62a7086ee8f](https://chatgpt.com/s/dr_68ba59016a54819190f1d62a7086ee8f), analyzes how our Solidity prototype – which demonstrates **single-sequence integer recurrences for approximating square roots** – could inform automated market maker (AMM) design, especially in concentrated-liquidity pools. In Uniswap-style AMMs, each “tick” is a fixed price step: by convention 1 tick = 0.01% price change (a 1.0001× multiplier)【7†L118-L127】【9†L38-L45】.  The contract’s ability to approximate such fine-grained exponents (for example, using inputs like `(1, 10001, 2)` to approximate the factor 1.0001) means we can generate small price increments on-chain. Below we discuss how tick spacing might vary by token type, and how Newton’s method could later be explored as a refinement step.

## Tick Spacing and Token Characteristics

AMMs can **tune tick granularity** to match token volatility and liquidity.  Each tick step corresponds to a price ratio (Uniswap uses \(p(i)=1.0001^i\))【9†L38-L45】.  Narrow tick spacing (small percentage steps) boosts precision, while wider spacing reduces the number of steps crossed for large price moves.  General guidelines are: 

- **Stablecoin / low-volatility pairs:** Use very *narrow* ticks (fine granularity).  Since stable pairs stay near a constant price, tighter spacing concentrates liquidity where trades happen【7†L139-L147】【15†L203-L208】.  Narrow spacing (e.g. 1-basis-point, 0.01% steps) improves capital efficiency and lowers slippage【7†L139-L147】【15†L203-L208】.
- **High-volatility assets:** Use *wider* ticks (coarser steps) to avoid frequent tick-crossing.  For a highly volatile pair, large price swings would otherwise hit many ticks (adding gas cost), so larger steps reduce crossing frequency【9†L74-L82】【18†L208-L213】.
- **High-liquidity pools:** Can tolerate *narrow* spacing.  When a pool has lots of liquidity, LPs can confidently concentrate it in tight ranges, so finer ticks are viable【18†L208-L213】.
- **Low-liquidity pools:** Benefit from *wider* spacing.  With little liquidity, each tick holds less depth; using larger steps avoids having extremely sparse liquidity at each tick【18†L208-L213】.

These principles align with Uniswap’s design: tick spacing is tied to fee tiers and volatility.  For example, Uniswap V3 governance added a 1 bps fee tier with tickSpacing=1 (0.01% steps) to better serve stablecoin pools【9†L132-L140】【15†L203-L208】.  In contrast, high-fee (volatile) pools have larger tick spacing (e.g. 0.3% steps) to balance precision and gas efficiency【9†L132-L140】【18†L208-L213】.  

## Single-Sequence Square Root Approximations

The key novelty here is the use of a **single linear recurrence** of integers to approximate values of the form \(1 + k\sqrt{m}\). This differs from classical Pell / Pell–Lucas methods, which require *two* interlinked sequences (numerator/denominator). By contrast, our approach uses just one sequence, making it simpler to implement in Solidity and cheaper on gas.

- *Example:* \(a(n) = 2a(n-1) + (m-1)a(n-2)\) has the property that \(a(n)/a(n-1) \to 1 + \sqrt{m}\).  
- More generally, variants like \(a(n) = 2a(n-1) + (k^2 m - 1)a(n-2)\) converge to \(1 + k\sqrt{m}\).  

This allows a Solidity contract to generate rational approximations to square roots — which in turn can be used to define tick multipliers for AMMs.

## Example: Approximating a 1.0001 Tick

To illustrate, consider approximating the base tick factor 1.0001.  Our contract can take an input like `(1, 10001, 2)` to generate the ratio \(a(n)/a(n-1)\) that converges near **1.0001**.  This shows that even tiny multipliers can be encoded: by choosing the integer recurrence parameters appropriately, we can construct ticks at the granularity of 0.01% (or even smaller if desired).

The key point is that our implementation handles this with **only one integer sequence**, unlike Pell-based double-sequence constructions. This makes the Solidity implementation lightweight.

## Implications for AMM Design

In summary, our Solidity experiment demonstrates that *adaptive tick spacing* and *on-chain recurrence-based math* can be combined in AMM technology.  AMMs could allow tick size to vary by pool (or even adjust dynamically) based on token volatility or liquidity, beyond the fixed 1.0001 step.  The recurrence-based approach gives deterministic integer-only approximations, which are gas-efficient.  

In the future, **Newton’s method** could be added as a refinement layer: once the recurrence provides a good approximation of \(\sqrt{m}\), Newton iterations could converge even faster to high precision.  This hybrid approach (recurrence baseline + Newton refinement) may be the optimal trade-off between precision and gas.

## Further Reading

The local file **Known recurrence sequences for $1+\sqrt m$.pdf**, available [here](https://chatgpt.com/share/68ba5836-e0c8-8008-a776-c6b856f86d51), provides more detail on the novelty and timestamp claims by **Kyle MacLean Smith**. It explains how single-sequence recurrences approximating \(1+\sqrt{m}\) (and \(1+k\sqrt{m}\)) were first recognized and generalized beyond Pell-type constructions.

**References:** Uniswap and Orca docs on ticks【7†L118-L127】【15†L203-L208】; Uniswap’s tick-fee design【9†L74-L82】【9†L132-L140】【18†L208-L213】; Curve’s on-chain math discussions【13†L43-L52】.
