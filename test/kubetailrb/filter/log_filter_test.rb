# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  module Filter
    class LogFilterTest < Minitest::Test
      ACCESS_LOG = <<~JSON
        {
          "@timestamp": "2024-11-09T19:42:55.088Z",
          "http.response.status_code": 200,
          "http.request.method": "GET",
          "url.path": "/foobar"
        }
      JSON

      DD_LOG = <<~LOG
        W, [2024-12-05T19:38:00.853776 #8256]  WARN -- : [api-localhost] [ce111111111111111111111111111111] [10760] [dd.env=localhost dd.service=some/service dd.version=d57c51c77b5f6dce59bb1287e457a9ff58210722 dd.trace_id=17109432818971684602 dd.span_id=645769859407861377 ddsource=ruby] {"authorization_header":"APIAuth 30024:ABCD=","uuid":"abcd","body":"","error":"bad_request","error_messages":["invalid hmac signature: check that the stringToSign is 'GET,application/json,abc==,/sync?last_event_id=abcd,Thu, 05 Dec 2024 19:38:00 GMT' and the signature starts with 'abcd'"]}
      LOG

      describe '.create' do
        it 'should create the filter with the right parameters if opts has both access logs and dd logs excluded' do
          exclude = %w[access-logs dd-logs]

          filter = LogFilter.create(exclude)

          assert filter.exclude_access_logs?
          assert filter.exclude_dd_logs?
        end

        it 'should create the filter with the right parameters if opts has none excluded' do
          exclude = %w[foo bar]

          filter = LogFilter.create(exclude)

          refute filter.exclude_access_logs?
          refute filter.exclude_dd_logs?
        end
      end

      describe '.new' do
        it 'should raise an error if exclude_access_logs is invalid' do
          given_invalid_boolean.each do |invalid|
            actual = assert_raises(ArgumentError) { LogFilter.new(invalid, true) }

            assert_equal "Invalid exclude_access_logs: #{invalid}.", actual.message
          end
        end

        it 'should raise an error if exclude_dd_logs is invalid' do
          given_invalid_boolean.each do |invalid|
            actual = assert_raises(ArgumentError) { LogFilter.new(true, invalid) }

            assert_equal "Invalid exclude_dd_logs: #{invalid}.", actual.message
          end
        end

        def given_invalid_boolean
          [nil, [], 0, -1, 'a string']
        end
      end

      describe '.filter' do
        it 'should filter out if it is an access log and configured to' do
          filter = LogFilter.new(true, true)

          actual = filter.test(ACCESS_LOG)

          refute actual
        end

        it 'should not filter out if it is an access log and not configured to' do
          filter = LogFilter.new(false, false)

          actual = filter.test(ACCESS_LOG)

          assert actual
        end

        it 'should filter out if it is an dd log and configured to' do
          filter = LogFilter.new(true, true)

          actual = filter.test(DD_LOG)

          refute actual
        end

        it 'should filter out if it is an dd log and not configured to' do
          filter = LogFilter.new(false, false)

          actual = filter.test(DD_LOG)

          assert actual
        end
      end
    end
  end
end
