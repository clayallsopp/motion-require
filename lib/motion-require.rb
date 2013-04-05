require 'ripper'
require 'pathname'
require_relative 'motion-require/ext'

module Motion
  module Require
    class RequireBuilder < Ripper::SexpBuilder
      REQUIREMENT_TOKENS = %w[motion_require require_relative]

      attr_accessor :requires

      def requires
        @requires ||= []
      end

      def on_command(command, args) # scanner event
        type, name, position = command
        if REQUIREMENT_TOKENS.include?(name)
          file = parse_args(args)
          requires << file
        end
      end

      def parse_args(args)
        value = nil
        args.each do |arg|
          if arg.is_a?(Array)
            type = arg.first
            if type == :@tstring_content
              return arg[1]
            end

            value = parse_args(arg)
          end
        end
        value
      end
    end

    module_function
    def dependencies_for(files)
      dependencies = {}
      files.each do |file_path|
        requires = requires_in(file_path)
        if !requires.empty?
          dependencies[file_path] = requires.map { |required|
            if required[-3..-1] != ".rb"
              required += ".rb"
            end
            resolve_path(file_path, required)
          }
          dependencies[file_path].unshift ext_file
        end
      end
      dependencies
    end

    def requires_in(file)
      parser = Motion::Require::RequireBuilder.new(File.read(file))
      parser.parse
      parser.requires
    end

    # Join `required` to directory containing `source`.
    # Preserves relative/absolute nature of source
    def resolve_path(source, required)
      Pathname.new(source).dirname.join(required.to_str).cleanpath.to_path
    end

    def all(files)
      Motion::Project::App.setup do |app|
        app.files << ext_file
        app.files |= files.map { |f| explicit_relative(f) }
        dependencies = dependencies_for(files)
        app.files_dependencies dependencies
      end
    end

    # RubyMotion prefers relative paths to be explicitly prefixed with ./
    def explicit_relative(path)
      # Paths that do not start with "/", "./", or "../" will be prefixed with ./
      path.sub(%r(^(?!\.{0,2}/)), './')
    end

    def ext_file
      File.expand_path(File.join(File.dirname(__FILE__), "../motion/ext.rb"))
    end
  end
end