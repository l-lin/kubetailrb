# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  class K8sOptsTest < Minitest::Test
    describe '.new' do
      it 'should raise an error if the namespace is not set' do
        given_invalid_string.each do |invalid_namespace|
          actual = assert_raises(ArgumentError) do
            K8sOpts.new(namespace: invalid_namespace)
          end

          assert_equal 'Namespace not set.', actual.message
        end
      end

      it 'should raise an error if the last nb lines is invalid' do
        given_invalid_last_nb_lines.each do |invalid_last_nb_lines|
          actual = assert_raises(ArgumentError) do
            K8sOpts.new(last_nb_lines: invalid_last_nb_lines)
          end

          assert_equal "Invalid last_nb_lines: #{invalid_last_nb_lines}.", actual.message
        end
      end

      it 'should raise an error if follow is invalid' do
        given_invalid_boolean.each do |follow|
          actual = assert_raises(ArgumentError) do
            K8sOpts.new(follow: follow)
          end

          assert_equal "Invalid follow: #{follow}.", actual.message
        end
      end

      it 'should raise an error if raw is invalid' do
        given_invalid_boolean.each do |invalid_raw|
          actual = assert_raises(ArgumentError) do
            K8sOpts.new(raw: invalid_raw)
          end

          assert_equal "Invalid raw: #{invalid_raw}.", actual.message
        end
      end

      it 'should raise an error if display_names is invalid' do
        given_invalid_boolean.each do |invalid|
          actual = assert_raises(ArgumentError) do
            K8sOpts.new(display_names: invalid)
          end

          assert_equal "Invalid display names: #{invalid}.", actual.message
        end
      end

      it 'should raise an error if excludes is invalid' do
        actual = assert_raises(ArgumentError) do
          K8sOpts.new(excludes: nil)
        end

        assert_equal 'Excludes not set.', actual.message
      end

      it 'should raise an error if mdcs is invalid' do
        actual = assert_raises(ArgumentError) do
          K8sOpts.new(mdcs: nil)
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
