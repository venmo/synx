module Synx
  class Tabber

    @@quiet = false
    @@tabbing = 0

    class << self
      def increase(n=1)
        @@tabbing += n
      end

      def decrease(n=1)
       @@tabbing -= n
       @@tabbing = 0 if @@tabbing < 0
      end

      def current
        @@tabbing
      end

      def reset
        @@tabbing = 0
        self.quiet = false
      end

      def quiet=(quiet)
        @@quiet = quiet
      end

      def quiet?
        @@quiet
      end

      def puts(str="")
        Kernel.puts (a_single_tab * @@tabbing) + str.to_s unless quiet?
      end

      def a_single_tab
        return "  "
      end
      private :a_single_tab

    end
  end
end
