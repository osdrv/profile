module Profile
  $:.push(File.expand_path(File.dirname(__FILE__)))
  require "enumerable"
  require "profile/document"


  module Version
    MAJOR = 0
    MINOR = 2
    PATCH = 0
    BUILD = nil

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')
  end
end
