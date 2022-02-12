require 'rails_helper'

RSpec.describe "Admin::V1::Users as admin", type: :request do
  let!(:auth_user) { create(:user) }

  context "GET /users" do
    let(:url) { "/admin/v1/users" }
    let!(:users) { create_list(:user, 10) }

    context "without any params" do
      it "returns 10 Users" do
        get url, headers: auth_header(auth_user)
        expect(body_json['users'].count).to eq 10
      end

      it "returns 10 first Users" do
        get url, headers: auth_header(auth_user)
        expected_users = users[0..9].as_json(only: %i(email id name))
        expect(body_json['users']).to contain_exactly *expected_users
      end

      it "returns success status" do
        get url, headers: auth_header(auth_user)
        expect(response).to have_http_status(:ok)
      end
    end

    context "with search[name] param" do
      let!(:search_name_users) do
        users = []
        15.times { |n| users << create(:user, name: "Search #{n + 1}") }
        users
      end

      let(:search_params) { { search: { name: "Search" } } }

      it "returns only searched users limited by default pagination" do
        get url, headers: auth_header(auth_user), params: search_params
        expected_users = search_name_users[0..9].map do |user|
          user.as_json(only: %i(email id name))
        end
        expect(body_json['users']).to contain_exactly *expected_users
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
        expect(body_json['users'].count).to eq length
      end

      it "returns users limited by pagination" do
        get url, headers: auth_header(auth_user), params: pagination_params
        expected_users = users[5..9].as_json(only: %i(email id name))
        expect(body_json['users']).to contain_exactly *expected_users
      end

      it "returns success status" do
        get url, headers: auth_header(auth_user), params: pagination_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with order params" do
      let(:order_params) { { order: { name: 'desc' } } }
      users = User.all.to_a
      puts users.inspect
      it "returns ordered users limited by default pagination" do
        get url, headers: auth_header(auth_user), params: order_params
        users.sort! { |a, b| b[:name] <=> a[:name]}
        expected_users = users[0..9].as_json(only: %i(email id name))
        puts ''
        puts body_json['users'].collect { |u| u['name']}.inspect
        puts users.collect { |u| u['name']}.inspect
        expect(body_json['users']).to contain_exactly *expected_users
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
