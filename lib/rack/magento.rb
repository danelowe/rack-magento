require 'rack/magento/version'
# require 'rack/showexceptions'
# require 'rack/request'
# require 'childprocess'

module Rack
 module Magento
   class ExecutionError < StandardError
   end
 end
end

require 'rack/magento/cgi'
require 'rack/magento/set_orig_uri'

