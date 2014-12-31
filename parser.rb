class UnknownFunctionError < StandardError; end
class ArityError < StandardError; end
class NotAListError < StandardError; end

def default_context
  {
    prepend: [:lambda,
              [:list, :h, :t],
              [:join, [:list, :h], :t]],
    map: [:lambda,
          [:list, :l, :x],
          [:prepend,
           [:x, [:head, :l]],
           [:map, [:tail, :l], :x]]],
    # prepend: [:lambda, [:list, :h, :t], [:join, [:list, :h], :t]],
    # prepend: [:lambda, [:list, :h, :t], [:join, [:list, :h], :t]],
  }
end

def parse_commands(commands, c = default_context)
  if commands.count == 1  # last command, we need the results (not the context)
    tparse(commands[0], c)
  else
    parse_commands(commands[1..-1], parse(commands[0], c)[1])
  end
end

# just a shortcut when we dont want the context, which is almost everywhere
# except parse_commands method above
def tparse(list, c)
  parse(list, c)[0]
end

def parse(list, c)
  c = c.dup
  puts "parsing: #{list}" if ENV["VERBOSE"]
  if list.kind_of? Array
    list[0] = tparse(list[0], c)
    case list[0]
    when :and
      require_arity(2, list)
      [tparse(list[1], c) && tparse(list[2], c), c]
    when :or
      require_arity(2, list)
      [tparse(list[1], c) || tparse(list[2], c), c]
    when :not
      require_arity(1, list)
      [!parse(list[1], c)[0], c]
    when :*
      require_arity(2, list)
      [tparse(list[1], c) * tparse(list[2], c), c]
    when :-
      require_arity(2, list)
      [tparse(list[1], c) - tparse(list[2], c), c]
    when :+
      require_arity(2, list)
      [tparse(list[1], c) + tparse(list[2], c), c]
    when :>
      require_arity(2, list)
      [tparse(list[1], c) > tparse(list[2], c), c]
    when :<
      require_arity(2, list)
      [tparse(list[1], c) < tparse(list[2], c), c]
    when :==
      require_arity(2, list)
      [tparse(list[1], c) == tparse(list[2], c), c]
    when :if
      require_arity(3, list)
      [(tparse(list[1], c) ? tparse(list[2], c) : tparse(list[3], c)), c]
    when :list
      require_arity((1..Float::INFINITY), list)
      [[:list, *(list[1..-1].map{ |a| tparse(a, c)  })], c]
    when :upto
      require_arity(2, list)
      [[:list, *(tparse(list[1], c)..tparse(list[2], c)).to_a], c]
    when :head, :car
      require_arity(1, list)
      [list_items(list[1], c)[0], c]
    when :tail, :cdr
      require_arity(1, list)
      v = list_items(list[1], c)
      [[:list, *v[1..-1]], c]
    # when :map
    #   require_arity(2, list)
    #   [[:list, *list_items(list[1], c).map { |i| tparse([list[2], i], c) }], c]
    when :reduce
      require_arity(2, list)
      [tparse(list_items(list[1], c).reduce { |m, x| [tparse(list[2], c), m, x]}, c), c]
    when :select
      require_arity(2, list)
      [[:list, *list_items(list[1], c).select { |i| tparse([list[2], i], c) }], c]
    when :list?
      require_arity(1, list)
      begin
        list_items(list[1], c)
        [true, c]
      rescue NotAListError
        [false, c]
      end
    when :join
      require_arity(2, list)
      [[:list, *(list_items(list[1], c) + list_items(list[2], c))], c]
    when :each
      require_arity(2, list)
      items = list_items(list[1], c).each { |i| tparse([list[2], i], c) }
      [[:list, *items], c]
    when :p
      require_arity(1, list)
      r = tparse(list[1], c)
      p r
      [r, c]
    when :lambda # function def
      require_arity(2, list)
      [list, c]
    when ->(f) { f[0] == :lambda} # function call
      cp = c.dup
      ar = list_items(list[0][1], cp).zip(list[1..-1])
      ar.each { |a| cp[a[0]] = tparse(a[1], c) }
      [tparse(list[0][2], cp), c]
    when :set
      require_arity(2, list)
      cp = c.dup
      cp[list[1]] = tparse(list[2], c)
      [list, cp]
    end
  else
    case list
    when ->(f){ c.keys.include? f } # macro...
      [c[list], c]
    else
      [list, c]
    end
  end
end

def require_arity(n, list)
  raise ArityError unless n === (list.count - 1)
end

def list_items(list, c)
  r = tparse(list, c)
  raise NotAListError unless r[0] == :list
  r[1..-1]
end
