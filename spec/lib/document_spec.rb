# encoding: utf-8


require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "profile/document"


describe "Profile::Document" do
  context "define_profile" do

    it "should raise error if Profile::Document is not included" do
      lambda {
        class MyClassWithoutProfile
          define_profile :my_profile, %w(attr1 attr2)
        end
      }.should raise_error NoMethodError
    end


    it "should not raise NoMethodError on class profile definition"do
      lambda {
        class MyClassWithProfile
          include Profile::Document
          define_profile :my_profile, %w(attr1 attr2)
        end
      }.should_not raise_error
    end


    it "should not raise error if block is given and call this block" do
      class MyClassForBlockProfile
        include Profile::Document
      end

      __block_called = false
      lambda {
        MyClassForBlockProfile.send(:define_profile) do |p|
          __block_called = true
        end
      }.should_not raise_error
      __block_called.should be_true
    end
  end


  context "profile" do
    let(:values) { { :attr1 => "a", :attr2 => "b", :attr3 => "c" } }
    it "retrieves profiles on declarative definition" do
      class MyClassDeclarativeProfile
        include Profile::Document
        define_profile :profile1, %w(attr1 attr2)
        define_profile :profile2, %w(attr2 attr3)
        define_profile :profile3, %w(attr1 attr3)
        attr_accessor :attr1, :attr2, :attr3
      end
      c = MyClassDeclarativeProfile.new
      values.each_pair do |k, v|
        c.send("#{k}=", v)
      end
      c.profile.profile1.to_h.should eq({ :attr1 => values[:attr1], :attr2 => values[:attr2] })
      c.profile.profile2.to_h.should eq({ :attr2 => values[:attr2], :attr3 => values[:attr3] })
      c.profile.profile3.to_h.should eq({ :attr1 => values[:attr1], :attr3 => values[:attr3] })
    end


    it "retrieves profiles on block definition" do
      class MyClassDeclarativeProfile
        include Profile::Document
        define_profile do |p|
          p.profile1 = %w(attr1 attr2)
          p.profile2 = %w(attr2 attr3)
          p.profile3 = %w(attr1 attr3)
        end
        attr_accessor :attr1, :attr2, :attr3
      end
      c = MyClassDeclarativeProfile.new
      values.each_pair do |k, v|
        c.send("#{k}=", v)
      end
      c.profile.profile1.to_h.should eq({ :attr1 => values[:attr1], :attr2 => values[:attr2] })
      c.profile.profile2.to_h.should eq({ :attr2 => values[:attr2], :attr3 => values[:attr3] })
      c.profile.profile3.to_h.should eq({ :attr1 => values[:attr1], :attr3 => values[:attr3] })
    end


    it "hash argument defines profile" do
      class MyClassHashyProfile
        include Profile::Document
        attr_accessor :attr1, :attr2, :attr3
      end
      lambda { MyClassHashyProfile.send(:define_profile, :profile1, :key1 => :attr1, :key2 => :attr2, :key3 => :attr3) }.should_not raise_error
      c = MyClassHashyProfile.new
      values.each do |k, v|
        c.send("#{k}=", v)
      end
      lambda { c.profile.profile1 }.should_not raise_error
      c.profile.profile1.keys.should eq [:key1, :key2, :key3]
      c.profile.profile1.values.should eq values.values
    end


    it "should extend existing profile" do
      class MyClassExtendProfileWithBlock
        include Profile::Document
        attr_accessor :attr1, :attr2, :attr3, :attr4, :attr5
        define_profile do |p|
          p.profile1 = %w(attr1 attr2)
          p.profile2 = p.continue(:profile1, %w(attr3))
          p.profile3 = p.profile1.continue(%w(attr4))
          p.profile4 = p.profile1.continue(:attr3, :attr5)
        end
      end
      
      @c = MyClassExtendProfileWithBlock.new
      
      @values = []
      (1..5).each do |i|
        rnd = Random.rand(1E5)
        @values[i] = rnd
        @c.send("attr#{i}=", rnd)
      end
      
      def __check_by_mask(num, set)
        _keys = set.map { |i| "attr#{i}".to_sym }
        _values = set.map { |i| @values[i] }
        profile = @c.profile.send("profile#{num}")
        profile.keys.should eq _keys
        profile.values.should eq _values
      end

      __check_by_mask(1, [1, 2])
      __check_by_mask(2, [1, 2, 3])
      __check_by_mask(3, [1, 2, 4])
      __check_by_mask(4, [1, 2, 3, 5])
    end
  end
end
