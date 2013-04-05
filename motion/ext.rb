# This is run in the RubyMotion environment

module Kernel
  def motion_require(*args)
  end
  alias_method :require_relative, :motion_require
end