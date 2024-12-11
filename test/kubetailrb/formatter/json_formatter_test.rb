# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  module Formatter
    class JsonFormatterTest < Minitest::Test
      describe '.new' do
        it 'should raise an error if mdcs is invalid' do
          actual = assert_raises(ArgumentError) do
            JsonFormatter.new(nil)
          end

          assert_equal 'MDCs not set.', actual.message
        end
      end
      describe '.format' do
        before :each do
          @formatter = JsonFormatter.new(['account.id'])
        end

        it 'should format into a human readable log if given an application log in json format' do
          json = <<~JSON
            {
              "@timestamp": "2024-11-09T19:42:55.088Z",
              "log.level": "INFO",
              "message": "Time is 2024-11-09T19:42:55.088Z"
            }
          JSON

          actual = @formatter.format json

          expected = "2024-11-09T19:42:55.088Z \e[1;30;44m I \e[0m Time is 2024-11-09T19:42:55.088Z"
          assert_equal expected, actual
        end

        it 'should format into a human readable log if given an access log in json format' do
          json = <<~JSON
            {
              "@timestamp": "2024-11-09T19:42:55.088Z",
              "http.response.status_code": 200,
              "http.request.method": "GET",
              "url.path": "/foobar"
            }
          JSON

          actual = @formatter.format json

          expected = "2024-11-09T19:42:55.088Z \e[1;30;44m I \e[0m [200] GET /foobar"
          assert_equal expected, actual
        end

        it 'should passthrough the argument if not given a json' do
          str = 'not a json'

          actual = @formatter.format str

          assert_equal str, actual
        end

        it 'should display the stack trace if there is a error.stack_trace field' do
          json = <<~JSON
            {
              "@timestamp": "2024-11-09T19:42:55.088Z",
              "log.level": "ERROR",
              "message": "Time is 2024-11-09T19:42:55.088Z",
              "error.stack_trace": "some error\\n    at lin.louis.Error.simulate(Error:42)"
            }
          JSON

          actual = @formatter.format json

          expected = <<~EXPECTED.chomp
            2024-11-09T19:42:55.088Z \e[1;30;41m E \e[0m Time is 2024-11-09T19:42:55.088Z
            some error
                at lin.louis.Error.simulate(Error:42)
          EXPECTED
          assert_equal expected, actual
        end

        it 'should display rails log in pretty format' do
          json = <<~JSON
            {
              "@timestamp": "2024-11-09T19:42:55.088Z",
              "log": {
                "logger": "lin_louis_logger",
                "level": "WARN"
              },
              "message": "Time is 2024-11-09T19:42:55.088Z",
              "rails": {
                "message": "Time is 2024-11-09T19:42:55.088Z"
              }
            }
          JSON

          actual = @formatter.format json

          expected = "2024-11-09T19:42:55.088Z \e[1;30;43m W \e[0m Time is 2024-11-09T19:42:55.088Z"
          assert_equal expected, actual
        end

        it 'should display rails log in pretty format even if log.level is absent' do
          json = <<~JSON
            {
              "@timestamp": "2024-11-09T19:42:55.088Z",
              "message": "Time is 2024-11-09T19:42:55.088Z"
            }
          JSON

          actual = @formatter.format json

          expected = '2024-11-09T19:42:55.088Z Time is 2024-11-09T19:42:55.088Z'
          assert_equal expected, actual
        end

        it 'should display rails access log in pretty format' do
          json = <<~JSON
            {
              "url": {
                "scheme": "https",
                "domain": "localhost",
                "port": 443,
                "path": "/sync",
                "query": "last_event_id=7425de38124429224e31"
              },
              "event": {
                "duration": "2024-12-04T21:59:42.348+01:00"
              },
              "request_id": "14615e3bd77a06c6b3572583777ea7da",
              "rails_route": "some/controller#index",
              "http_method": "GET",
              "http_path": "/foobar",
              "rails_format": "json",
              "rails_controller": "some/controller",
              "rails_action": "index",
              "http_status": 200,
              "source": "rails_logs",
              "@timestamp": "2024-11-09T19:42:55.088Z",
              "@version": "1"
            }
          JSON

          actual = @formatter.format json

          expected = "2024-11-09T19:42:55.088Z \e[1;30;44m I \e[0m [200] GET /foobar"
          assert_equal expected, actual
        end

        it 'should display the mdc if present' do
          json = <<~JSON
            {
              "@timestamp": "2024-11-09T19:42:55.088Z",
              "log.level": "INFO",
              "message": "Time is 2024-11-09T19:42:55.088Z",
              "account.id": 1234
            }
          JSON

          actual = @formatter.format json

          expected = <<~EXPECTED.chomp
            2024-11-09T19:42:55.088Z \e[1;30;44m I \e[0m \e[36maccount.id=1234\e[0m Time is 2024-11-09T19:42:55.088Z
          EXPECTED
          assert_equal expected, actual
        end
      end
    end
  end
end
