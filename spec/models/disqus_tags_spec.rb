require File.dirname(__FILE__) + '/../spec_helper'

describe 'DisqusTags' do
  dataset :pages

  describe "<r:disqus>" do
    before(:each) do
      Radiant::Config.stub!(:table_exists?).and_return(true)
      Radiant::Config.stub!(:[]).with("disqus.shortname").and_return("foo")
      Radiant::Config.stub!(:[]).with("disqus.hide_powered_by?").and_return(nil)
      Radiant::Config.stub!(:[]).with("disqus.developer_mode?").and_return(nil)
      Radiant::Config.stub!(:[]).with("disqus.auto_title?").and_return(nil)
      @page = pages(:home)
    end
    it "renders the disqus javascript" do
      tag = "<r:disqus/>"
      expected = disqus_code_block("foo")
      @page.should render(tag).as(expected)
    end
    it "sets developer mode when in config" do
      Radiant::Config.stub!(:[]).with("disqus.developer_mode?").and_return(true)
      tag = '<r:disqus />'
      expected = disqus_code_block("foo", :developer => 1)
      @page.should render(tag).as(expected)
    end
    it "sets developer mode when in tag" do
      tag = '<r:disqus developer_mode="true" />'
      expected = disqus_code_block("foo", :developer => 1)
      @page.should render(tag).as(expected)
    end
    it "uses the id attribute if set" do
      tag = '<r:disqus id="drstrange-987654"/>'
      expected = disqus_code_block("foo", :disqus_id => "drstrange-987654")
      @page.should render(tag).as(expected)
    end
    it "uses the url attribute if set" do
      tag = '<r:disqus url="/flabbergasted/"/>'
      expected = disqus_code_block("foo", :disqus_url => "/flabbergasted/")
      @page.should render(tag).as(expected)
    end
    it "uses the title attribute if set" do
      tag = '<r:disqus title="Radiant is Rad"/>'
      expected = disqus_code_block("foo", :disqus_title => "Radiant is Rad")
      @page.should render(tag).as(expected)
    end
    it "uses the title if auto_title? config is set" do
      Radiant::Config.stub!(:[]).with("disqus.auto_title?").and_return(true)
      tag = '<r:disqus/>'
      expected = disqus_code_block("foo", :disqus_title => @page.title)
      @page.should render(tag).as(expected)
    end
    it "uses the attr title if auto_title? config is set" do
      Radiant::Config.stub!(:[]).with("disqus.auto_title?").and_return(true)
      tag = '<r:disqus title="Something else"/>'
      expected = disqus_code_block("foo", :disqus_title => "Something else")
      @page.should render(tag).as(expected)
    end
    it "escapes the title for single quotes" do
      tag = %{<r:disqus title="It's a Trap"/>}
      expected = disqus_code_block("foo", :disqus_title => "It&apos;s a Trap")
      @page.should render(tag).as(expected)
    end
    context "when hide_powered_by? is configured to true" do
      before(:each) do
        Radiant::Config.stub!(:[]).with("disqus.hide_powered_by?").and_return(true)
      end
      it "hides the 'powered-by'" do
        tag = "<r:disqus/>"
        expected = disqus_code_block("foo", :hide_powered_by => true)
        @page.should render(tag).as(expected)
      end
      it "shows 'powered-by' if tag overrides config" do
        tag = '<r:disqus hide_powered_by="false"/>'
        expected = disqus_code_block("foo")
        @page.should render(tag).as(expected)
      end
    end

    context "when disqus shortname is not set in config" do
      before(:each) do
        Radiant::Config.stub!(:table_exists?).and_return(false)
      end
      it "returns an error when no shortname is provided" do
        @page.should render('<r:disqus/>').with_error('shortname not configured')
      end
      it "uses shortname from attribute" do
        tag = %{<r:disqus shortname="bar"/>}
        expected = disqus_code_block("bar")
        @page.should render(tag).as(expected)
      end
    end
  end

  def disqus_code_block(shortname, options = {})
    code = %{<div id="disqus_thread"></div>
<script type="text/javascript">
  var disqus_shortname = '#{shortname}';}
    disqus_id = options[:disqus_id] || @page.id
    code << %{ var disqus_identifier = '#{disqus_id}';}
    disqus_url = options[:disqus_url] || @page.url
    code << %{ var disqus_url = '#{disqus_url}';}
    disqus_title = options[:disqus_title]
    code << %{ var disqus_title = '#{disqus_title}';} if disqus_title
    code << %{ var disqus_developer = #{options[:developer]};} if options[:developer]
    code << %{
  (function() {
    var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
    dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';
    (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
  })();
</script>
<noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
}
    code << %{<a href="http://disqus.com" class="dsq-brlink">blog comments powered by <span class="logo-disqus">Disqus</span></a>} unless options[:hide_powered_by]
    code
  end

end