require "bundler/setup"
require "logger"
require "active_support/concern"

module ActiverecordDeferPersist
  module Concern
    extend ActiveSupport::Concern

    included do
      after_save :persist_deferred
    end

    def persist_deferred
      return unless @_defer_persist_ids

      @_defer_persist_ids.each do |association, new_ids|
        singular = association.to_s.singularize
        send(:"eager_#{singular}_ids=", new_ids)
      end
      @_defer_persist_ids = {}
    end

    def reload
      @_defer_persist_ids = {}
      super
    end

    class_methods do
      def defer_persist(association)
        singular = association.to_s.singularize

        alias_method :"eager_#{singular}_ids=", :"#{singular}_ids="
        alias_method :"original_#{singular}_ids", :"#{singular}_ids"

        define_method "#{singular}_ids=" do |ids|
          @_defer_persist_ids ||= {}
          @_defer_persist_ids[association] = ids
        end

        define_method "#{singular}_ids" do
          @_defer_persist_ids ||= {}
          @_defer_persist_ids.fetch(association, super())
        end

        define_method association.to_s do
          @_defer_persist_ids ||= {}
          if @_defer_persist_ids.key?(association)
            self.class.reflect_on_association(association).klass.where(id: @_defer_persist_ids[association])
          else
            super()
          end
        end

      end
    end
  end

  # maybe: lazy_agent_ids
end
