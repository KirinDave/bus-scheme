module BusScheme
  # RecursiveHash is needed to store Lambda environments
  class RecursiveHash < Hash
    # takes a hash and a parent
    def initialize(hash, parent)
      @parent = parent
      hash.each { |k, v| immediate_set k, v }
    end

    alias_method :immediate_has_key?, :has_key?
    alias_method :immediate_set, :[]=
    alias_method :immediate_lookup, :[]

    # Just your regular has stuff, only it takes the parent into account
    def has_key?(symbol)
      immediate_has_key?(symbol) or @parent && @parent.has_key?(symbol)
    end

    def [](symbol)
      immediate_lookup(symbol) or @parent && @parent[symbol]
    end

    def []=(symbol, value)
      if !immediate_has_key?(symbol) and @parent and @parent.has_key?(symbol)
        @parent[symbol] = value
      else
        immediate_set symbol, value
      end
    end
  end
end
