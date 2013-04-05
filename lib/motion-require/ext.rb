# Hack until HipByte accepts https://github.com/HipByte/RubyMotion/pull/82
# Stolen from BubbleWrap
module Motion
  module Require
    module Ext
      module ConfigTask

        def self.included(base)
          base.class_eval do
            alias_method :files_dependencies_without_require, :files_dependencies
            alias_method :files_dependencies, :files_dependencies_with_require
          end
        end

        def files_dependencies_with_require(deps_hash)
          res_path = lambda do |x|
            path = /^\.?\//.match(x) ? x : File.join('.', x)
            unless @files.flatten.include?(path)
              Motion::Project::App.send(:fail, "Can't resolve dependency `#{x}'")
            end
            path
          end
          deps_hash.each do |path, deps|
            deps = [deps] unless deps.is_a?(Array)
            @dependencies[res_path.call(path)] = deps.map(&res_path)
          end
        end
      end
    end
  end
end

if Motion.const_defined?("Project")
  Motion::Project::Config.send(:include, Motion::Require::Ext::ConfigTask)
end