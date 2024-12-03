# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  module Reader
    class K8sPodReaderTest
      POD_NAME = 'some-pod'
      CONTAINER_NAME = 'some-container'
      NAMESPACE = 'some-namespace'

      describe '.new' do
        it 'should raise an error if the pod name is not set' do
          given_invalid_string.each do |invalid_pod_name|
            actual = assert_raises(ArgumentError) do
              K8sPodReader.new(
                pod_name: invalid_pod_name,
                container_name: CONTAINER_NAME,
                opts: K8sOpts.new(
                  namespace: NAMESPACE,
                  last_nb_lines: 3,
                  follow: false,
                  raw: false
                )
              )
            end

            assert_equal 'Pod name not set.', actual.message
          end
        end

        it 'should raise an error if the container name is not set' do
          given_invalid_string.each do |invalid_container_name|
            actual = assert_raises(ArgumentError) do
              K8sPodReader.new(
                pod_name: POD_NAME,
                container_name: invalid_container_name,
                opts: K8sOpts.new(
                  namespace: NAMESPACE,
                  last_nb_lines: 3,
                  follow: false,
                  raw: false
                )
              )
            end

            assert_equal 'Container name not set.', actual.message
          end
        end

        it 'should raise an error if the opts is not set' do
          actual = assert_raises(ArgumentError) do
            K8sPodReader.new(
              pod_name: POD_NAME,
              container_name: CONTAINER_NAME,
              opts: nil
            )
          end

          assert_equal 'Opts not set.', actual.message
        end

        # TODO: check formatter type

        def given_invalid_string
          [nil, '', '   ']
        end
      end

      describe '.read' do
        before :each do
          @k8s_client = Kubeclient::Client.new('http://localhost:8080/api/', 'v1')
        end

        it 'should get pod logs with pod name if given 3 last nb lines and not watched and raw disabled' do
          reader = K8sPodReader.new(
            k8s_client: @k8s_client,
            pod_name: POD_NAME,
            container_name: CONTAINER_NAME,
            opts: K8sOpts.new(
              namespace: NAMESPACE,
              last_nb_lines: 3,
              follow: false,
              raw: false
            )
          )
          given_pod_logs

          expected = <<~EXPECTED
            some-pod/some-container | log 1
            some-pod/some-container | log 2
            some-pod/some-container | log 3
          EXPECTED
          assert_output(expected) { reader.read }
        end

        it 'should get pod logs without pod name if given 3 last nb lines and not watched and raw enabled' do
          reader = K8sPodReader.new(
            k8s_client: @k8s_client,
            pod_name: POD_NAME,
            container_name: CONTAINER_NAME,
            opts: K8sOpts.new(
              namespace: NAMESPACE,
              last_nb_lines: 3,
              follow: false,
              raw: true
            )
          )
          pod_logs = given_pod_logs

          assert_output(pod_logs) { reader.read }
        end

        it 'should get pod logs in stream if given 3 last nb lines and are watched and raw disabled' do
          reader = K8sPodReader.new(
            k8s_client: @k8s_client,
            pod_name: POD_NAME,
            container_name: CONTAINER_NAME,
            opts: K8sOpts.new(
              namespace: NAMESPACE,
              last_nb_lines: 3,
              follow: true,
              raw: false
            )
          )

          previous_logs = given_pod_logs

          logs_from_watch = <<~LOGS
            previous log 1
            previous log 2
            previous log 3
            previous log 4
            #{previous_logs}
          LOGS
          stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods/#{POD_NAME}/log?container=#{CONTAINER_NAME}&follow=true")
            .to_return(status: 200, body: logs_from_watch)

          expected = <<~EXPECTED
            some-pod/some-container | log 1
            some-pod/some-container | log 2
            some-pod/some-container | log 3
          EXPECTED
          assert_output(expected) { reader.read }
        end

        def given_pod_list_found
          stub_core_api_list
          stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods")
            .to_return(body: open_test_file('pod_list.json'), status: 200)
        end

        def given_pod_logs
          pod_logs = <<~PODLOGS
            log 1
            log 2
            log 3
          PODLOGS
          stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods/#{POD_NAME}/log?container=#{CONTAINER_NAME}&tailLines=3")
            .to_return(status: 200, body: pod_logs)
          pod_logs
        end
      end
    end
  end
end
