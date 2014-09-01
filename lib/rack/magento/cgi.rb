require 'childprocess'

class Rack::Magento::Cgi

  # Will setup a new instance of the CGI middleware executing
  # programs located in the given `public_dir`
  def initialize app, public_dir=Dir.getwd
    @app = app
    @public_dir = public_dir
  end

  # Middleware, so if it looks like we can run it then do so.
  # Otherwise send it on for someone else to handle.
  def call env
    path = env['PATH_INFO']
    path = path[1..-1] if path =~ /\//
    path = ::File.expand_path path, @public_dir
    if valid? path
      run env, path
    else
      @app.call env
    end
  end

  # Only pass to PHP if the file doesn't exist of is a PHP file.
  def valid?(path)
    path.start_with?(::File.expand_path @public_dir) &&
         (!::File.file?(path) || path =~ /\.php/)
  end
  private

  # Will run the given path with the given environment
  def run env, path
  # Setup CGI process
    cgi = ChildProcess.build 'php-cgi' #path
    cgi.duplex = true
    # cgi.cwd = File.dirname path
    # Arrange CGI processes IO
    cgi_out, cgi.io.stdout = IO.pipe
    cgi.io.stderr = $stderr
    # Config CGI environment

    # PHP-CGI will refuse to run script without REDIRECT_STATUS set.
    cgi.environment['REDIRECT_STATUS'] = 'test'
    cgi.environment['DOCUMENT_ROOT'] = @public_dir
    cgi.environment['SERVER_SOFTWARE'] = 'Rack Legacy'

    #@todo: fix for other entrie point also.
    cgi.environment['SCRIPT_FILENAME'] = @public_dir+'/index.php'

    # Workaround get magento to recognise request path
    # Mage_Core_Controller_Request_Http::getHttpHost() changes parent signature, so that zend router will not remove the
    # port from the URI in Zend_Controller_Request_Http::setRequestUri()
    cgi.environment['HTTP_X_ORIGINAL_URL'] = env['REQUEST_PATH']

    # Set Magento Dev Mode.
    cgi.environment['MAGE_IS_DEVELOPER_MODE'] = true
    env.each do |key, value|
      cgi.environment[key] = value if
          value.respond_to?(:to_str) && key =~ /^[A-Z_]+$/
    end
    # Start running CGI
    cgi.start
    # Delegate IO to CGI process
    cgi.io.stdin.write env['rack.input'].read if env['rack.input']
    cgi.io.stdout.close
    # Extract headers from output
    headers = {}
    until cgi_out.eof? || (line = cgi_out.readline.chomp) == ''
      if line =~ /\s*\:\s*/
        key, value = line.split /\s*\:\s*/, 2
        if headers.has_key? key
          headers[key] += "\n" + value
        else
          headers[key] = value
        end
      end
    end
    # Extract status from sub-process, default to 200
    status = (headers.delete('Status') || 200).to_i
    # Throw error if process crashed.
    # NOTE: Process could still be running and crash later. This just
    # ensure we response correctly if it immmediately crashes
    raise Rack::Magento::ExecutionError if cgi.crashed?
    # Send status, headers and remaining IO back to rack
    [status, headers, cgi_out]
  end
end
