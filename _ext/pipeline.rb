require File.join File.dirname(__FILE__), 'tweakruby'
require_relative 'common'
require_relative 'restclient_extensions_enabler'
require 'awestruct/extensions/remotePartial'
require_relative 'lanyrd'
require_relative 'identities'
require_relative 'repository'
require_relative 'jdf'
require_relative 'posts_helper'
require_relative 'disqus_more'
require_relative 'jira'
require_relative 'external'
require_relative 'guide'
require_relative 'spotlight'
require_relative 'moveup'
require_relative 'remotePartial'
require_relative 'qstoc'
require_relative 'nav'
require_relative 'roadmap'
require_relative 'ordernamefixer'
require_relative 'guide_metadata'
require_relative 'disqus'
require_relative 'tag_cloud'


Awestruct::Extensions::Pipeline.new do

  # You need to have the file $HOME/.github-auth containing username:password on one line
  github_collector = Identities::GitHub::Collector.new()

  extension Awestruct::Extensions::RestClientExtensions::EnableGetCache.new
  extension Awestruct::Extensions::RestClientExtensions::EnableJsonConverter.new
  extension Awestruct::Extensions::Identities::Storage.new
  #Awestruct::Extensions::Jira::Project.new(self, 'JDF:12312221')
  extension Awestruct::Extensions::Repository::Collector.new('jboss-jdf', '5VW45kG4HftAMaI5GbjA', :observers => [github_collector])
  extension Awestruct::Extensions::Identities::Collect.new(github_collector)
  extension Awestruct::Extensions::Identities::Crawl.new(
    Identities::GitHub::Crawler.new,
    Identities::Gravatar::Crawler.new,
    #Identities::Confluence::Crawler.new('https://docs.jboss.org/author', :auth_file => '.jboss-auth',
    #    :identity_search_keys => ['name', 'username'], :assign_username_to => 'jboss_username'),
    Identities::JBossCommunity::Crawler.new
  )

  extension Awestruct::Extensions::Lanyrd::Search.new('jdf')
  extension Awestruct::Extensions::Lanyrd::Export.new('/events/jdf.ics')
  extension Awestruct::Extensions::Posts.new( '/news', :posts ) 
  extension Awestruct::Extensions::Posts.new( '/migrations/war-stories', :war_stories )
  extension Awestruct::Extensions::Roadmap.new( '/about/roadmaps' ) 

  extension Awestruct::Extensions::Indexifier.new
  # Must come after Indexifier and before Guides
  extension Awestruct::Extensions::MoveUp.new('/quickstarts/jboss-as-quickstart', 'README')
  extension Awestruct::Extensions::MoveUp.new('/stack/jboss-bom', 'README')
  extension Awestruct::Extensions::OrderNameFixer.new('/examples/ticket-monster/tutorial')

  extension Awestruct::Extensions::Atomizer.new( 
    :posts, 
    '/news.atom',
    :feed_title=>'jdf News' 
  )
  extension Awestruct::Extensions::Paginator.new(:posts, '/news/index', :per_page => 5)
  extension Awestruct::Extensions::Tagger.new(:posts, '/news/index', '/news/tags', :per_page => 5)
  extension Awestruct::Extensions::TagCloud.new(:posts, '/news/tags/index.html')
  extension Awestruct::Extensions::Paginator.new(:war_stories, '/migrations/war-stories/index', :per_page => 5)
  extension Awestruct::Extensions::Tagger.new(:war_stories, '/migrations/war-stories/index', '/migrations/war-stories/tags', :per_page => 5)
  extension Awestruct::Extensions::TagCloud.new(:war_stories, '/migrations/war-stories/tags/index.html')
  extension Awestruct::Extensions::Disqus.new

  extension Awestruct::Extensions::Nav.new

  extension Awestruct::Extensions::Spotlight.new('/spotlights')

  # Needs to be before Guides
  extension Awestruct::Extensions::GuideMetadata.new  

  # Needs to be after Indexifier to get the linking correct; second argument caps changelog per guide
  extension Awestruct::Extensions::Guide::Index.new('/examples/ticket-monster', '.asciidoc')
  extension Awestruct::Extensions::Guide::Index.new('/migrations/seam2', '.asciidoc')
  extension Awestruct::Extensions::Guide::Index.new('/quickstarts/jboss-as-quickstart', 'README.md')
  extension Awestruct::Extensions::Guide::Index.new('/stack/jboss-bom', 'README.md')

  # Must be after guides
  extension Awestruct::Extensions::QSTOC.new('/quickstarts/jboss-as-quickstart')

  # Must be after all other extensions that might populate identities
  extension Awestruct::Extensions::Identities::Cache.new

  # Transformers
  transformer Awestruct::Extensions::Minify.new

  helper Awestruct::Extensions::RemotePartial
  helper Awestruct::Extensions::Partial
  helper Awestruct::Extensions::PostsHelper
end

