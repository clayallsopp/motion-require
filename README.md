# motion-require

Miss `require`? Well, this is a step in that direction:

```ruby
# in a RubyMotion file
motion_require "base_view_controller"
motion_require "../util/controller_helper"

class MyController < BaseViewController
  include ControllerHelper
end
```

```ruby
# in your Rakefile
require 'motion/project'

require 'motion-require'
Motion::Require.all

Motion::Project::App.setup do |app|
  # ...
end
```

![Whoa.](http://i.imgur.com/JLpjqkk.jpg)

To enable `motion_require` for only select files:

```ruby
Motion::Require.all(Dir.glob('app/models/**/*.rb'))
```

You **should not** use `app.files <<` in your `setup` block if using motion-require; opt to use `Motion::Require.all` and it will be taken care of.

It's used in:
- [Formotion](https://github.com/clayallsopp/formotion)
- [MotionSupport](https://github.com/tkadauke/motion-support)
- [Basecamp](https://itunes.apple.com/us/app/id599139477) ([ref](https://twitter.com/qrush/status/343324117140897792))

## Installation

`gem install motion-require`

Can also add to your `Gemfile` etc

## How?

motion-require uses static analysis (via [`ripper`](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/ripper/rdoc/Ripper.html)) to find the files using `motion_require` and automatically add the declared dependencies to `Motion::Project::Config#dependencies`. Then the `Kernel#motion_require` method is overriden at compile-time to be a noop.

The paths attached to `motion_require` are treated like those with `require_relative`. If you want to use `require_relative` instead of `motion_require`, you can enable this:

```ruby
require 'motion-require'
Motion::Require.require_relative_enabled = true

# now Motion::Require will detect require_relative
Motion::Require.all(Dir.glob("app/**/*.rb"))
```

## Contact

Clay Allsopp ([http://clayallsopp.com](http://clayallsopp.com))

- [http://twitter.com/clayallsopp](http://twitter.com/clayallsopp)
- [clay@usepropeller.com](clay@usepropeller.com)

## License

motion-require is available under the MIT license. See the LICENSE file for more info.
