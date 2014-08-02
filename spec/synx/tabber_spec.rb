require 'spec_helper'

describe Synx::Tabber do

  before(:each) do
    Synx::Tabber.reset
    Synx::Tabber.options[:output] = output
  end

  let(:output) { StringIO.new }

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
    it "should print to the output io with the appropriate indentation" do
      Synx::Tabber.increase(3)
      Synx::Tabber.puts("Hello, world.")
      expect(output.string).to eq("      Hello, world.\n")
    end

    it "should not print anything if quiet is true" do
      Synx::Tabber.options[:quiet] = true
      Synx::Tabber.puts("Hello, world.")
      expect(output.string).to eq("")
    end

    it "should print colors if no_color is false or not present" do
      Synx::Tabber.puts("Hello, world.".red)
      expect(output.string).to eq("\e[0;31;49mHello, world.\e[0m\n")
    end

    it "should not print colors if no_color is true" do
      Synx::Tabber.options[:no_color] = true
      Synx::Tabber.puts("Hello, world.".red)
      expect(output.string).to eq("Hello, world.\n")
    end

    it "prints to stdout if no output is specified" do
      expect($stdout).to receive(:puts).with("  Hello, world.")
      Synx::Tabber.reset
      Synx::Tabber.increase
      Synx::Tabber.puts("Hello, world.")
    end
  end

  describe "::a_single_tab" do
    it "should be two spaces" do
      expect(Synx::Tabber.send(:a_single_tab)).to eq "  "
    end
  end

end
