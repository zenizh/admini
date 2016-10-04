# Admini

[![Build Status](https://travis-ci.org/kami-zh/admini.svg?branch=master)](https://travis-ci.org/kami-zh/admini)
[![Gem Version](https://badge.fury.io/rb/admini.svg)](https://badge.fury.io/rb/admini)

Admini is a minimal administration framework for Ruby on Rails application.

The core feature is just provides CRUD actions as Active Support's Concern module.
So you can implement administration page as usual.

Admini solves the same problem as [ActiveAdmin](https://github.com/activeadmin/activeadmin), [RailsAdmin](https://github.com/sferik/rails_admin) and [Administrate](https://github.com/thoughtbot/administrate).
Admini is the simplest framework, so you can create administration page according to the Rails way.

**Note**: Admini is still under development, and there may be breaking changes to the API.

![](https://raw.githubusercontent.com/kami-zh/admini/master/docs/screenshot.png)

## Table of contents

- [Demo](#demo)
- [Installation](#installation)
- [Basic usage](#basic-usage)
- [Customization](#customization)
  - [Customize attributes](#customize-attributes)
  - [Customize rendering text](#customize-rendering-text)
  - [Search items](#search-items)
  - [Enum as select tag](#enum-as-select-tag)
  - [Override CRUD actions](#override-crud-actions)
  - [Authorize user](#authorize-user)
  - [Use default theme](#use-default-theme)
  - [Edit header menu](#edit-header-menu)
  - [Override specify view](#override-specify-view)
  - [Change namespace of form object](#change-namespace-of-form-object)
  - [Change paginates per](#change-paginates-per)
- [ToDo](#todo)
- [Need help?](#need-help?)
- [Contributing](#contributing)
- [License](#license)

## Demo

You can try an administration page built with Admini at following link.
The code of the demo can be found [here](https://github.com/kami-zh/admini-demo).

- https://admini.herokuapp.com/admin

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'admini'
```

And then execute:

```bash
$ bundle
```

## Basic usage

If the namespace of your administration page is `:admin`, you probably create `Admin::ApplicationController` like this:

```ruby
class Admin::ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # If you use Devise:
  # before_action :authenticate_user!
end
```

There's no code related to Admini.
You can implement as you like, such as an authentication.

Now everything is ready to create administration page.
For example, to create the page manages Post model, you have to do the following steps:

1. Create `Admin::PostsController` and include `Admini::Resources`
2. Add routing

The example codes is below:

```ruby
class Admin::PostsController < Admin::ApplicationController
  include Admini::Resources
end
```

```ruby
namespace :admin do
  resources :posts
end
```

That's it, and now you can take action `index`, `new`, `create`, `show`, `edit`, `update`, `destroy` the posts at `/admin/posts`.

## Customization

### Customize attributes

The items rendering on `index`, `new`, `show` and `edit` can customize using `#xxx_attributes`.
If you define following methods to controller, the items have changed:

- `#index_attributes`
- `#show_attributes` (default: `#index_attributes`)
- `#new_attributes`
- `#edit_attributes` (default: `#new_attributes`)

Examples:

```ruby
class Admin::PostsController < Admin::ApplicationController
  include Admini::Resources

  private

  def index_attributes
    %i(id title status created_at)
  end

  def show_attributes
    %i(id title status created_at content)
  end

  def new_attributes
    %i(title status content)
  end
end
```

### Customize rendering text

The items rendering text on `index` and `show` are also customizable as you like.
If you define `#render_xxx` on your controller, Admini renders text according to the method.

Here is an example that renders a title with link to post instead of just title.

```ruby
class Admin::PostsController < Admin::ApplicationController
  include Admini::Resources
  include ActionView::Helpers::UrlHelper

  private

  def render_title(resource)
    path = case resource.status
           when 'draft'
             preview_post_path(resource, token: resource.preview_token)
           else
             post_path(resource)
           end
    link_to resource.title, path
  end
end
```

In the same way, a method name to customize the `content` is `#render_content`, or `created_at` is `#render_created_at`.

### Search items

If you want to enable the search form, you should just define `#search_attributes` on your controller.

Following examples enable the search form searched by `title` and `content`.

```ruby
class Admin::PostsController < Admin::ApplicationController
  include Admini::Resources

  private

  def search_attributes
    %i(title content)
  end
end
```

### Enum as select tag

Enum is treated as Integer by database, so enum form has created as text field by default.
If you want to show the form as select box, you should define `#enum_attributes`.

```ruby
class Admin::PostsController < Admin::ApplicationController
  include Admini::Resources

  private

  def enum_attributes
    %i(status)
  end
end
```

### Override CRUD actions

Often we want to override CRUD actions, especially `create` and `update`.

To do this, just define `#create` or `#update` on your controller.
If you want to delegate to `super` defined by Admini, you should call `#super` on the action.

```ruby
class Admin::PostsController < Admin::ApplicationController
  include Admini::Resources

  def create
    @resource.user = current_user
    super
  end
end
```

### Authorize user

You can simply authorize user using [CanCanCan](https://github.com/CanCanCommunity/cancancan), [Pundit](https://github.com/elabs/pundit) or your own code.

When you define the following methods on your controller, Admini authorizes user with it, and raise `Admini::AuthorizationError` if user has not authorized.

- `#can_create?`
- `#can_read?`
- `#can_update?`
- `#can_delete?`

Examples using CanCanCan:

```ruby
class Admin::PostsController < Admin::ApplicationController
  include Admini::Resources

  private

  def can_create?
    can? :create, Post
  end
end
```

Also you can define custom error handler.
This is realized by to define `#authorization_error` on your `Admin::ApplicationController`.

```ruby
class Admin::ApplicationController < ActionController::Base
  private

  def authorization_error
    puts 'Authorization error'
  end
end
```

### Use default theme

Admini doesn't apply any styles to administration pages by default.
Because Admini should be minimal.
If you want to apply basic style created by Admini, you should require the stylesheet.

`app/assets/stylesheets/admini/application.css`:

```css
/*
 *= require admini/default
 */
```

Needless to say, you can write your own styles here as you like.

### Edit header menu

Admini is minimal, so the links to pages will **not** added automatically.
The default view generated by Admini doesn't have any links [like this](https://github.com/kami-zh/admini/blob/master/app/views/admini/layouts/_header.html.erb).

However, you can override header menu by editing `app/views/admini/layouts/_header.html.erb`.

Examples:

```html
<div class="header">
  <div class="container">
    <%= link_to 'Admin', admin_root_path, class: 'header-title' %>
    <%= link_to 'Posts', admin_posts_path %>
    <%= link_to 'Users', admin_users_path %>
    <div class="right">
      <%= link_to 'Logout', destroy_user_session_path, method: :delete %>
    </div>
  </div>
</div>
```

### Override specify view

The view has rendered with a [common views](https://github.com/kami-zh/admini/tree/master/app/views/admini).
If you want to implement original views, you should place your own views according to Rails convention.

For example, to customize the view of `admin/posts#show`, you should create `app/views/admin/posts/show.html.erb`.

```html
<h1>admin/posts#show</h1>
```

In the same way, you can override all views, including `application.html.erb`, `_header.html.erb`, `_nav.html.erb`.

### Change namespace of form object

Admini sets `[:admin, @resource]` as the namespace of form object by default.
This is because generally we adopt `:admin` as administration page's namespace.

If your administration page has a different namespace like `:editor`, you should define `#resource_object` on your `Editor::ApplicationController`.

```ruby
class Editor::ApplicationController < ActionController::Base
  private

  def resource_object
    [:editor, @resource]
  end
end
```

### Change paginates per

Admini depends on [Kaminari](https://github.com/amatsuda/kaminari) as paginater, and it paginates per `25` items.
You can override this number by `#paginates_per` method.

```ruby
class Admin::ApplicationController < ActionController::Base
  private

  def paginates_per
    10
  end
end
```

## ToDo

- [ ] Add spec
- [ ] Improve README (Because I'm not good at English :no_good:)

## Need help?

Feel free to ask me in [Issues](https://github.com/kami-zh/admini/issues) or [author's twitter](https://twitter.com/kami_zh).

## Contributing

1. Fork it ( https://github.com/kami-zh/admini/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
