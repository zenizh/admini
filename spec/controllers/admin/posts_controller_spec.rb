require 'spec_helper'

describe Admin::PostsController, type: :controller do
  before do
    Post.create(title: 'foo', content: 'foo')
    Post.create(title: 'bar', content: 'bar')
    Post.create(title: 'baz', content: 'baz')
  end

  describe '#resources' do
    it 'returns all posts' do
      get :index
      expect(assigns(:resources).count).to eq 3
    end
  end

  describe '#resource' do
    it 'returns a post' do
      get :show, wrapped_params(id: 1)
      expect(assigns(:resource).title).to eq 'foo'
    end
  end

  describe '#build_resource' do
    it 'creates a Post instance' do
      get :new
      expect(assigns(:resource)).to be_a_kind_of(Post)
      expect(assigns(:resource)).not_to be_persisted
    end

    it 'creates a Post instance with params' do
      post :create, wrapped_params(post: { title: 'qux', content: 'qux' })
      expect(assigns(:resource).title).to eq 'qux'
    end
  end

  describe '#search_resources' do
    it 'returns posts which includes keyword' do
      get :index, wrapped_params(attribute: 'title', value: 'ba')
      expect(assigns(:resources).count).to eq 2
    end
  end

  describe '#authorize' do
    it 'raises error when access to prohibited action' do
      expect { delete :destroy, wrapped_params(id: 1) }.to raise_error(Admini::AuthorizationError)
    end
  end
end
