
class Rack::Magento::SetOrigUri

  def initialize app
    @app = app
  end

  def call env
    # Workaround get magento to recognise request path
    # Mage_Core_Controller_Request_Http::getHttpHost() changes parent signature, so that zend router will not remove the
    # port from the URI in Zend_Controller_Request_Http::setRequestUri()
    uri = URI.parse(env['REQUEST_URI'])
    env['HTTP_X_ORIGINAL_URL'] = uri.request_uri
    @app.call env
  end
end
