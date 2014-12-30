[
  [:set, :fib,
   [:lambda,
    [:list, :x],
    [:if, [:<, :x, 3],
     1,
     [:+,
      [:fib, [:-, :x, 1]],
      [:fib, [:-, :x, 2]]]]]],


  [:p, "fib 10:"],
  [:p, [:fib, 10]],

  [:p, "first 5 using literal lists:"],
  [:map, [:list, 1,2,3,4,5],
   [:lambda, [:list, :x], [:p, [:fib, :x]]]],

  [:p, "fib 1 to 15 using upto:"],
  [:map,
   [:upto, 1, 15],
   [:lambda, [:list, :x], [:p, [:fib, :x]]]]
]
