require 'action_controller/railtie'
require 'active_record'
require 'admini'

module Dummy
  class Application < Rails::Application
    config.secret_key_base = 'abcdefghijklmnopqrstuvwxyz0123456789'
    config.eager_load = false
  end
end

Dummy::Application.initialize!

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

#
# Migrates
#

class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.timestamps null: false
    end
  end
end

class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string  :title,   null: false
      t.text    :content, null: false
      t.integer :status,  null: false, default: 0
      t.timestamps null: false
    end
  end
end

CreateUsers.new.change
CreatePosts.new.change

#
# Routes
#

Dummy::Application.routes.draw do
  namespace :admin do
    resources :users, only: [:index, :show]
    resources :posts
  end
end

#
# Models
#

class User < ActiveRecord::Base; end

class Post < ActiveRecord::Base
  enum status: { draft: 0, published: 10 }
end

#
# Controllers
#

module Admin; end

class Admin::ApplicationController < ActionController::Base; end

class Admin::PostsController < Admin::ApplicationController
  include Admini::Resources

  private

  def show_attributes
    %i(title content)
  end

  def new_attributes
    %i(title content)
  end

  def search_attributes
    %i(title)
  end

  def can_delete?
    false
  end

  def render_content(resource)
    'bar'
  end
end
