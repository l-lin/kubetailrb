# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  module Reader
    class K8sPodsReaderTest < Minitest::Test
      POD_QUERY = 'some-*'
      CONTAINER_QUERY = 'some-.*'
      NAMESPACE = 'some-namespace'

      describe '.new' do
        it 'should raise an error if the pod query is not set' do
          given_invalid_string.each do |invalid_pod_query|
            actual = assert_raises(ArgumentError) do
              K8sPodsReader.new(
                pod_query: invalid_pod_query,
                container_query: CONTAINER_QUERY,
                opts: K8sOpts.new(
                  namespace: NAMESPACE,
                  last_nb_lines: 10,
                  follow: false,
                  raw: false,
                  display_names: false,
                  exclude: []
                )
              )
            end

            assert_equal 'Pod query not set.', actual.message
          end
        end

        it 'should raise an error if the container query is not set' do
          given_invalid_string.each do |invalid_container_query|
            actual = assert_raises(ArgumentError) do
              K8sPodsReader.new(
                pod_query: POD_QUERY,
                container_query: invalid_container_query,
                opts: K8sOpts.new(
                  namespace: NAMESPACE,
                  last_nb_lines: 10,
                  follow: false,
                  raw: false,
                  display_names: false,
                  exclude: []
                )
              )
            end

            assert_equal 'Container query not set.', actual.message
          end
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
          # GIVEN
          given_empty_pod_list
          given_no_new_pod_event

          # WHEN
          reader = K8sPodsReader.new(
            k8s_client: @k8s_client,
            pod_query: POD_QUERY,
            container_query: CONTAINER_QUERY,
            opts: K8sOpts.new(
              namespace: NAMESPACE,
              last_nb_lines: 3,
              follow: false,
              raw: false,
              display_names: false,
              exclude: []
            )
          )

          # THEN
          assert_output('') { reader.read }
        end

        it 'should display only display filtered pod logs with pod name prefixed if in display names' do
          # GIVEN
          pod_name = 'some-pod'
          container_name = 'some-container'
          given_pod_list_found
          given_pod_logs pod_name, container_name
          given_no_new_pod_event

          # WHEN
          reader = K8sPodsReader.new(
            k8s_client: @k8s_client,
            pod_query: POD_QUERY,
            container_query: CONTAINER_QUERY,
            opts: K8sOpts.new(
              namespace: NAMESPACE,
              last_nb_lines: 3,
              follow: false,
              raw: false,
              display_names: true,
              exclude: []
            )
          )

          # THEN
          then_prefix_pod_name_to_pod_logs reader, pod_name, container_name
        end

        it 'should display all pod logs if pod and container queries are . and in display names' do
          # GIVEN
          given_pod_list_found
          pod_name1 = 'redis-master'
          container_name1 = 'master'
          given_pod_logs pod_name1, container_name1
          pod_name2 = 'some-pod'
          container_name2 = 'some-container'
          given_pod_logs pod_name2, container_name2
          given_no_new_pod_event

          # WHEN
          reader = K8sPodsReader.new(
            k8s_client: @k8s_client,
            pod_query: '.',
            container_query: '.',
            opts: K8sOpts.new(
              namespace: NAMESPACE,
              last_nb_lines: 3,
              follow: false,
              raw: false,
              display_names: true,
              exclude: []
            )
          )

          # THEN
          then_prefix_pod_name_to_multiple_pod_logs reader, pod_name1, container_name1, pod_name2, container_name2
        end

        it 'should only display one pod log if container query is specific and in display_names mode' do
          # GIVEN
          given_pod_list_found
          pod_name1 = 'redis-master'
          container_name1 = 'master'
          given_pod_logs pod_name1, container_name1
          pod_name2 = 'some-pod'
          container_name2 = 'some-container'
          given_pod_logs pod_name2, container_name2
          given_no_new_pod_event

          # WHEN
          reader = K8sPodsReader.new(
            k8s_client: @k8s_client,
            pod_query: '.',
            container_query: 'some-.*',
            opts: K8sOpts.new(
              namespace: NAMESPACE,
              last_nb_lines: 3,
              follow: false,
              raw: false,
              display_names: true,
              exclude: []
            )
          )

          # THEN
          then_prefix_pod_name_to_pod_logs reader, pod_name2, container_name2
        end

        it 'should display not display pod name if raw property is set to true and no display_names mode' do
          # GIVEN
          given_pod_list_found
          pod_name = 'some-pod'
          container_name = 'some-container'
          given_pod_logs pod_name, container_name
          given_no_new_pod_event

          # WHEN
          reader = K8sPodsReader.new(
            k8s_client: @k8s_client,
            pod_query: POD_QUERY,
            container_query: CONTAINER_QUERY,
            opts: K8sOpts.new(
              namespace: NAMESPACE,
              last_nb_lines: 3,
              follow: false,
              raw: true,
              display_names: false,
              exclude: []
            )
          )

          # THEN
          then_no_prefix_to_pod_logs reader, pod_name
        end

        it 'should display new pod logs once they are available' do
          # GIVEN
          given_pod_list_found
          pod_name = 'some-pod'
          container_name = 'some-container'
          given_pod_logs pod_name, container_name
          given_pod_logs_from_watch pod_name, container_name
          given_new_pod_events
          new_pod_name = 'some-other-pod'
          new_container_name = 'some-other-container'
          given_pod_logs new_pod_name, new_container_name
          given_pod_logs_from_watch new_pod_name, new_container_name

          # WHEN
          reader = K8sPodsReader.new(
            k8s_client: @k8s_client,
            pod_query: POD_QUERY,
            container_query: CONTAINER_QUERY,
            opts: K8sOpts.new(
              namespace: NAMESPACE,
              last_nb_lines: 3,
              follow: true,
              raw: true,
              display_names: false,
              exclude: []
            )
          )

          # THEN
          then_no_prefix_to_pod_logs_with_new_pod reader, pod_name, new_pod_name, new_container_name
        end

        def given_empty_pod_list
          stub_core_api_list
          stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods")
            .to_return(body: open_test_file('empty_pod_list.json'), status: 200)
        end

        def given_pod_list_found
          stub_core_api_list
          stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods")
            .to_return(body: open_test_file('pod_list.json'), status: 200)
        end

        def given_no_new_pod_event
          stub_request(:get, "http://localhost:8080/api/v1/watch/namespaces/#{NAMESPACE}/pods")
            .to_return(status: 200, body: '')
        end

        def given_new_pod_events
          stub_request(:get, "http://localhost:8080/api/v1/watch/namespaces/#{NAMESPACE}/pods")
            .to_return(body: open_test_file('watch_stream.json'), status: 200)
        end

        def given_pod_logs(pod_name, container_name)
          pod_logs = <<~PODLOGS
            log 1 from #{pod_name}
            log 2 from #{pod_name}
            log 3 from #{pod_name}
          PODLOGS
          stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods/#{pod_name}/log?container=#{container_name}&tailLines=3")
            .to_return(status: 200, body: pod_logs)
        end

        def given_pod_logs_from_watch(pod_name, container_name)
          pod_logs = <<~PODLOGS
            log 1 from #{pod_name}
            log 2 from #{pod_name}
            log 3 from #{pod_name}
          PODLOGS
          stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods/#{pod_name}/log?container=#{container_name}&follow=true")
            .to_return(status: 200, body: pod_logs)
        end

        def then_prefix_pod_name_to_pod_logs(reader, pod_name, container_name)
          expected = <<~EXPECTED
            #{pod_name}/#{container_name} | log 1 from #{pod_name}
            #{pod_name}/#{container_name} | log 2 from #{pod_name}
            #{pod_name}/#{container_name} | log 3 from #{pod_name}
          EXPECTED
          assert_output(expected) { reader.read }
        end

        def then_prefix_pod_name_to_multiple_pod_logs(reader, pod_name1, container_name1, pod_name2, container_name2)
          expected = <<~EXPECTED
            #{pod_name1}/#{container_name1} | log 1 from #{pod_name1}
            #{pod_name1}/#{container_name1} | log 2 from #{pod_name1}
            #{pod_name1}/#{container_name1} | log 3 from #{pod_name1}
            #{pod_name2}/#{container_name2} | log 1 from #{pod_name2}
            #{pod_name2}/#{container_name2} | log 2 from #{pod_name2}
            #{pod_name2}/#{container_name2} | log 3 from #{pod_name2}
          EXPECTED
          assert_output(expected) { reader.read }
        end

        def then_no_prefix_to_pod_logs(reader, pod_name)
          expected = <<~EXPECTED
            log 1 from #{pod_name}
            log 2 from #{pod_name}
            log 3 from #{pod_name}
          EXPECTED
          assert_output(expected) { reader.read }
        end

        def then_no_prefix_to_pod_logs_with_new_pod(reader, pod_name, new_pod_name, new_container_name)
          # The watch operation is performed before reading the pod logs.
          # Since I cannot simulate a delay before the the stubbed k8s API server
          # returns the right streams (otherwise, we will introduce a flaky test...
          # and we hate flaky tests, aren't we?), we will first get the logs from
          # the new pod instead of existing pod in the tests.
          # In practice, new pods are created afterwards, so their logs are
          # displayed afterwards/
          expected = <<~EXPECTED
            + #{new_pod_name}/#{new_container_name}
            log 1 from #{new_pod_name}
            log 2 from #{new_pod_name}
            log 3 from #{new_pod_name}
            log 1 from #{pod_name}
            log 2 from #{pod_name}
            log 3 from #{pod_name}
          EXPECTED
          assert_output(expected) { reader.read }
        end
      end
    end
  end
end
