require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Synxronize::Tabber do

  after(:each) do
    Synxronize::Tabber.reset
  end

  describe "::increase" do
    it "should default to increasing tabbing by 1" do
      Synxronize::Tabber.increase
      expect(Synxronize::Tabber.current).to eq 1
      Synxronize::Tabber.increase
      expect(Synxronize::Tabber.current).to eq 2
    end

    it "should indent by the amount passed in" do
      Synxronize::Tabber.increase(3)
      expect(Synxronize::Tabber.current).to eq 3
      Synxronize::Tabber.increase(5)
      expect(Synxronize::Tabber.current).to eq 8
    end

  end

  describe "::decrease" do
    it "should default to decreasing tabbing by 1" do
      Synxronize::Tabber.increase
      Synxronize::Tabber.increase
      expect(Synxronize::Tabber.current).to eq 2
      Synxronize::Tabber.decrease
      expect(Synxronize::Tabber.current).to eq 1
    end

    it "should not do any more decreasing past 0 tabbing" do
      Synxronize::Tabber.increase
      Synxronize::Tabber.increase
      expect(Synxronize::Tabber.current).to eq 2
      Synxronize::Tabber.decrease
      expect(Synxronize::Tabber.current).to eq 1
      Synxronize::Tabber.decrease
      expect(Synxronize::Tabber.current).to eq 0
      Synxronize::Tabber.decrease
      expect(Synxronize::Tabber.current).to eq 0
      Synxronize::Tabber.increase
      expect(Synxronize::Tabber.current).to eq 1
    end
  end

  describe "::puts" do
    it "should call system's puts on the string, appending the appropraite indentation" do
      Synxronize::Tabber.increase(3)
      expect(Kernel).to receive(:puts).with("      Hello, world.")
      Synxronize::Tabber.puts("Hello, world.")
    end
  end

  describe "::a_single_tab" do
    it "should be two spaces" do
      expect(Synxronize::Tabber.send(:a_single_tab)).to eq "  "
    end
  end

end