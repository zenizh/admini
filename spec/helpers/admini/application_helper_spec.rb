require 'spec_helper'

include Admini::ApplicationHelper

describe Admini::ApplicationHelper do
  describe '#enable_action?' do
    context 'enable all actions' do
      let(:controller_path) { 'admin/posts' }

      it 'all returns true' do
        %i(index new create show edit update destroy).each do |action|
          expect(enable_action?(action)).to be_truthy
        end
      end
    end

    context 'enable some actions' do
      let(:controller_path) { 'admin/users' }

      it 'returns true when passed enable action, otherwise false' do
        %i(index show).each do |action|
          expect(enable_action?(action)).to be_truthy
        end

        %i(new create edit update destroy).each do |action|
          expect(enable_action?(action)).to be_falsy
        end
      end
    end
  end

  describe '#search_options' do
    let(:resource_name) { 'post' }
    let(:search_attributes) { %i(title content) }

    it 'returns option tags' do
      expect(search_options).to eq "<option value=\"title\">Title</option>\n<option value=\"content\">Content</option>"
    end
  end
end
