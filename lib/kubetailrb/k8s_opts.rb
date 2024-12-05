# frozen_string_literal: true

require_relative 'validated'

module Kubetailrb
  # Options to use for reading k8s pod logs.
  class K8sOpts
    include Validated

    attr_reader :namespace, :last_nb_lines

    def initialize(namespace:, last_nb_lines:, follow:, raw:, display_names:)
      @namespace = namespace
      @last_nb_lines = last_nb_lines
      @follow = follow
      @raw = raw
      @display_names = display_names

      validate
    end

    def follow?
      @follow
    end

    def raw?
      @raw
    end

    def display_names?
      @display_names
    end

    private

    def validate
      raise_if_blank @namespace, 'Namespace not set.'
      validate_last_nb_lines @last_nb_lines
      validate_boolean @follow, "Invalid follow: #{@follow}."
      validate_boolean @raw, "Invalid raw: #{@raw}."
      validate_boolean @display_names, "Invalid display names: #{@display_names}."
    end
  end
end
