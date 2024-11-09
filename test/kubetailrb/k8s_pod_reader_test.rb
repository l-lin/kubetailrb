# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  class K8sPodReaderTest
    K8S_CLIENT = 'stubbed-k8s-client'
    POD_NAME = 'some-pod'
    NAMESPACE = 'namespace'

    describe '.new' do
      it 'should raise an error if the k8s client is not set' do
        given_invalid_pod_name.each do |invalid_pod_name|
          actual = assert_raises(InvalidArgumentError) do
            K8sPodReader.new(
              k8s_client: nil,
              pod_name: invalid_pod_name,
              namespace: NAMESPACE,
              last_nb_lines: 10,
              follow: false
            )
          end

          assert_equal 'K8s client not set.', actual.message
        end
      end

      it 'should raise an error if the pod name is not set' do
        given_invalid_pod_name.each do |invalid_pod_name|
          actual = assert_raises(InvalidArgumentError) do
            K8sPodReader.new(
              k8s_client: K8S_CLIENT,
              pod_name: invalid_pod_name,
              namespace: NAMESPACE,
              last_nb_lines: 10,
              follow: false
            )
          end

          assert_equal 'Pod name not set.', actual.message
        end
      end

      it 'should raise an error if the namespace is not set' do
        given_invalid_namespace.each do |invalid_namespace|
          actual = assert_raises(InvalidArgumentError) do
            K8sPodReader.new(
              k8s_client: K8S_CLIENT,
              pod_name: POD_NAME,
              namespace: invalid_namespace,
              last_nb_lines: 10,
              follow: false
            )
          end

          assert_equal 'Namespace not set.', actual.message
        end
      end

      it 'should raise an error if the last nb lines is invalid' do
        given_invalid_last_nb_lines.each do |invalid_last_nb_lines|
          actual = assert_raises(InvalidArgumentError) do
            K8sPodReader.new(
              k8s_client: K8S_CLIENT,
              pod_name: POD_NAME,
              namespace: NAMESPACE,
              last_nb_lines: invalid_last_nb_lines,
              follow: false
            )
          end

          assert_equal "Invalid last_nb_lines: #{invalid_last_nb_lines}.", actual.message
        end
      end

      it 'should raise an error if follow is invalid' do
        given_invalid_follow.each do |follow|
          actual = assert_raises(InvalidArgumentError) do
            K8sPodReader.new(
              k8s_client: K8S_CLIENT,
              pod_name: POD_NAME,
              namespace: NAMESPACE,
              last_nb_lines: 10,
              follow: follow
            )
          end

          assert_equal "Invalid follow: #{follow}.", actual.message
        end
      end

      def given_invalid_pod_name
        [nil, '', '   ']
      end

      def given_invalid_namespace
        [nil, '', '   ']
      end

      def given_invalid_last_nb_lines
        [0, -1, 'a string']
      end

      def given_invalid_follow
        [nil, [], 0, -1, 'a string']
      end
    end
  end
end
