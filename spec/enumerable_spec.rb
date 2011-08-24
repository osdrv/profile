# encoding: utf-8


require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require "profile/document"


describe Enumerable do

  context "profile" do
    
    it "should fails if profile is not defined" do
      class MyClass ; end
      collection = collectionize(MyClass, 10)
      lambda { collection.profile(:my_profile) }.should raise_error NoMethodError
    end


    it "should works fine if Profile::Document is just included" do
      class MyClass
        include Profile::Document
      end
      collection = collectionize(MyClass, 10)
      lambda { collection.profile(:my_profile) }.should_not raise_error
    end
  end
end
