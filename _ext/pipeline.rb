require File.join File.dirname(__FILE__), 'tweakruby'
require_relative 'common'
require_relative 'restclient_extensions_enabler'
require 'awestruct/extensions/remotePartial'
require_relative 'lanyrd'

Awestruct::Extensions::Pipeline.new do
  extension Awestruct::Extensions::RestClientExtensions::EnableGetCache.new
  extension Awestruct::Extensions::RestClientExtensions::EnableJsonConverter.new
  extension Awestruct::Extensions::Lanyrd::Search.new('jdf')
  extension Awestruct::Extensions::Lanyrd::Export.new('/events/jdf.ics')
  extension Awestruct::Extensions::Posts.new( '/news', :news ) 
  extension Awestruct::Extensions::Indexifier.new
  extension Awestruct::Extensions::Atomizer.new( 
    :news, 
    '/news.atom',
    :feed_title=>'jdf News' 
  )
  extension Awestruct::Extensions::Paginator.new(:news, '/news/index', :per_page => 5)
  extension Awestruct::Extensions::Tagger.new(:news, '/news/index', '/news/tags', :per_page => 5)
  extension Awestruct::Extensions::TagCloud.new(:news, '/news/tags/index.html')
  helper Awestruct::Extensions::RemotePartial
  helper Awestruct::Extensions::Partial
end

