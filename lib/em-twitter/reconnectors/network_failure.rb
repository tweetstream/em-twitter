module EventMachine
  module Twitter
    module Reconnectors
      class NetworkFailure < Base

        START       = 0.25
        INCREMENTOR = 0.25
        MAX         = 16

        def initialize(options = {})
          @reconnect_timer = options[:reconnect_timer] || START
          super
        end

        def reconnect_timer
          [@reconnect_timer, MAX].min
        end

        def increment
          @reconnect_count += 1
          @reconnect_timer += INCREMENTOR
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