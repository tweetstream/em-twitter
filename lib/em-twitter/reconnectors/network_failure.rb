module EventMachine
  module Twitter
    module Reconnectors
      class NetworkFailure

        START       = 0.25
        INCREMENTOR = 0.25

        MAX_RECONNECTS    = 10
        DEFAULT_RECONNECT = 0
        MAX_TIMEOUT       = 16

        attr_reader :reconnect_count
        attr_writer :reconnect_timeout

        def initialize(options = {})
          @reconnect_timeout  = options.delete(:reconnect_timeout) || START
          @reconnect_count    = options.delete(:reconnect_count) || DEFAULT_RECONNECT
        end

        def reconnect_timeout
          [@reconnect_timeout, MAX_TIMEOUT].min
        end

        def increment
          if maximum_reconnects?
            raise EM::Twitter::ReconnectLimitError.new("#{@reconnect_count} Reconnects")
          end

          yield @reconnect_timeout if block_given?

          @reconnect_count += 1
          @reconnect_timeout += INCREMENTOR
        end

        def reset
          @reconnect_timeout  = START
          @reconnect_count    = DEFAULT_RECONNECT
        end

        private

        def maximum_reconnects?
          @reconnect_count > MAX_RECONNECTS || @reconnect_timeout > MAX_TIMEOUT
        end

      end
    end
  end
end
