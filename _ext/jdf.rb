# encoding: utf-8
require 'git'
require 'fileutils'
require 'rexml/document'


module Awestruct::Extensions::Repository::Visitors
  module Clone
    include Base

    def visit(repository, site)
      repos_dir = nil
      if site.repos_dir
        repos_dir = site.repos_dir
      else
        repos_dir = File.join(site.tmp_dir, 'repos')
      end
      if !File.directory? repos_dir
        FileUtils.mkdir_p(repos_dir)      
      end
      clone_dir = File.join(repos_dir, repository.path)
      rc = nil
      if !File.directory? clone_dir
        puts "Cloning repository #{repository.clone_url} -> #{clone_dir}"
        rc = Git.clone(repository.clone_url, clone_dir)
        if repository.master_branch.nil?
          rc.checkout(repository.master_branch)
        else
          repository.master_branch = rc.current_branch
        end
      else
        puts "Using cloned repository #{clone_dir}"
        rc = Git.open(clone_dir)
        master_branch = repository.master_branch
        if master_branch.nil?
          master_branch = rc.branches.find{|b| !b.remote and !b.name.eql? '(no branch)'}.name
          repository.master_branch = master_branch
        end
        rc.checkout(master_branch)
        # nil argument required to work around bug in git library
        rc.pull('origin', ['origin', master_branch] * '/', nil)
      end
      repository.clone_dir = clone_dir
      repository.client = rc
    end
  end

  module RepositoryHelpers
    # Retrieves the contributors between the two commits, filtering
    # by the relative path, if present
    def self.resolve_contributors_between(site, repository, sha1, sha2)
      range_author_index = {}
      RepositoryHelpers.resolve_commits_between(repository, sha1, sha2).map {|c|
        # we'll use email as the key to finding their identity; the sha we just need temporarily
        OpenStruct.new({:name => c.author.name, :email => c.author.email.downcase, :commits => 0, :sha => c.sha})
      }.each {|e|
        # This loop both grabs unique authors by email and counts their commits
        if !range_author_index.has_key? e.email
          range_author_index[e.email] = e
        end
        range_author_index[e.email].commits += 1
      }
      
      range_author_index.values.each {|e|
        # this loop registers author in global index if not present
        if repository.host.eql? 'github.com'
          site.git_author_index[e.email] ||= OpenStruct.new({
            :email => e.email,
            :name => e.name,
            :sample_commit_sha => e.sha,
            :sample_commit_url => RepositoryHelpers.build_commit_url(repository, e.sha),
            :commits => 0,
            :repositories => []
          })
          site.git_author_index[e.email].commits += e.commits
          site.git_author_index[e.email].repositories |= [repository.http_url]
        end
        e.delete_field('sha')
      }.sort {|a, b| a.name <=> b.name}
    end

    # Retrieves the commits in the range, filtered on the relative
    # path in the repository, if present
    def self.resolve_commits_between(repository, sha1, sha2)
      rc = repository.client
      log = rc.log(nil).path(repository.relative_path)
      if sha1.nil?
        log = log.object(sha2)
      else
        log = log.between(sha1, sha2)
      end
    end

    def self.build_commit_url(repository, sha)
      repository.http_url + '/commits/' + sha
    end
  end

  # SEMI-HACK think about how best to curate & display info about these special repos
  # FIXME at least try to make GenericMavenComponent build on this one; perhaps a website component?
  module GenericComponent
    include Base
    def handles(repository)
	true      
    end

    def visit(repository, site)
      rc = repository.client
      c = OpenStruct.new({
        :repository => repository,
        :basepath => repository.path.eql?(repository.owner) ? repository.path : repository.path.sub(/^#{repository.owner}-/, ''),
        :owner => repository.owner,
        :name => repository.name,
        :desc => repository.desc,
        :contributors => []
      })
      # FIXME not dry (from below)!
      RepositoryHelpers.resolve_contributors_between(site, repository, nil, rc.revparse('HEAD')).each do |contrib|
        i = c.contributors.index {|n| n.email == contrib.email}
        if i.nil?
          c.contributors << contrib
        else
          c.contributors[i].commits += contrib.commits
        end
      end
    end
  end

end
