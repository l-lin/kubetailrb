# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  class JsonFormatterTest < Minitest::Test
    describe '.format' do
      before :each do
        @formatter = JsonFormatter.new
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
    end
  end
end
