# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  class K8sOptsTest < Minitest::Test
    NAMESPACE = 'some-namespace'

    describe '.new' do
      it 'should raise an error if the namespace is not set' do
        given_invalid_string.each do |invalid_namespace|
          actual = assert_raises(ArgumentError) do
            K8sOpts.new(
              namespace: invalid_namespace,
              last_nb_lines: 10,
              follow: false,
              raw: false,
              display_names: false,
              exclude: [],
              mdcs: []
            )
          end

          assert_equal 'Namespace not set.', actual.message
        end
      end

      it 'should raise an error if the last nb lines is invalid' do
        given_invalid_last_nb_lines.each do |invalid_last_nb_lines|
          actual = assert_raises(ArgumentError) do
            K8sOpts.new(
              namespace: NAMESPACE,
              last_nb_lines: invalid_last_nb_lines,
              follow: false,
              raw: false,
              display_names: false,
              exclude: [],
              mdcs: []
            )
          end

          assert_equal "Invalid last_nb_lines: #{invalid_last_nb_lines}.", actual.message
        end
      end

      it 'should raise an error if follow is invalid' do
        given_invalid_boolean.each do |follow|
          actual = assert_raises(ArgumentError) do
            K8sOpts.new(
              namespace: NAMESPACE,
              last_nb_lines: 10,
              follow: follow,
              raw: false,
              display_names: false,
              exclude: [],
              mdcs: []
            )
          end

          assert_equal "Invalid follow: #{follow}.", actual.message
        end
      end

      it 'should raise an error if raw is invalid' do
        given_invalid_boolean.each do |invalid_raw|
          actual = assert_raises(ArgumentError) do
            K8sOpts.new(
              namespace: NAMESPACE,
              last_nb_lines: 10,
              follow: false,
              raw: invalid_raw,
              display_names: false,
              exclude: [],
              mdcs: []
            )
          end

          assert_equal "Invalid raw: #{invalid_raw}.", actual.message
        end
      end

      it 'should raise an error if display_names is invalid' do
        given_invalid_boolean.each do |invalid|
          actual = assert_raises(ArgumentError) do
            K8sOpts.new(
              namespace: NAMESPACE,
              last_nb_lines: 10,
              follow: false,
              raw: false,
              display_names: invalid,
              exclude: [],
              mdcs: []
            )
          end

          assert_equal "Invalid display names: #{invalid}.", actual.message
        end
      end

      it 'should raise an error if exclude is invalid' do
        actual = assert_raises(ArgumentError) do
          K8sOpts.new(
            namespace: NAMESPACE,
            last_nb_lines: 10,
            follow: false,
            raw: false,
            display_names: true,
            exclude: nil,
            mdcs: []
          )
        end

        assert_equal 'Exclude not set.', actual.message
      end

      it 'should raise an error if mdcs is invalid' do
        actual = assert_raises(ArgumentError) do
          K8sOpts.new(
            namespace: NAMESPACE,
            last_nb_lines: 10,
            follow: false,
            raw: false,
            display_names: true,
            exclude: [],
            mdcs: nil
          )
        end

        assert_equal 'MDCs not set.', actual.message
      end

      def given_invalid_string
        [nil, '', '   ']
      end

      def given_invalid_last_nb_lines
        [0, -1, 'a string']
      end

      def given_invalid_boolean
        [nil, [], 0, -1, 'a string']
      end
    end
  end
end
