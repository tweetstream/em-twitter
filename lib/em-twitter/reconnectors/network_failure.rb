module EventMachine
  module Twitter
    module Reconnectors
      class NetworkFailure

        START       = 0.25
        INCREMENTOR = 0.25
        MAX         = 16

        MAX_RECONNECTS    = 320
        DEFAULT_RECONNECT = 0

        attr_reader :reconnect_count
        attr_writer :reconnect_timer

        def initialize(options = {})
          @reconnect_timer = options.delete(:reconnect_timer) || START
          @reconnect_count = options.delete(:reconnect_count) || DEFAULT_RECONNECT
        end

        def reconnect_timer
          [@reconnect_timer, MAX].min
        end

        def increment
          @reconnect_count += 1
          @reconnect_timer += INCREMENTOR

          if @reconnect_count > MAX_RECONNECTS
            raise EM::Twitter::ReconnectLimitError.new("#{@reconnect_count} Reconnects")
          end

          yield @reconnect_timer if block_given?
        end

        def reset
          @reconnect_timer = START
          @reconnect_count = DEFAULT_RECONNECT
        end

      end
    end
  end
end