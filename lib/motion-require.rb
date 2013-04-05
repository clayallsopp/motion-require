require 'ripper'

module Motion
  module Require
    class RequireBuilder < Ripper::SexpBuilder
      REQUIREMENT_TOKEN = "motion_require"

      attr_accessor :requires

      def requires
        @requires ||= []
      end

      def on_command(command, args) # scanner event
        type, name, position = command
        if name == REQUIREMENT_TOKEN
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
            absolute_path(file_path, required)
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

    def absolute_path(source, required)
      File.expand_path(File.join(File.dirname(source), required.to_str))
    end

    def all(files)
      Motion::Project::App.setup do |app|
        app.files << ext_file
        files.each do |file|
          app.files << file
        end

        dependencies = dependencies_for(files)
        app.files_dependencies dependencies
      end
    end

    def ext_file
      File.expand_path(File.join(File.dirname(__FILE__), "../motion/ext.rb"))
    end
  end
end