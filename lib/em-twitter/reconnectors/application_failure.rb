module EventMachine
  module Twitter
    module Reconnectors
      class ApplicationFailure < Base

        START       = 10
        INCREMENTOR = 2

        def initialize(options = {})
          @reconnect_timer = options[:reconnect_timer] || START
          super
        end

        def reconnect_timer
          @reconnect_timer
        end

        def increment
          @reconnect_count += 1
          @reconnect_timer *= INCREMENTOR
          yield if block_given?
        end

        def reset
          @reconnect_timer = START
          super
        end

      end
    end
  end
end