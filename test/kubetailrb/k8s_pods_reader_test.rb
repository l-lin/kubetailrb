# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  class K8sPodsReaderTest < Minitest::Test
    POD_QUERY = 'some-*'
    NAMESPACE = 'some-namespace'

    describe '.new' do
      it 'should raise an error if the pod query is not set' do
        given_invalid_string.each do |invalid_pod_query|
          actual = assert_raises(InvalidArgumentError) do
            K8sPodsReader.new(
              pod_query: invalid_pod_query,
              formatter: NoOpFormatter.new,
              opts: K8sOpts.new(
                namespace: NAMESPACE,
                last_nb_lines: 10,
                follow: false,
                raw: false
              )
            )
          end

          assert_equal 'Pod query not set.', actual.message
        end
      end

      it 'should raise an error if the formatter is not set' do
        actual = assert_raises(InvalidArgumentError) do
          K8sPodsReader.new(
            pod_query: POD_QUERY,
            formatter: nil,
            opts: K8sOpts.new(
              namespace: NAMESPACE,
              last_nb_lines: 3,
              follow: false,
              raw: false
            )
          )
        end

        assert_equal 'Formatter not set.', actual.message
      end

      def given_invalid_string
        [nil, '', '   ']
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
        stub_request(:get, "http://localhost:8080/api/v1/watch/namespaces/#{NAMESPACE}/pods")
          .to_return(status: 200, body: '')

        reader = K8sPodsReader.new(
          k8s_client: @k8s_client,
          pod_query: POD_QUERY,
          formatter: NoOpFormatter.new,
          opts: K8sOpts.new(
            namespace: NAMESPACE,
            last_nb_lines: 3,
            follow: false,
            raw: false
          )
        )

        assert_output('') { reader.read }
      end

      it 'should display only display filtered pod logs' do
        stub_core_api_list
        stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods")
          .to_return(body: open_test_file('pod_list.json'), status: 200)

        pod_logs = <<~PODLOGS
          some pod log 1
          some pod log 2
          some pod log 3
        PODLOGS
        stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods/some-pod/log?tailLines=3")
          .to_return(status: 200, body: pod_logs)

        stub_request(:get, "http://localhost:8080/api/v1/watch/namespaces/#{NAMESPACE}/pods")
          .to_return(status: 200, body: '')

        reader = K8sPodsReader.new(
          k8s_client: @k8s_client,
          pod_query: POD_QUERY,
          formatter: NoOpFormatter.new,
          opts: K8sOpts.new(
            namespace: NAMESPACE,
            last_nb_lines: 3,
            follow: false,
            raw: false
          )
        )

        expected = <<~EXPECTED
          some-pod - some pod log 1
          some-pod - some pod log 2
          some-pod - some pod log 3
        EXPECTED
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

        stub_request(:get, "http://localhost:8080/api/v1/watch/namespaces/#{NAMESPACE}/pods")
          .to_return(status: 200, body: '')

        reader = K8sPodsReader.new(
          k8s_client: @k8s_client,
          pod_query: '.',
          formatter: NoOpFormatter.new,
          opts: K8sOpts.new(
            namespace: NAMESPACE,
            last_nb_lines: 3,
            follow: false,
            raw: false
          )
        )

        expected = <<~EXPECTED
          redis-master - redis log 1
          redis-master - redis log 2
          redis-master - redis log 3
          some-pod - some pod log 1
          some-pod - some pod log 2
          some-pod - some pod log 3
        EXPECTED
        assert_output(expected) { reader.read }
      end

      it 'should display not display pod name if raw property is set to true' do
        stub_core_api_list
        stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods")
          .to_return(body: open_test_file('pod_list.json'), status: 200)

        pod_logs = <<~PODLOGS
          some pod log 1
          some pod log 2
          some pod log 3
        PODLOGS
        stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods/some-pod/log?tailLines=3")
          .to_return(status: 200, body: pod_logs)

        stub_request(:get, "http://localhost:8080/api/v1/watch/namespaces/#{NAMESPACE}/pods")
          .to_return(status: 200, body: '')

        reader = K8sPodsReader.new(
          k8s_client: @k8s_client,
          pod_query: POD_QUERY,
          formatter: NoOpFormatter.new,
          opts: K8sOpts.new(
            namespace: NAMESPACE,
            last_nb_lines: 3,
            follow: false,
            raw: true
          )
        )

        expected = <<~EXPECTED
          some pod log 1
          some pod log 2
          some pod log 3
        EXPECTED
        assert_output(expected) { reader.read }
      end

      # TODO: Add tests when adding new pod.
    end
  end
end
