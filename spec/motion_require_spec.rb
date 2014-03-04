require 'spec_helper'

describe Motion::Require do
  it 'should run' do
    true.should == true
  end

  describe 'should check_platform' do
    it 'should support `nil`' do
      Motion::Require.check_platform(:ios, nil).should == true
    end
    it 'should support Symbol' do
      Motion::Require.check_platform(:ios, :ios).should == true
      Motion::Require.check_platform(:ios, :osx).should == false
    end
    it 'should support Array' do
      Motion::Require.check_platform(:ios, [:ios]).should == true
      Motion::Require.check_platform(:ios, [:ios, :osx]).should == true
      Motion::Require.check_platform(:osx, [:ios, :osx]).should == true
      Motion::Require.check_platform(:ios, [:osx]).should == false
    end
  end
end