require "minruby"

def evaluate(exp, env, context)
  case exp[0]

  when "lit"
    exp[1] # return the immediate value as is

  when "+"
    evaluate(exp[1], env, context) + evaluate(exp[2], env, context)
  when "-"
    evaluate(exp[1], env, context) - evaluate(exp[2], env, context)
  when "*"
    evaluate(exp[1], env, context) * evaluate(exp[2], env, context)
  when "/"
    evaluate(exp[1], env, context) / evaluate(exp[2], env, context)
  when "%"
    evaluate(exp[1], env, context) % evaluate(exp[2], env, context)
  when "=="
    evaluate(exp[1], env, context) == evaluate(exp[2], env, context)
  when "!="
    evaluate(exp[1], env, context) != evaluate(exp[2], env, context)
  when ">"
    evaluate(exp[1], env, context) > evaluate(exp[2], env, context)
  when ">="
    evaluate(exp[1], env, context) >= evaluate(exp[2], env, context)
  when "<"
    evaluate(exp[1], env, context) < evaluate(exp[2], env, context)
  when "<="
    evaluate(exp[1], env, context) <= evaluate(exp[2], env, context)


  when "stmts"
    statements = tail(exp, 1)
    retval = nil

    i = 0
    while statements[i]
      retval = evaluate(statements[i], env, context)
      i = i + 1
    end

    retval


  when "var_ref"
    var_name = exp[1]
    env[var_name]
  when "var_assign"
    var_name = exp[1]
    var_value = evaluate(exp[2], env, context)
    env[var_name] = var_value


  when "if"
    if evaluate(exp[1], env, context)
      evaluate(exp[2], env, context)
    else
      evaluate(exp[3], env, context)
    end

  when "while"
    while(evaluate(exp[1], env, context)) do
      evaluate(exp[2], env, context)
    end


  when "func_call"
    func = context[exp[1]]

    if func == nil
      case exp[1]
      when "require"
        require evaluate(exp[2], env, context)
      when "minruby_load"
        minruby_load()
      when "minruby_parse"
        minruby_parse(evaluate(exp[2], env, context))
      when "p"
        p(evaluate(exp[2], env, context))
      when "Integer"
        (evaluate(exp[2], env, context)).to_i
      when "fizzbuzz"
        n = exp[2]
        if n % 3 == 0 && n % 5 == 0
          'fizzbuzz'
        elsif n % 3 == 0
          'fizz'
        elsif n %5 == 0
          'buzz'
        else
          n
        end
      else
        raise("unknown builtin function: #{exp[1]}")
      end
    else
      real_params = tail(exp, 2).map{|e| evaluate(e, env, context) }

      i = 0
      local_env = {}
      while func["formal_params"][i]
        formal_param = func["formal_params"][i]
        real_param = real_params[i]
        local_env[formal_param] = real_param
        i = i + 1
      end

      evaluate(func["statement"], local_env, context)
    end

  when "func_def"
    func_name = exp[1]
    formal_params = exp[2]
    statement = exp[3]

    context[func_name] = {
      "func_name" => func_name,
      "formal_params" => formal_params,
      "statement" => statement,
    }


  when "ary_new"
    arr = []
    i = 0
    while exp[i + 1]
      arr[i] = exp[i + 1]
    end
    arr
  when "ary_ref"
    ary = evaluate(exp[1], env, context)
    index = evaluate(exp[2], env, context)
    ary[index]
  when "ary_assign"
    ary = evaluate(exp[1], env, context)
    index = evaluate(exp[2], env, context)
    ary[index] = evaluate(exp[3], env, context)

  when "hash_new"
    tail(exp, 1).each_slice(2).map{|ke, ve| [evaluate(ke, env, context), evaluate(ve, env, context) ] }.to_h

  else
    p("error")
    pp(
      {
        "context" => context,
        "exp" => exp,
        "env" => env,
      }
    )
    raise("unknown node")
  end
end

def tail(array, offset)
  result = []
  i = 0
  while array[i + offset]
    result[i] = array[i + offset]
    i = i + 1
  end
  result
end

global = {
}

env = {}

src = minruby_load()
ast = minruby_parse(src)
evaluate(ast, env, global)
