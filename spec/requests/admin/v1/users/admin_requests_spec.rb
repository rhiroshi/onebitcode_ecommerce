require 'rails_helper'

RSpec.describe "Admin::V1::Users as admin", type: :request do
  let!(:auth_user) { create(:user) }

  context "GET /categories" do
    let(:url) { "/admin/v1/categories" }
    let!(:categories) { create_list(:category, 10) }

    context "without any params" do
      it "returns 10 Categories" do
        get url, headers: auth_header(auth_user)
        expect(body_json['categories'].count).to eq 10
      end

      it "returns 10 first Categories" do
        get url, headers: auth_header(auth_user)
        expected_categories = categories[0..9].as_json(only: %i(id name))
        expect(body_json['categories']).to contain_exactly *expected_categories
      end

      it "returns success status" do
        get url, headers: auth_header(auth_user)
        expect(response).to have_http_status(:ok)
      end
    end

    context "with search[name] param" do
      let!(:search_name_categories) do
        categories = []
        15.times { |n| categories << create(:category, name: "Search #{n + 1}") }
        categories
      end

      let(:search_params) { { search: { name: "Search" } } }

      it "returns only seached categories limited by default pagination" do
        get url, headers: auth_header(auth_user), params: search_params
        expected_categories = search_name_categories[0..9].map do |category|
          category.as_json(only: %i(id name))
        end
        expect(body_json['categories']).to contain_exactly *expected_categories
      end

      it "returns success status" do
        get url, headers: auth_header(auth_user), params: search_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with pagination params" do
      let(:page) { 2 }
      let(:length) { 5 }

      let(:pagination_params) { { page: page, length: length } }

      it "returns records sized by :length" do
        get url, headers: auth_header(auth_user), params: pagination_params
        expect(body_json['categories'].count).to eq length
      end

      it "returns categories limited by pagination" do
        get url, headers: auth_header(auth_user), params: pagination_params
        expected_categories = categories[5..9].as_json(only: %i(id name))
        expect(body_json['categories']).to contain_exactly *expected_categories
      end

      it "returns success status" do
        get url, headers: auth_header(auth_user), params: pagination_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with order params" do
      let(:order_params) { { order: { name: 'desc' } } }

      it "returns ordered categories limited by default pagination" do
        get url, headers: auth_header(auth_user), params: order_params
        categories.sort! { |a, b| b[:name] <=> a[:name]}
        expected_categories = categories[0..9].as_json(only: %i(id name))
        expect(body_json['categories']).to contain_exactly *expected_categories
      end

      it "returns success status" do
        get url, headers: auth_header(auth_user), params: order_params
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context 'POST /users' do
    let(:url) { '/admin/v1/users' }

    context "with valid params" do
        let(:user_params) { {user: attributes_for(:user) }.to_json }
        it 'adds a new user' do
          expect do
            post url, headers: auth_header(auth_user), params: user_params
          end.to change(User, :count).by(1)
        end

        it 'returns last added User' do
          post url, headers: auth_header(auth_user), params: user_params
          expect_user = User.last.as_json(only: %i(id name email))
          expect(body_json['user']).to eq expect_user
        end

        it "returns success status" do
          post url, headers: auth_header(auth_user), params: user_params
          expect(response).to have_http_status(:ok), lambda { "Expected status 200\n got status: #{response.status}\nBody: #{response.body.inspect}" }
        end
    end

    context "with invalid params" do
      let(:user_invalid_params) do
        { user: attributes_for(:user, name: nil) }.to_json
      end

      it "does not add a new User" do
        expect do
          post url, headers: auth_header(auth_user), params: user_invalid_params
        end.to_not change(User, :count)
      end

      it 'returns error messages' do
        post url, headers: auth_header(auth_user), params: user_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity' do
        post url, headers: auth_header(auth_user), params: user_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

  end

  context 'PATCH /users/:id' do
    let(:user) { create(:user) }
    let(:url) { "/admin/v1/users/#{user.id}" }

    context "with valid params" do
      let(:new_name) { "my new user" }
      let(:user_params) { {user: {name: new_name}}.to_json }

      it 'updates user' do
        patch url, headers: auth_header(auth_user), params: user_params
        user.reload
        expect(user.name).to eq new_name
      end

      it 'returns updated user' do
        patch url, headers: auth_header(auth_user), params: user_params
        user.reload
        expect_user = user.as_json(only: %i(id name email))
        expect(body_json['user']).to eq expect_user
      end

      it 'returns success status' do
        patch url, headers: auth_header(auth_user), params: user_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:user_invalid_params) do
        { user: attributes_for(:user, name: nil) }.to_json
      end

      it 'does not update user' do
        old_name = user.name
        patch url, headers: auth_header(auth_user), params: user_invalid_params
        user.reload
        expect(user.name).to eq old_name
      end

      it 'returns error messages' do
        patch url, headers: auth_header(auth_user), params: user_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity status' do
        patch url, headers: auth_header(auth_user), params: user_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

  end

  context 'DELETE /users/:id' do
    let!(:user) { create(:user) }
    let(:url) { "/admin/v1/users/#{user.id}" }

    it 'removes user' do
      expect do
        delete url, headers: auth_header(auth_user)
      end.to change(User, :count).by(-1)
    end

    it "returns success status" do
      delete url, headers: auth_header(auth_user)
      expect(response).to have_http_status(:no_content)
    end

    it 'does not return any body content' do
      delete url, headers: auth_header(auth_user)
      expect(body_json).to_not be_present
    end
  end
end
