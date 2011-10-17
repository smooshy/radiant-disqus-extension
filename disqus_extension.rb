# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class DisqusExtension < Radiant::Extension
  version "1.0"
  description "Provides tags to integrate Disqus comments into your site"
  url "http://yourwebsite.com/disqus"

  def activate
    Page.send :include, DisqusTags
  end

  def deactivate
  end

end
