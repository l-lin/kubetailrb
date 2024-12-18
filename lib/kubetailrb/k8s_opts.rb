# frozen_string_literal: true

require_relative 'validated'

module Kubetailrb
  # Options to use for reading k8s pod logs.
  class K8sOpts
    include Validated

    DEFAULT_NAMESPACE = 'default'
    DEFAULT_NB_LINES = 10

    attr_reader :namespace, :last_nb_lines, :excludes, :mdcs

    def initialize( # rubocop:disable Metrics/ParameterLists
      namespace: DEFAULT_NAMESPACE,
      last_nb_lines: DEFAULT_NB_LINES,
      follow: false,
      raw: false,
      display_names: false,
      excludes: [],
      mdcs: []
    )
      @namespace = namespace
      @last_nb_lines = last_nb_lines
      @follow = follow
      @raw = raw
      @display_names = display_names
      @excludes = excludes
      @mdcs = mdcs

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
      raise_if_nil @excludes, 'Excludes not set.'
      raise_if_nil @mdcs, 'MDCs not set.'
    end
  end
end
