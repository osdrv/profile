= profile


Simple tool to define objects named data sets


Usage
-----
  class MyClass
    include Profile::Document
    define_profile :some_profile, %w(attr0 attr1 meth0)
    attr_accessor :attr0, attr1, attr2

    def meth0
      "#{attr0}: #{attr1}"
    end
  end

  c = MyClass.new
  c.attr0 = "foo"
  c.attr1 = "bar"
  c.attr2 = "tar"

  p c.profile.some_profile
  # produces { :attr0 => "foo", :attr1 => "bar", :meth0 => "foo: bar" }
  

  # profile also extends ruby enumerable instances:
  collection = []
  class A
    include Profile::Document
    define_profile :b, %w(foo bar)
    attr_accessor :foo
    
    def bar
      foo * foo
    end
  end

  10.times do |i|
    obj = A.new
    obj.foo = i
    collection << i
  end

  p collection.profile(:b)
  # produces [{:foo=>0, :bar=>0}, {:foo=>1, :bar=>1},
    {:foo=>2, :bar=>4}, {:foo=>3, :bar=>9}, {:foo=>4, :bar=>16}, 
    {:foo=>5, :bar=>25}, {:foo=>6, :bar=>36}, {:foo=>7, :bar=>49}, 
    {:foo=>8, :bar=>64}, {:foo=>9, :bar=>81}]


  # new in version 0.2

  You can define prfiles via hash, this way input hash keys would be a result keys, and input key values would be an instance methods to call when profile builds.

  class B
    include Profile::Document
    define profile :b, :k1 => v1, :k2 => v2
    attr_accessor :v1
    
    def v2
      v1 * v1
    end
  end

  b = B.new
  b.v1 = 5
  p b.profile.b
  # produces {:k1=>5, :k2=>25}

  # new in version 0.3

  class C
    
  end

== Real life usage
This gem may be powerful using with rails and [inherited_resources](https://github.com/josevalim/inherited_resources) gem when your model become fat. Suppose you need to render select options using json API. No reason to transfer all the model objects data in this case. Example below show how to reject useless fields in API response:

# apps/controllers/items.rb
class ItemsController < InheritedResources::Base
  respond_to :json, :xml, :html
  def index
    index! do |wants|
      wants.json { respond_with collection.profile(:json) }
      wants.xml { respond_with collection.profile(:xml) }
    end
  end
end

# apps/models/item.rb
# No mater object model you are using here
# Here is an example with mongoid odm:
class Item
  include Mongoid::Document
  include Profile::Document
  field :title
  field :description # ok, description is helpful for api
  field :wery_wery_long_text # but this field is not
  
  define_profile do |p|
    p.xml = { :id => :_id, :brief => :description }
    p.json = p.xml.continue(%w(extra)) # so, json profile would contain th same fields as xml extended by extra field
  end

  def extra
    # something helpful here
    ...
  end
end

== Copyright

Copyright (c) 2011 4pcbr. See LICENSE.txt for
further details.


