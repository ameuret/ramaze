#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # = PartialHelper
  #
  # === Example Usage
  #
  #   class MyController
  #     def index
  #     end
  #     def list
  #       plain = request['plain']
  #       "Hello World from List!  Plain List == #{plain}"
  #     end
  #   end
  #
  #
  #   <html>
  #     <head><title>Partial Render Index</title></head>
  #     <body>
  #       #{render_partial(Rs(:list), 'plain' => true)}
  #     </body>
  #   </html>

  module PartialHelper

    private
    module_function

    # Renders a url 'inline'.
    #
    # url:      normal URL, like you'd use for redirecting.
    # options:  optional, will be used as request parameters.

    def render_partial(url, options = {})
      saved = {}
      options.keys.each {|x| saved[x] = Request.current.params[x] }
      saved_action = Action.current

      Request.current.params.update(options)

      Controller.handle(url)
    ensure
      Thread.current[:action] = saved_action
      options.keys.each {|x| Request.current.params[x] = saved[x] }
    end

    # Generate from a filename in template_root of the given (or current)
    # controller a new action.
    # Any option you don't pass is instead taken from Action.current

    def render_template(file, options = {})
      current = Action.current
      options[:controller] ||= current.controller
      options[:instance]   ||= current.instance.dup
      options[:binding]    ||= options[:instance].instance_eval{ binding }
      options[:template] = (options[:controller].template_root/file)

      action = Ramaze::Action(options)
      action.render
    ensure
      Thread.current[:action] = current
    end
  end
end
