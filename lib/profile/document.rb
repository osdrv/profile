require "rubygems"

module Profile
  module Document
    

    class ProfileSet
      attr_accessor :fields, :__obj

      def initialize(fields)
        self.fields = flatten_fields(fields)
      end


      def to_h
        res = {}
        if !fields.nil? && fields.any?
          fields.each_pair do |k, v|
            res[k.to_sym] = __obj.send(v)
          end
          res
        end
      end


      def values; to_h.values; end
      def keys; to_h.keys; end
      def inspect; to_h; end
      def to_json; to_h.to_json; end
      def to_xml; to_h.to_xml; end


      def and_more(*fields)
        self.fields.merge(flatten_fields(fields))
      end


      def continue(*fields)
        self.class.new(self.fields.merge(flatten_fields(fields)))
      end
      

      def with(obj)
        self.__obj = obj  
      end

      
      protected


      def flatten_fields(fields)
        fields = fields
        if !fields.first.is_a?(Hash)
          fields = Hash[fields.flatten.each.map{ |e| [e, e] }]
        else
          fields = fields.first
        end
        fields
      end
    end


    class ProfileProxy
      attr_accessor :__profile_pool, :__obj
      
      
      def method_missing(m, *args)
        self.__profile_pool ||= {}
        if m.to_s[/\=$/]
          profile_name = m[/^([^=]+)/].to_sym
          profile = args.first
          profile_class = Profile::Document::ProfileSet
          if !profile.is_a?(profile_class)
            profile = profile_class.new(args.flatten)
          end
          self.__profile_pool[profile_name] = profile
        else
          p = self.__profile_pool[m.to_sym]
          p.with(self.__obj) if !p.nil? && self.__obj
          p
        end
      end


      def continue(profile, fields)
        if !profile.is_a?(Profile::Document::ProfileSet)
          profile = self.__profile_pool[profile.to_sym]
        end
        profile.continue(fields)
      end


      def with(obj)
        self.__obj = obj
        self
      end
    end


    module InstanceMethods
      def profile
        (self.class.__profile ||= Profile::Document::ProfileProxy.new).with(self)
      end
    end


    module ClassMethods
      def define_profile(*args)
        self.__profile ||= Profile::Document::ProfileProxy.new
        if block_given?
          yield (self.__profile)
        elsif args.length == 2
          args[0] = "#{args[0]}=".to_sym
          self.__profile.send(*args)
        else
          raise "Invalid argument set."
        end
      end
    end


    def self.included(base)
      base.class.send(:attr_accessor, :__profile)
      base.send(:extend, ClassMethods)
      base.send(:include, InstanceMethods)
    end

  end
end
