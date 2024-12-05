# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  module Formatter
    class PodMetadataFormatterTest < Minitest::Test
      POD_NAME = 'some-pod'
      CONTAINER_NAME = 'some-container'
      FORMATTER = NoOpFormatter.new

      describe '.initialize' do
        it 'should raise an error if pod name is not set' do
          given_invalid_string.each do |invalid_container_name|
            actual = assert_raises(ArgumentError) do
              PodMetadataFormatter.new(invalid_container_name, CONTAINER_NAME, FORMATTER)
            end

            assert_equal 'Pod name not set.', actual.message
          end
        end

        it 'should raise an error if container name is not set' do
          given_invalid_string.each do |invalid_container_name|
            actual = assert_raises(ArgumentError) do
              PodMetadataFormatter.new(POD_NAME, invalid_container_name, FORMATTER)
            end

            assert_equal 'Container name not set.', actual.message
          end
        end

        it 'should raise an error if formatter is nil' do
          actual = assert_raises(ArgumentError) do
            PodMetadataFormatter.new(POD_NAME, CONTAINER_NAME, nil)
          end
          assert_equal 'Formatter not set.', actual.message
        end

        def given_invalid_string
          [nil, '', '   ']
        end
      end

      describe '.format' do
        it 'should prepend the pod metadata information' do
          formatter = PodMetadataFormatter.new(POD_NAME, CONTAINER_NAME, FORMATTER)
          log = 'some log'

          actual = formatter.format(log)

          expected = 'some-pod/some-container | some log'
          assert_equal expected, actual
        end
      end
    end
  end
end
