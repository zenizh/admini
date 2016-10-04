require 'spec_helper'

describe 'Posts', type: :feature do
  describe 'GET /admin/posts/:id' do
    before do
      Post.create(title: 'foo', content: 'foo')
      visit admin_post_path(id: 1)
    end

    it 'has attributes set by #show_attributes' do
      expect(page).to have_content('foo')
    end

    it 'has attributes overridden by #render_attribute' do
      expect(page).to have_content('bar')
    end
  end

  describe 'GET /admin/posts/new' do
    it 'renders with form object set by #resource_object' do
      visit new_admin_post_path
      expect(page).to have_http_status(:ok)
    end
  end
end
