[
  [:set, :fact,
   [:lambda,
    [:list, :x],
    [:if, [:==, :x, 1],
     1,
     [:*, :x, [:fact, [:+, :x, -1]]]]]],


  [:p, "factorial of 12 is"],
  [:p, [:fact, 12]]
]
