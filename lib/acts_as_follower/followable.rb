# frozen_string_literal: true

module ActsAsFollower # :nodoc:
  module Followable
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_followable
        has_many :followings, as: :followable, dependent: :destroy, class_name: 'Follow'
        include ActsAsFollower::Followable::InstanceMethods
        include ActsAsFollower::FollowerLib
      end
    end

    module InstanceMethods
      # Returns the number of followers a record has.
      def followers_count
        followings.unblocked.count
      end

      # Returns the followers by a given type
      def followers_by_type(follower_type, options = {})
        follows = follower_type.constantize
                               .joins(:follows)
                               .where('follows.blocked' => false,
                                      'follows.followable_id' => id,
                                      'follows.followable_type' => parent_class_name(self),
                                      'follows.follower_type' => follower_type)
        follows = follows.limit(options[:limit]) if options.key?(:limit)
        follows = follows.includes(options[:includes]) if options.key?(:includes)
        follows
      end

      def followers_by_type_count(follower_type)
        followings.unblocked.for_follower_type(follower_type).count
      end

      # Allows magic names on followers_by_type
      # e.g. user_followers == followers_by_type('User')
      # Allows magic names on followers_by_type_count
      # e.g. count_user_followers == followers_by_type_count('User')
      def method_missing(m, *args)
        if m.to_s[/count_(.+)_followers/]
          followers_by_type_count(Regexp.last_match(1).singularize.classify)
        elsif m.to_s[/(.+)_followers/]
          followers_by_type(Regexp.last_match(1).singularize.classify)
        else
          super
        end
      end

      def respond_to?(m, include_private = false)
        super || m.to_s[/count_(.+)_followers/] || m.to_s[/(.+)_followers/]
      end

      def blocked_followers_count
        followings.blocked.count
      end
      alias restricted_followers_count blocked_followers_count

      # Returns the followings records scoped
      def followers_scoped
        followings.includes(:follower)
      end

      def followers(options = {})
        followers_scope = followers_scoped.unblocked
        followers_scope = apply_options_to_scope(followers_scope, options)
        followers_scope.to_a.collect(&:follower)
      end

      # We don't want your blocks! We want our blocks!
      # def blocks(options={})
      #   blocked_followers_scope = followers_scoped.blocked
      #   blocked_followers_scope = apply_options_to_scope(blocked_followers_scope, options)
      #   blocked_followers_scope.to_a.collect{|f| f.follower}
      # end

      def restricts(options = {})
        blocked_followers_scope = followers_scoped.blocked
        blocked_followers_scope = apply_options_to_scope(blocked_followers_scope, options)
        blocked_followers_scope.to_a.collect(&:follower)
      end

      # Returns true if the current instance is followed by the passed record
      # Returns false if the current instance is blocked by the passed record or no follow is found
      def followed_by?(follower)
        followings.unblocked.for_follower(follower).first.present?
      end

      # Returns true if the current instance is blocked by the passed record
      # Returns false if the current instance is not blocked by the passed record or no follow is found
      def restricted?(follower)
        followings.blocked.for_follower(follower).first.present?
      end

      # Returns true if the current instance is blocked by the passed record
      # Returns false if the current instance is not blocked by the passed record or no follow is found
      def restricted_by?(follower)
        follows.blocked.for_followable(follower).first.present?
      end

      def block(follower)
        get_follow_for(follower) ? block_existing_follow(follower) : block_future_follow(follower)
      end
      alias restrict block

      def unblock(follower)
        get_follow_for(follower).try(:delete)
      end
      alias unrestrict unblock

      def get_follow_for(follower)
        followings.for_follower(follower).first
      end

      private

      def block_future_follow(follower)
        Follow.create(followable: self, follower: follower, blocked: true)
      end

      def block_existing_follow(follower)
        get_follow_for(follower).block!
      end
    end
  end
end
