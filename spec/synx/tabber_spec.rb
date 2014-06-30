require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Synx::Tabber do

  before(:each) do
    Synx::Tabber.reset
  end

  describe "::increase" do
    it "should default to increasing tabbing by 1" do
      Synx::Tabber.increase
      expect(Synx::Tabber.current).to eq 1
      Synx::Tabber.increase
      expect(Synx::Tabber.current).to eq 2
    end

    it "should indent by the amount passed in" do
      Synx::Tabber.increase(3)
      expect(Synx::Tabber.current).to eq 3
      Synx::Tabber.increase(5)
      expect(Synx::Tabber.current).to eq 8
    end

  end

  describe "::decrease" do
    it "should default to decreasing tabbing by 1" do
      Synx::Tabber.increase
      Synx::Tabber.increase
      expect(Synx::Tabber.current).to eq 2
      Synx::Tabber.decrease
      expect(Synx::Tabber.current).to eq 1
    end

    it "should not do any more decreasing past 0 tabbing" do
      Synx::Tabber.increase
      Synx::Tabber.increase
      expect(Synx::Tabber.current).to eq 2
      Synx::Tabber.decrease
      expect(Synx::Tabber.current).to eq 1
      Synx::Tabber.decrease
      expect(Synx::Tabber.current).to eq 0
      Synx::Tabber.decrease
      expect(Synx::Tabber.current).to eq 0
      Synx::Tabber.increase
      expect(Synx::Tabber.current).to eq 1
    end
  end

  describe "::puts" do
    it "should call system's puts on the string, appending the appropraite indentation" do
      Synx::Tabber.increase(3)
      expect(Kernel).to receive(:puts).with("      Hello, world.")
      Synx::Tabber.puts("Hello, world.")
    end

    it "should not print anything if quiet is true" do
      Synx::Tabber.options = { quiet: true }
      expect(Kernel).to_not receive(:puts)
      Synx::Tabber.puts("Hello, world.")
    end

    it "should print colors if no_color is false or not present" do
      expect(Kernel).to receive(:puts).with("\e[0;31;49mHello, world.\e[0m")
      Synx::Tabber.puts("Hello, world.".red)
    end

    it "should not print colors if no_color is true" do
      Synx::Tabber.options = { no_color: true }
      expect(Kernel).to receive(:puts).with("Hello, world.")
      Synx::Tabber.puts("Hello, world.".red)
    end
  end

  describe "::a_single_tab" do
    it "should be two spaces" do
      expect(Synx::Tabber.send(:a_single_tab)).to eq "  "
    end
  end

end
