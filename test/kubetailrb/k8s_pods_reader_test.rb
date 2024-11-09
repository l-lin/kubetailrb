# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  class K8sPodsReaderTest < Minitest::Test
    POD_QUERY = 'some-*'
    NAMESPACE = 'some-namespace'

    describe '.new' do
      it 'should raise an error if the pod query is not set' do
        given_invalid_pod_query.each do |invalid_pod_query|
          actual = assert_raises(InvalidArgumentError) do
            K8sPodsReader.new(
              pod_query: invalid_pod_query,
              namespace: NAMESPACE,
              last_nb_lines: 10,
              follow: false
            )
          end

          assert_equal 'Pod query not set.', actual.message
        end
      end

      it 'should raise an error if the namespace is not set' do
        given_invalid_namespace.each do |invalid_namespace|
          actual = assert_raises(InvalidArgumentError) do
            K8sPodsReader.new(
              pod_query: POD_QUERY,
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
            K8sPodsReader.new(
              pod_query: POD_QUERY,
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
            K8sPodsReader.new(
              pod_query: POD_QUERY,
              namespace: NAMESPACE,
              last_nb_lines: 10,
              follow: follow
            )
          end

          assert_equal "Invalid follow: #{follow}.", actual.message
        end
      end

      def given_invalid_pod_query
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

    describe '.read' do
      before :each do
        @k8s_client = Kubeclient::Client.new('http://localhost:8080/api/', 'v1')
      end

      it 'should display nothing if there is no pod found' do
        stub_core_api_list
        stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods")
          .to_return(body: open_test_file('empty_pod_list.json'), status: 200)

        reader = K8sPodsReader.new(
          k8s_client: @k8s_client,
          pod_query: POD_QUERY,
          namespace: NAMESPACE,
          last_nb_lines: 3,
          follow: false
        )

        assert_output('') { reader.read }
      end

      it 'should display only display filtered pod logs' do
        stub_core_api_list
        stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods")
          .to_return(body: open_test_file('pod_list.json'), status: 200)

        expected = <<~EXPECTED
          some pod log 1
          some pod log 2
          some pod log 3
        EXPECTED
        stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods/some-pod/log?tailLines=3")
          .to_return(status: 200, body: expected)

        reader = K8sPodsReader.new(
          k8s_client: @k8s_client,
          pod_query: POD_QUERY,
          namespace: NAMESPACE,
          last_nb_lines: 3,
          follow: false
        )

        assert_output(expected) { reader.read }
      end

      it 'should display display all pod logs if pod query is .' do
        stub_core_api_list
        stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods")
          .to_return(body: open_test_file('pod_list.json'), status: 200)

        redis_logs = <<~REDISLOG
          redis log 1
          redis log 2
          redis log 3
        REDISLOG
        stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods/redis-master/log?tailLines=3")
          .to_return(status: 200, body: redis_logs)

        some_pod_logs = <<~SOMEPOD
          some pod log 1
          some pod log 2
          some pod log 3
        SOMEPOD
        stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods/some-pod/log?tailLines=3")
          .to_return(status: 200, body: some_pod_logs)

        reader = K8sPodsReader.new(
          k8s_client: @k8s_client,
          pod_query: '.',
          namespace: NAMESPACE,
          last_nb_lines: 3,
          follow: false
        )

        assert_output(redis_logs + some_pod_logs) { reader.read }
      end
    end
  end
end
