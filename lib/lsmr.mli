(** Logarithmic Market Scoring Rule (LMSR) implementation.

    A market maker for prediction markets based on Robin Hanson's LMSR. The
    market maintains a vector of quantities (shares outstanding per outcome) and
    uses the softmax function to derive prices from quantities.

    References:
    - https://mason.gmu.edu/~rhanson/mktscore.pdf
    - http://blog.oddhead.com/2006/10/30/implementing-hansons-market-maker/
    - https://claude.ai/share/9a26b6bf-02a5-40b2-af81-8a2542ba146a *)

type t = { b : float; qs : float array }
(** The market state: a liquidity parameter b and a vector of quantities. *)

val init : b:float -> n:int -> t
(** [init ~b ~n] creates a market with n outcomes and liquidity parameter b. All
    quantities start at zero, so initial prices are uniform 1/n. Higher b means
    more liquidity: traders must buy more shares to move prices. The market
    maker's worst-case loss is bounded by b * ln(n). *)

val lse : logits:float array -> temp:float -> float
(** [lse ~logits ~temp] computes the log-sum-exp of logits at temperature temp.
    Uses the max-subtraction trick for numerical stability. LSE(q/t) = ln(sum of
    exp(qi/t)) *)

val cost_function : t -> float
(** [cost_function market] returns b * LSE(q/b), the total cost paid by all
    traders to reach the current state. The gradient of this function with
    respect to qi gives the spot price of outcome i. *)

val spot_price : t -> outcome:int -> float
(** [spot_price market ~outcome] returns the current price of outcome,
    equivalent to softmax(q/b) for that outcome. Prices are in (0, 1) and sum to
    1 across all outcomes, so they form a probability distribution. *)

val trade_cost : t -> outcome:int -> nshares:float -> float
(** [trade_cost market ~outcome ~nshares] returns the cost of buying nshares of
    outcome at current market state. Negative nshares for selling. Computed as
    C(q') - C(q) where q' has the updated quantity. Note: this does not mutate
    the market. *)

val move_to_price : t -> outcome:int -> price:float -> float
(** [move_to_price market ~outcome ~price] returns the number of shares of
    outcome needed to move its spot price to price. Derived by inverting the
    softmax: qi = b * (logit(p) + LSE(q without i / b)). Returns a share delta,
    not a new quantity. *)

val execute_buy : t -> outcome:int -> nshares:float -> t
(** [execute_buy market ~outcome ~nshares] returns a new market with nshares
    added to outcome's quantity. Use negative nshares to sell. *)
