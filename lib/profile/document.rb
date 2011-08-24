require "active_support"

module Profile
  module Document
    
    extend ::ActiveSupport::Concern


    class ProfileDefiner
       
      attr_accessor :__profile, :__obj
      

      def method_missing(m, *args)
        if m.to_s[/\=$/]
          (self.__profile ||= {})[m[/^([^=]+)/].to_sym] = args.flatten
        else
          fields = self.__profile[m.to_sym] if !self.__profile.nil?
          res = {}
          if !fields.nil? && fields.any?
            fields.each do |f|
              res[f.to_sym] = __obj.send(f)
            end
            res
          end
          res
        end
      end
      
      
      def with(obj)
        self.__obj = obj
        self
      end
    end


    module InstanceMethods
      def profile
        (self.class.__profile ||= ProfileDefiner.new).with(self)
      end
    end


    module ClassMethods
      def define_profile(*args)
        self.__profile ||= ProfileDefiner.new
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


    included do
      class << self
        attr_accessor :__profile
      end
      extend ClassMethods
    end

  end
end
