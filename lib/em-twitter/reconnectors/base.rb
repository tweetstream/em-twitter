module EventMachine
  module Twitter
    module Reconnectors

      class Base
        attr_reader :reconnect_count
        attr_writer :reconnect_timer

        DEFAULT_RECONNECT = 0

        def initialize(options = {})
          @reconnect_count = options[:reconnect_count] || DEFAULT_RECONNECT
        end

        # implemented in the ApplicationFailure and NetworkFailure classes
        def increment
        end

        def reset
          @reconnect_count = DEFAULT_RECONNECT
        end

      end

    end
  end
end