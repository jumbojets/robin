open Robin
open Printf

let () =
  let market = Lsmr.init ~b:100. ~n:2 in
  let trade_cost = Lsmr.trade_cost market ~outcome:0 ~nshares:10. in
  printf "Buy 10 shares of outcome 0: %f\n" trade_cost;

  let market =
    market
    |> Lsmr.execute_buy ~outcome:0 ~nshares:50.
    |> Lsmr.execute_buy ~outcome:1 ~nshares:10.
  in
  printf "Market state after trades: b = %f, qs = [%f, %f]\n" market.b
    market.qs.(0) market.qs.(1);

  let price = Lsmr.spot_price market ~outcome:0 in
  printf "Spot price for outcome 0: %f\n" price;
  let price = Lsmr.spot_price market ~outcome:1 in
  printf "Spot price for outcome 1: %f\n" price;

  let trade_cost = Lsmr.trade_cost market ~outcome:0 ~nshares:(-10.) in
  printf "Sell 10 shares of outcome 0: %f\n" trade_cost;

  let move_to_price = Lsmr.move_to_price market ~outcome:0 ~price:0.7 in
  printf "Move to price 0.7 for outcome 0: %f\n" move_to_price
