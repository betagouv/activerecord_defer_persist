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
      return if !@_defer_persist_ids && !@_defer_persist_records

      @_defer_persist_ids&.each do |association, new_ids|
        singular = association.to_s.singularize
        send(:"original_#{singular}_ids=", new_ids)
      end
      @_defer_persist_ids = {}

      @_defer_persist_records&.each do |association, new_records|
        singular = association.to_s.singularize
        send(:"original_#{singular}s=", new_records)
      end
      @_defer_persist_records = {}
    end

    def reload
      @_defer_persist_ids = {}
      super
    end

    class_methods do
      def defer_persist(association)
        singular = association.to_s.singularize

        alias_method :"original_#{singular}_ids=", :"#{singular}_ids="
        alias_method :"original_#{singular}s=", :"#{singular}s="
        alias_method :"original_#{singular}_ids", :"#{singular}_ids"

        define_method "#{singular}_ids=" do |ids|
          @_defer_persist_ids ||= {}
          @_defer_persist_ids[association] = ids
        end

        define_method "#{singular}s=" do |records|
          @_defer_persist_records ||= {}
          @_defer_persist_records[association] = records
          # if something was stored in _defer_persist_ids, clear it now
          @_defer_persist_ids.delete(association) if @_defer_persist_ids&.key?(association)
        end

        define_method "#{singular}_ids" do
          @_defer_persist_ids ||= {}
          @_defer_persist_records ||= {}
          if @_defer_persist_ids.key?(association)
            @_defer_persist_ids[association]
          elsif @_defer_persist_records.key?(association)
            @_defer_persist_records[association].map(&:id)
          else
            super()
          end
        end

        define_method association.to_s do
          @_defer_persist_ids ||= {}
          @_defer_persist_records ||= {}
          if @_defer_persist_ids.key?(association)
            self.class.reflect_on_association(association).klass.where(id: @_defer_persist_ids[association])
          elsif @_defer_persist_records.key?(association)
            @_defer_persist_records[association]
          else
            super()
          end
        end

      end
    end
  end
end
