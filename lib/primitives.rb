module BusScheme
  SYMBOL_TABLE = {}

  def self.define(identifier, value)
    SYMBOL_TABLE[identifier.sym] = value
  end

  def self.special_form(identifier, value)
    value.special_form = true
    SYMBOL_TABLE[identifier.sym] = value
  end

  define '#t', true
  define '#f', false

  define '+', lambda { |*args| args.inject { |sum, i| sum + i } }
  define '-', lambda { |x, y| x - y }
  define '*', lambda { |*args| args.inject { |product, i| product * i } }
  define '/', lambda { |x, y| x / y }

  define 'concat', lambda { |*args| args.join('') }
  define 'cons', lambda { |car, cdr| Cons.new(car, cdr) }
  define 'list', lambda { |*members| members.to_list }
  define 'vector', lambda { |*members| members.to_a }
  define 'map', lambda { |fn, list| list.map(lambda { |n| fn.call(n) }).sexp }
  
  define 'eval', lambda { |code| eval(code) }
  define 'stacktrace', lambda { Lambda.stacktrace }
  define 'fail', lambda { |message| raise AssertionFailed, "#{message}\n  #{Lambda.stacktrace.map{|frame| frame.join(":")}.join("\n  ")}" }
  
  define 'ruby', lambda { |*code| Kernel.eval code.join('') }
  define 'send', lambda { |obj, *message| obj.send(*message) }

  define 'load', lambda { |filename| BusScheme.load filename }
  define 'exit', lambda { exit }
  define 'quit', lambda { exit }

  # TODO: hacky to coerce everything to sexps... won't work once we start using vectors
  special_form 'quote', lambda { |arg| arg.sexp }
  special_form 'if', lambda { |q, yes, *no| eval(eval(q) ? yes : [:begin] + no) }
  special_form 'begin', lambda { |*args| args.map{ |arg| eval(arg) }.last }
  special_form 'lambda', lambda { |args, *form| Lambda.new(args, form) }
  special_form 'define', lambda { |sym, definition| Lambda[sym] = eval(definition); sym }
  special_form 'set!', lambda { |sym, value| raise EvalError.new unless Lambda.in_scope?(sym)
    Lambda[:define.sym].call(sym, value) }

  # TODO: once we have macros, this can be defined in scheme
  special_form 'and', lambda { |*args| args.all? { |x| eval(x) } }
  special_form 'or', lambda { |*args| args.any? { |x| eval(x) } }
  special_form 'let', lambda { |defs, *body| Lambda.new(defs.map{ |d| d.car }, body).call(*defs.map{ |d| eval d.last }) }
  special_form 'hash', lambda { |*args| args.to_hash } # accepts an alist
end
