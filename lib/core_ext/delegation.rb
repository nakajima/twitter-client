module Twitter
  module Delegation
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def delegate(*args)
        opts = args.last.is_a?(Hash) ? args.pop : {}
        if target = opts[:to]
          args.each do |sym|
            class_eval(<<-END, __FILE__, __LINE__)
              def #{sym}(*args, &block)
                send(#{target.inspect}) \
                  .send(#{sym.inspect}, *args, &block)
              end
            END
          end
        else
          raise ArgumentError, "You must pass a target as :to option"
        end
      end
    end
  end
end