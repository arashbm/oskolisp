class UnknownFunctionError < StandardError; end
class ArityError < StandardError; end

def parse(list, c)
  c = c.dup
  # puts "parsing: #{list}"
  if list.kind_of? Array
    case list[0]
    when :+
      require_arity(2, list)
      parse(list[1], c) + parse(list[2], c)
    when :and
      require_arity(2, list)
      parse(list[1], c) && parse(list[2], c)
    when :or
      require_arity(2, list)
      parse(list[1], c) || parse(list[2], c)
    when :not
      require_arity(1, list)
      !parse(list[1], c)
    when :*
      require_arity(2, list)
      parse(list[1], c) * parse(list[2], c)
    when :-
      require_arity(2, list)
      parse(list[1], c) - parse(list[2], c)
    when :>
      require_arity(2, list)
      parse(list[1], c) > parse(list[2], c)
    when :<
      require_arity(2, list)
      parse(list[1], c) < parse(list[2], c)
    when :==
      require_arity(2, list)
      parse(list[1], c) == parse(list[2], c)
    when :if
      require_arity(3, list)
      parse(list[1], c) ? parse(list[2], c) : parse(list[3], c)
    when :time
      require_arity(0, list)
      Time.now.to_i
    when :list
      require_arity(1, list)
      [:list, list[1]]
    when :map
      require_arity(2, list)
      [:list, list_items(list[1], c).map { |i| parse(list[2] + [i], c) }]
    when :each
      require_arity(2, list)
      items = list_items(list[1], c).each { |i| parse(list[2] + [i], c) }
      [:list, items]
    when :p
      require_arity(1, list)
      puts "printing: #{parse(list[1], c)}"
    when :defun
      require_arity(1, list)
      puts "printing: #{parse(list[1], c)}"
      # TODO: complete
    when ->(f) { c[:functions].keys.include? f }
      require_arity(c[:functions][f][:arg_names].count, list)
      args = Hash[c[:functions][f][:arg_names].zip list[1..list.count]]
      run_func(c[:functions][f][:defenition], args, c)
    else
      raise UnknownFunctionError
    end
  else
    list
  end
end

def require_arity(n, list)
  raise ArityError unless n === (list.count - 1)
end

def list_items(list, c)
  r = parse(list, c)
  raise NotAListError unless r[0] == :list
  r[1]
end

def run_func(d, args, c)
  c = c.dup
  args.each { |k, v| c[:variables][k] = v }
  parse(d, c)
end