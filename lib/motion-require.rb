require 'ripper'
require 'pathname'

module Motion
  module Require

    class << self
      attr_accessor :require_relative_enabled
    end

    class RequireBuilder < Ripper::SexpBuilder
      REQUIREMENT_TOKENS = %w[motion_require require_relative]

      attr_accessor :requires

      def requires
        @requires ||= []
      end

      def on_command(command, args) # scanner event
        type, name, position = command
        if valid_require_command(name)
          file = parse_args(args)
          requires << file
        end
      end

      def valid_require_command(name)
        if name == 'require_relative' && !Motion::Require.require_relative_enabled
          raise NoMethodError, 'require_relative is not enabled, see Motion::Require.require_relative_enabled'
        end
        REQUIREMENT_TOKENS.include?(name)
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
            required_path = resolve_path(file_path, required)
            if !File.exist?(required_path) && File.extname(required) != ".rb"
              required_path += ".rb"
            end

            if !File.exist?(required_path)
              # TODO: Report line number of failing require
              raise LoadError, "ERROR! In `#{file_path}', could not require `#{required}', file not found."
            end

            required_path
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

    # Scan specified files. When nil, fallback to RubyMotion's default (app/**/*.rb).
    def all(files=nil, options={})
      # if you want the default 'app.files', you can just pass in the options
      if files.is_a?(Hash) && options == {}
        options = files
        files = nil
      end

      check_platform = options.fetch(:platform, nil)
      current_platform = App.respond_to?(:template) ? App.template : :ios
      return unless Motion::Require.check_platform(current_platform, check_platform)

      Motion::Project::App.setup do |app|
        app.exclude_from_detect_dependencies << ext_file

        if files.nil? || files.empty?
          app.files.push ext_file
          app.exclude_from_detect_dependencies += app.files
          app.files_dependencies dependencies_for(app.files.flatten)
        else
        # Place files prior to those in ./app, otherwise at the end.
          preceding_app = app.files.index { |f| f =~ %r(^(?:\./)?app/) } || -1
          required = Array(files).map { |f| explicit_relative(f) }
          app.exclude_from_detect_dependencies += required
          app.files.insert(preceding_app, ext_file, *required)
          app.files.uniq! # Prevent redundancy

          app.files_dependencies dependencies_for(required)
        end
      end
    end

    def check_platform(current_platform, check_platform)
      case check_platform
      when nil
        true
      when Array
        check_platform.include?(current_platform)
      when Symbol
        current_platform == check_platform
      else
        puts "Unrecognized value for 'check_platform': #{check_platform.inspect}"
        false
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
