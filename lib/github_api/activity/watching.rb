# encoding: utf-8

module Github
  # Watching a Repository registers the user to receive notificactions on new
  # discussions, as well as events in the user’s activity feed.
  class Activity::Watching < API

    # List repo watchers
    #
    # = Examples
    #  github = Github.new :user => 'user-name', :repo => 'repo-name'
    #  github.activity.watching.list
    #  github.activity.watching.list { |watcher| ... }
    #
    def list(user_name, repo_name, params={})
      set :user => user_name, :repo => repo_name
      assert_presence_of user, repo
      normalize! params

      response = get_request("/repos/#{user}/#{repo}/subscribers", params)
      return response unless block_given?
      response.each { |el| yield el }
    end
    alias :all :list

    # List repos being watched by a user
    #
    # = Examples
    #  github = Github.new
    #  github.activity.watching.watched :user => 'user-name'
    #
    # List repos being watched by the authenticated user
    #
    # = Examples
    #  github = Github.new :oauth_token => '...'
    #  github.activity.watching.watched
    #
    def watched(*args)
      params = args.extract_options!
      normalize! params

      response = if (user_name = params.delete('user'))
        get_request("/users/#{user_name}/subscriptions", params)
      else
        get_request("/user/subscriptions", params)
      end
      return response unless block_given?
      response.each { |el| yield el }
    end

    # Check if you are watching a repository
    #
    # Returns <tt>true</tt> if this repo is watched by you, <tt>false</tt> otherwise
    # = Examples
    #  github = Github.new
    #  github.activity.watching.watching? 'user-name', 'repo-name'
    #
    def watching?(user_name, repo_name, params={})
      assert_presence_of user_name, repo_name
      normalize! params
      get_request("/user/subscriptions/#{user_name}/#{repo_name}", params)
      true
    rescue Github::Error::NotFound
      false
    end

    # Watch a repository
    #
    # You need to be authenticated to watch a repository
    #
    # = Examples
    #  github = Github.new
    #  github.activity.watching.watch 'user-name', 'repo-name'
    #
    def watch(user_name, repo_name, params={})
      assert_presence_of user_name, repo_name
      normalize! params
      put_request("/user/subscriptions/#{user_name}/#{repo_name}", params)
    end

    # Stop watching a repository
    #
    # You need to be authenticated to stop watching a repository.
    # = Examples
    #  github = Github.new
    #  github.activity.watching.unwatch 'user-name', 'repo-name'
    #
    def unwatch(user_name, repo_name, params={})
      assert_presence_of user_name, repo_name
      normalize! params
      delete_request("/user/subscriptions/#{user_name}/#{repo_name}", params)
    end

  end # Activity::Watching
end # Github
