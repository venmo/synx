module Synx
  class Tabber

    @options = {}
    @tabbing = 0

    class << self
      def increase(n=1)
        @tabbing += n
      end

      def decrease(n=1)
       @tabbing -= n
       @tabbing = 0 if @tabbing < 0
      end

      def current
        @tabbing
      end

      def reset
        @tabbing = 0
        self.options = {}
      end

      def options=(options = {})
        @options = options
      end

      def options
        @options
      end

      def puts(str="")
        str = str.uncolorize if options[:no_color]
        output.puts (a_single_tab * @tabbing) + str.to_s unless options[:quiet]
      end

      def a_single_tab
        return "  "
      end
      private :a_single_tab

      def output
        options.fetch(:output, $stdout)
      end
      private :output

    end
  end
end
