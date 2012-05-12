module EventMachine
  module Twitter
    module Reconnectors
      class ApplicationFailure

        START       = 10
        INCREMENTOR = 2

        MAX_RECONNECTS    = 10
        DEFAULT_RECONNECT = 0
        MAX_TIMEOUT       = 320

        attr_reader :reconnect_count
        attr_writer :reconnect_timer

        def initialize(options = {})
          @reconnect_count = options.delete(:reconnect_count) || DEFAULT_RECONNECT
          @reconnect_timer = options.delete(:reconnect_timer) || START
        end

        def reconnect_timer
          @reconnect_timer
        end

        def increment
          @reconnect_count += 1
          @reconnect_timer *= INCREMENTOR

          if maximum_reconnects?
            raise EM::Twitter::ReconnectLimitError.new("#{@reconnect_count} Reconnects")
          end

          yield @reconnect_timer if block_given?
        end

        def reset
          @reconnect_timer = START
          @reconnect_count = DEFAULT_RECONNECT
        end

        private

        def maximum_reconnects?
          @reconnect_count > MAX_RECONNECTS || @reconnect_timer > MAX_TIMEOUT
        end

      end
    end
  end
end