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
        attr_writer :reconnect_timeout

        def initialize(options = {})
          @reconnect_count    = options.delete(:reconnect_count) || DEFAULT_RECONNECT
          @reconnect_timeout  = options.delete(:reconnect_timeout) || START
        end

        def reconnect_timeout
          @reconnect_timeout
        end

        def increment
          if maximum_reconnects?
            raise EM::Twitter::ReconnectLimitError.new("#{@reconnect_count} Reconnects")
          end

          yield @reconnect_timeout if block_given?

          @reconnect_count += 1
          @reconnect_timeout *= INCREMENTOR
        end

        def reset
          @reconnect_timeout = START
          @reconnect_count = DEFAULT_RECONNECT
        end

        private

        def maximum_reconnects?
          @reconnect_count > MAX_RECONNECTS || @reconnect_timeout > MAX_TIMEOUT
        end

      end
    end
  end
end
