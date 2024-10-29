#
# Guard is a command line tool to easily handle events on file system modifications.
# More info at https://github.com/guard/guard#readme
#

#
# Configuration generated by using `guard init minitest`.
#
guard :minitest do
  watch(%r{^test/(.*)\/?test_(.*)\.rb$})
  watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[1]}test_#{m[2]}.rb" }
  watch(%r{^test/test_helper\.rb$})      { 'test' }
end

#
# Configuration generated by using `guard init cucumber`.
#
cucumber_options = {
  # Need to disable this in order to make it work with recent version of cucumber.
  # src: https://github.com/guard/guard-cucumber/issues/41#issuecomment-716199847
  notification: false
}

guard "cucumber", cucumber_options do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$}) { "features" }

  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) do |m|
    Dir[File.join("**/#{m[1]}.feature")][0] || "features"
  end
end
