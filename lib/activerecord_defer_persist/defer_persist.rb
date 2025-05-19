require "bundler/setup"
require "logger"
require "active_support/concern"

module ActiverecordDeferPersist
  module Concern
    extend ActiveSupport::Concern

    included do
      after_save :persist_lazy_ids
    end

    def persist_lazy_ids
      return unless @_lazy_ids

      @_lazy_ids_previous_changes ||= {}
      @_lazy_ids.each do |association, new_ids|
        singular = association.to_s.singularize
        @_lazy_ids_previous_changes["#{singular}_ids"] ||= [send(:"original_#{singular}_ids"), new_ids]
        send(:"eager_#{singular}_ids=", new_ids)
        # clear_attribute_changes([:"lazy_#{singular}_ids"])
      end
      @_lazy_ids = {}
    end

    class_methods do
      def lazy_ids(association)
        singular = association.to_s.singularize

        alias_method :"eager_#{singular}_ids=", :"#{singular}_ids="
        alias_method :"original_#{singular}_ids", :"#{singular}_ids"

        define_method "#{singular}_ids=" do |ids|
          @_lazy_ids ||= {}
          @_lazy_ids[association] = ids
        end

        define_method "#{singular}_ids" do
          (@_lazy_ids || {}).fetch(association, super())
        end

        define_method association.to_s do
          @_lazy_ids ||= {}
          if @_lazy_ids.key?(association)
            self.class.reflect_on_association(association).klass.where(id: @_lazy_ids[association])
          else
            super()
          end
        end

        define_method "reload" do
          @_lazy_ids = {}
          super()
        end

        define_method "previous_changes" do
          super().merge(@_lazy_ids_previous_changes || {})
        end
      end
    end
  end

  # maybe: lazy_agent_ids
end
