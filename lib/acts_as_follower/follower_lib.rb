# frozen_string_literal: true

module ActsAsFollower
  module FollowerLib
    private

    DEFAULT_PARENTS = [ApplicationRecord, ActiveRecord::Base].freeze

    # Retrieves the parent class name if using STI.
    def parent_class_name(obj)
      return obj.class.base_class.name unless parent_classes.include?(obj.class.superclass)

      obj.class.name
    end

    def apply_options_to_scope(scope, options = {})
      scope = scope.limit(options[:limit]) if options.key?(:limit)
      scope = scope.includes(options[:includes]) if options.key?(:includes)
      scope = scope.joins(options[:joins]) if options.key?(:joins)
      scope = scope.where(options[:where]) if options.key?(:where)
      scope = scope.order(options[:order]) if options.key?(:order)

      scope
    end

    def parent_classes
      return DEFAULT_PARENTS unless ActsAsFollower.custom_parent_classes

      ActsAsFollower.custom_parent_classes + DEFAULT_PARENTS
    end
  end
end
