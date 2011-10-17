module DisqusTags
  include Radiant::Taggable

  class DisqusError < StandardError; end

  desc %Q{Outputs code to display disqus comments
    *Usage:*

    <pre><code><r:disqus [id=""] [url=""] [title=""] [shortname=""] [hide_powered_by="true|false"] [developer_mode="true|false"] /></code></pre>
  }
  tag 'disqus' do |tag|
    shortname = tag.attr["shortname"] unless tag.attr["shortname"].nil?
    shortname = Radiant::Config["disqus.shortname"] if shortname.nil? && Radiant::Config.table_exists? && Radiant::Config["disqus.shortname"]
    raise DisqusError.new('shortname not configured') if shortname.nil?
    disqus_id = tag.attr["id"] || tag.locals.page.id
    disqus_url = tag.attr["url"] || tag.locals.page.url
    disqus_title = tag.locals.page.title if Radiant::Config.table_exists? && Radiant::Config["disqus.auto_title?"]
    disqus_title = tag.attr["title"] unless tag.attr["title"].nil?

    output = %{<div id="disqus_thread"></div>
<script type="text/javascript">
  var disqus_shortname = '#{shortname}';}
    output << %{ var disqus_identifier = '#{escape_quote(disqus_id.to_s)}';}
    output << %{ var disqus_url = '#{escape_quote(disqus_url)}';}
    output << %{ var disqus_title = '#{escape_quote(disqus_title)}';} unless disqus_title.nil?
    output << %{ var disqus_developer = 1;} if (!tag.attr["developer_mode"].nil? && parse_boolean(tag.attr["developer_mode"])) || Radiant::Config["disqus.developer_mode?"]
    output << %{
  (function() {
    var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
    dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';
    (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
  })();
</script>
<noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
}
    hide_powered_by = unless tag.attr["hide_powered_by"].nil?
      parse_boolean(tag.attr["hide_powered_by"])
    else
      Radiant::Config["disqus.hide_powered_by?"] || false
    end
    output << %{<a href="http://disqus.com" class="dsq-brlink">blog comments powered by <span class="logo-disqus">Disqus</span></a>} unless hide_powered_by
    output
  end

private

  def parse_boolean(value)
    [true, 'true', 1, '1', 't'].include?(value.respond_to?(:downcase) ? value.downcase : value)
  end

  def escape_quote(str)
    str.gsub("'", "&apos;")
  end
end