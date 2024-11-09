# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  module Cmd
    class K8sTest < Minitest::Test
      describe '.create' do
        it 'should return the k8s command with default namespace' do
          args = %w[some-pod]

          actual = K8s.create(*args)

          assert_instance_of K8s, actual
          assert_equal 'some-pod', actual.reader.pod_name
          assert_equal 'default', actual.reader.namespace
          assert_equal 10, actual.reader.last_nb_lines
          refute actual.reader.follow?
        end

        it 'should return k8s command with custom last nb lines if `--tail`, `--follow` & `--namespace flags' do
          args = %w[some-pod --tail 3 --follow --namespace some-namespace]

          actual = K8s.create(*args)

          assert_instance_of K8s, actual
          assert_equal 'some-pod', actual.reader.pod_name
          assert_equal 'some-namespace', actual.reader.namespace
          assert_equal 3, actual.reader.last_nb_lines
          assert actual.reader.follow?
        end

        it 'should return k8s command with custom last nb lines if `-f` and `-n` flags' do
          args = %w[some-pod -f -n some-namespace]

          actual = K8s.create(*args)

          assert_instance_of K8s, actual
          assert_equal 'some-pod', actual.reader.pod_name
          assert_equal 'some-namespace', actual.reader.namespace
          assert_equal 10, actual.reader.last_nb_lines
          assert actual.reader.follow?
        end

        it 'should raise InvalidNbLinesValueError if given an invalid `--tail` flag value' do
          args = %w[some-pod --tail invalid]

          actual = assert_raises(InvalidNbLinesValueError) { K8s.create(*args) }

          assert_equal 'Invalid --tail value: invalid.', actual.message
        end

        it 'should raise MissingNbLinesValueError if given a `--tail` flag with no value' do
          args = %w[some-pod --tail]

          actual = assert_raises(MissingNbLinesValueError) { K8s.create(*args) }

          assert_equal 'Missing --tail value.', actual.message
        end

        it 'should raise MissingNamespaceValueError if no value given for `--namespace` flag value' do
          args = %w[some-pod --namespace]

          actual = assert_raises(MissingNamespaceValueError) { K8s.create(*args) }

          assert_equal 'Missing ["-n", "--namespace"] value.', actual.message
        end

        it 'should raise MissingNamespaceValueError if no value given for `-n` flag value' do
          args = %w[some-pod -n]

          actual = assert_raises(MissingNamespaceValueError) { K8s.create(*args) }

          assert_equal 'Missing ["-n", "--namespace"] value.', actual.message
        end
      end
    end
  end
end