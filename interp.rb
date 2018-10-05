require "minruby"

# An implementation of the evaluator
def evaluate(exp, env)
  # exp: A current node of AST
  # env: An environment (explained later)

  case exp[0]

#
## Problem 1: Arithmetics
#

  when "lit"
    exp[1] # return the immediate value as is

  when "+"
    evaluate(exp[1], env) + evaluate(exp[2], env)
  when "-"
    evaluate(exp[1], env) - evaluate(exp[2], env)
  when "*"
    evaluate(exp[1], env) * evaluate(exp[2], env)
  when "/"
    evaluate(exp[1], env) / evaluate(exp[2], env)
  when "%"
    evaluate(exp[1], env) % evaluate(exp[2], env)
  when "=="
    evaluate(exp[1], env) == evaluate(exp[2], env)
  when "!="
    evaluate(exp[1], env) != evaluate(exp[2], env)
  when ">"
    evaluate(exp[1], env) > evaluate(exp[2], env)
  when ">="
    evaluate(exp[1], env) >= evaluate(exp[2], env)
  when "<"
    evaluate(exp[1], env) < evaluate(exp[2], env)
  when "<="
    evaluate(exp[1], env) <= evaluate(exp[2], env)

#
## Problem 2: Statements and variables
#

  when "stmts"
    exp[1..-1].each do |func_call|
      evaluate(func_call, env)
    end

  # The second argument of this method, `env`, is an "environement" that
  # keeps track of the values stored to variables.
  # It is a Hash object whose key is a variable name and whose value is a
  # value stored to the corresponded variable.

  when "var_ref"
    var_name = exp[1]
    env[var_name]

  when "var_assign"
    var_name = exp[1]
    var_value = evaluate(exp[2], env)
    env[var_name] = var_value

#
## Problem 3: Branchs and loops
#

  when "if"
    if evaluate(exp[1], env)
      evaluate(exp[2], env)
    else
      evaluate(exp[3], env)
    end

  when "while"
    while(evaluate(exp[1], env)) do
      evaluate(exp[2], env)
    end

#
## Problem 4: Function calls
#

  when "func_call"
    func = $function_definitions[exp[1]]

    if func.nil?
      # We couldn't find a user-defined function definition;
      # it should be a builtin function.
      # Dispatch upon the given function name, and do paticular tasks.
      case exp[1]
      when "p"
        # MinRuby's `p` method is implemented by Ruby's `p` method.
        p(evaluate(exp[2], env))
      when "Integer"
        (evaluate(exp[2], env)).to_i
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
        raise("unknown builtin function")
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

      real_params = exp[2..-1].map{|e| evaluate(e, env) }
      local_env = func[:formal_params].zip(real_params).to_h
      evaluate(func[:statement], local_env)
    end

  when "func_def"
    # Function definition.
    #
    # Add a new function definition to function definition list.
    # The AST of "func_def" contains function name, parameter list, and the
    # child AST of function body.
    # All you need is store them into $function_definitions.
    #
    # Advice: $function_definitions[???] = ???

    func_name = exp[1]
    formal_params = exp[2]
    statement = exp[3]

    $function_definitions[func_name] = {
      func_name: func_name,
      formal_params: formal_params,
      statement: statement,
    }

#
## Problem 6: Arrays and Hashes
#

  when "ary_new"
    exp[1..-1].map{|e| evaluate(e, env) }

  when "ary_ref"
    ary = evaluate(exp[1], env)
    index = evaluate(exp[2], env)
    ary[index]

  when "ary_assign"
    ary = evaluate(exp[1], env)
    index = evaluate(exp[2], env)
    ary[index] = evaluate(exp[3], env)

  when "hash_new"
    raise(NotImplementedError) # Problem 6

  else
    p("error")
    pp(exp)
    pp(env)
    raise("unknown node")
  end
end


$function_definitions = {
}

env = {}

# `minruby_load()` == `File.read(ARGV.shift)`
# `minruby_parse(str)` parses a program text given, and returns its AST
src = minruby_load()
ast = minruby_parse(src)
evaluate(ast, env)
