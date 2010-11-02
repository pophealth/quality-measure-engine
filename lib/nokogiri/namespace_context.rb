module Nokogiri
  class NamespaceContext
    def initialize(node, namespaces={})
      @ctx = Nokogiri::XML::XPathContext.new(node) 
      @ctx.register_namespaces(namespaces)
    end

    def first(expression)
      node_set = evaluate(expression)
      if node_set
        return node_set.first
      else
        return nil
      end
    end

    def evaluate(expression)
      @ctx.evaluate(expression)
    end
  end
end
