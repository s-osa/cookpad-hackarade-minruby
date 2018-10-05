require "minruby"

def evaluate(exp, env, context)
  # exp: A current node of AST
  # env: An environment (explained later)

  case exp[0]

#
## Problem 1: Arithmetics
#

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

#
## Problem 2: Statements and variables
#

  when "stmts"
    statements = tail(exp, 1)
    retval = nil

    i = 0
    while i < statements.size
      retval = evaluate(statements[i], env, context)
      i = i + 1
    end

    retval

  # The second argument of this method, `env`, is an "environement" that
  # keeps track of the values stored to variables.
  # It is a Hash object whose key is a variable name and whose value is a
  # value stored to the corresponded variable.

  when "var_ref"
    var_name = exp[1]
    env[var_name]

  when "var_assign"
    var_name = exp[1]
    var_value = evaluate(exp[2], env, context)
    env[var_name] = var_value

#
## Problem 3: Branchs and loops
#

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

#
## Problem 4: Function calls
#

  when "func_call"
    func = context[exp[1]]

    if func == nil
      # We couldn't find a user-defined function definition;
      # it should be a builtin function.
      # Dispatch upon the given function name, and do paticular tasks.
      case exp[1]
      when "require"
        require evaluate(exp[2], env, context)
      when "minruby_load"
        minruby_load()
      when "minruby_parse"
        minruby_parse(evaluate(exp[2], env, context))
      when "p"
        # MinRuby's `p` method is implemented by Ruby's `p` method.
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

#
## Problem 5: Function definition
#

      # (You may want to implement "func_def" first.)
      #
      # Here, we could find a user-defined function definition.
      # The variable `func` should be a value that was stored at "func_def":
      # parameter list and AST of function body.
      #
      # Function calls evaluates the AST of function body within a new scope.
      # You know, you cannot access a varible out of function.
      # Therefore, you need to create a new environment, and evaluate the
      # function body under the environment.
      #
      # Note, you can access formal parameters (*1) in function body.
      # So, the new environment must be initialized with each parameter.
      #
      # (*1) formal parameter: a variable as found in the function definition.
      # For example, `a`, `b`, and `c` are the formal parameters of
      # `def foo(a, b, c)`.

      real_params = tail(exp, 2).map{|e| evaluate(e, env, context) }

      i = 0
      local_env = {}
      while i < func["formal_params"].size
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

#
## Problem 6: Arrays and Hashes
#

  when "ary_new"
    arr = []
    i = 0
    while i + 1 < exp.size
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
    pp(exp)
    pp(env)
    raise("unknown node")
  end
end

def tail(array, offset)
  result = []
  i = 0
  while i + offset < array.size
    result[i] = array[i + offset]
    i = i + 1
  end
  result
end

global = {
}

env = {}

# `minruby_load()` == `File.read(ARGV.shift)`
# `minruby_parse(str)` parses a program text given, and returns its AST
src = minruby_load()
ast = minruby_parse(src)
evaluate(ast, env, global)
