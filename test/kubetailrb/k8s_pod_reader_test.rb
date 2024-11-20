# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  class K8sPodReaderTest
    POD_NAME = 'some-pod'
    NAMESPACE = 'some-namespace'

    describe '.new' do
      it 'should raise an error if the pod name is not set' do
        given_invalid_string.each do |invalid_pod_name|
          actual = assert_raises(ArgumentError) do
            K8sPodReader.new(
              pod_name: invalid_pod_name,
              formatter: NoOpFormatter.new,
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

      it 'should raise an error if the opts is not set' do
        actual = assert_raises(ArgumentError) do
          K8sPodReader.new(
            pod_name: POD_NAME,
            formatter: NoOpFormatter.new,
            opts: nil
          )
        end

        assert_equal 'Opts not set.', actual.message
      end

      it 'should raise an error if the formatter is not set' do
        actual = assert_raises(ArgumentError) do
          K8sPodReader.new(
            pod_name: POD_NAME,
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

      it 'should get pod logs with pod name if given 3 last nb lines and not watched and raw disabled' do
        reader = K8sPodReader.new(
          k8s_client: @k8s_client,
          pod_name: POD_NAME,
          formatter: NoOpFormatter.new,
          opts: K8sOpts.new(
            namespace: NAMESPACE,
            last_nb_lines: 3,
            follow: false,
            raw: false
          )
        )
        pod_logs = <<~PODLOGS
          log 1
          log 2
          log 3
        PODLOGS
        stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods/#{POD_NAME}/log?tailLines=3")
          .to_return(status: 200, body: pod_logs)

        expected = <<~EXPECTED
          some-pod - log 1
          some-pod - log 2
          some-pod - log 3
        EXPECTED
        assert_output(expected) { reader.read }
      end

      it 'should get pod logs without pod name if given 3 last nb lines and not watched and raw enabled' do
        reader = K8sPodReader.new(
          k8s_client: @k8s_client,
          pod_name: POD_NAME,
          formatter: NoOpFormatter.new,
          opts: K8sOpts.new(
            namespace: NAMESPACE,
            last_nb_lines: 3,
            follow: false,
            raw: true
          )
        )
        pod_logs = <<~PODLOGS
          log 1
          log 2
          log 3
        PODLOGS
        stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods/#{POD_NAME}/log?tailLines=3")
          .to_return(status: 200, body: pod_logs)

        assert_output(pod_logs) { reader.read }
      end

      it 'should get pod logs in stream if given 3 last nb lines and are watched and raw disabled' do
        reader = K8sPodReader.new(
          k8s_client: @k8s_client,
          pod_name: POD_NAME,
          formatter: NoOpFormatter.new,
          opts: K8sOpts.new(
            namespace: NAMESPACE,
            last_nb_lines: 3,
            follow: true,
            raw: false
          )
        )

        previous_logs = <<~LOGS
          log 1
          log 2
          log 3
        LOGS
        stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods/#{POD_NAME}/log?tailLines=3")
          .to_return(status: 200, body: previous_logs)

        logs_from_watch = <<~LOGS
          previous log 1
          previous log 2
          previous log 3
          previous log 4
          #{previous_logs}
        LOGS
        stub_request(:get, "http://localhost:8080/api/v1/namespaces/#{NAMESPACE}/pods/#{POD_NAME}/log?follow=true")
          .to_return(status: 200, body: logs_from_watch)

        expected = <<~EXPECTED
          some-pod - log 1
          some-pod - log 2
          some-pod - log 3
        EXPECTED
        assert_output(expected) { reader.read }
      end
    end
  end
end
