require 'rails_helper'

RSpec.describe "Admin::V1::Licenses as admin", type: :request do
  let!(:auth_user) { create(:user) }

  context "GET /licenses" do
    let(:url) { "/admin/v1/licenses" }
    let!(:licenses) { create_list(:license, 10) }

    context "without any params" do
      it "returns 10 Licenses" do
        get url, headers: auth_header(auth_user)
        expect(body_json['licenses'].count).to eq 10
      end

      it "returns 10 first Licenses" do
        get url, headers: auth_header(auth_user)
        expected_licenses = licenses[0..9].as_json(only: %i(id key game_id))
        expect(body_json['licenses']).to contain_exactly *expected_licenses
      end

      it "returns success status" do
        get url, headers: auth_header(auth_user)
        expect(response).to have_http_status(:ok)
      end
    end

    context "with search[game_id] param" do
      let!(:search_game) { create(:game) }
      let!(:search_game_licenses) do
        licenses = []
        15.times { |n| licenses << create(:license, game: search_game.id) }
        licenses
      end

      let(:search_params) { { search: { game_id: search_game.id } } }

      it "returns only searched licenses limited by default pagination" do
        get url, headers: auth_header(auth_user), params: search_params
        expected_licenses = search_game_licenses[0..9].map do |license|
          license.as_json(only: %i(id key game_id))
        end
        expect(body_json['licenses']).to contain_exactly *expected_licenses
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
        expect(body_json['licenses'].count).to eq length
      end

      it "returns licenses limited by pagination" do
        get url, headers: auth_header(auth_user), params: pagination_params
        expected_licenses = licenses[5..9].as_json(only: %i(id key game_id))
        expect(body_json['licenses']).to contain_exactly *expected_licenses
      end

      it "returns success status" do
        get url, headers: auth_header(auth_user), params: pagination_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with license params" do
      let(:license_params) { { license: { key: 'desc' } } }
      licenses = License.all.to_a
      it "returns ordered licenses limited by default pagination" do
        get url, headers: auth_header(auth_user), params: license_params
        licenses.sort! { |a, b| b[:key] <=> a[:key]}
        expected_licenses = licenses[0..9].as_json(only: %i(id key game_id))
        expect(body_json['licenses']).to contain_exactly *expected_licenses
      end

      it "returns success status" do
        get url, headers: auth_header(auth_user), params: license_params
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context 'POST /licenses' do
    let(:url) { '/admin/v1/licenses' }

    context "with valid params" do
        let(:license_params) { {license: attributes_for(:license) }.to_json }
        it 'adds a new license' do
          expect do
            post url, headers: auth_header(auth_user), params: license_params
          end.to change(License, :count).by(1)
        end

        it 'returns last added License' do
          post url, headers: auth_header(auth_user), params: license_params
          expect_license = License.last.as_json(only: %i(id key game_id))
          expect(body_json['license']).to eq expect_license
        end

        it "returns success status" do
          post url, headers: auth_header(auth_user), params: license_params
          expect(response).to have_http_status(:ok), lambda { "Expected status 200\n got status: #{response.status}\nBody: #{response.body.inspect}" }
        end
    end

    context "with invalid params" do
      let(:license_invalid_params) do
        { license: attributes_for(:license, key: nil) }.to_json
      end

      it "does not add a new License" do
        expect do
          post url, headers: auth_header(auth_user), params: license_invalid_params
        end.to_not change(License, :count)
      end

      it 'returns error messages' do
        post url, headers: auth_header(auth_user), params: license_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity' do
        post url, headers: auth_header(auth_user), params: license_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

  end

  context 'PATCH /licenses/:id' do
    let(:license) { create(:license) }
    let(:url) { "/admin/v1/licenses/#{license.id}" }

    context "with valid params" do
      let(:new_name) { "my new license" }
      let(:license_params) { {license: {name: new_name}}.to_json }

      it 'updates license' do
        patch url, headers: auth_header(auth_user), params: license_params
        license.reload
        expect(license.name).to eq new_name
      end

      it 'returns updated license' do
        patch url, headers: auth_header(auth_user), params: license_params
        license.reload
        expect_license = license.as_json(only: %i(id key game_id))
        expect(body_json['license']).to eq expect_license
      end

      it 'returns success status' do
        patch url, headers: auth_header(auth_user), params: license_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:license_invalid_params) do
        { license: attributes_for(:license, name: nil) }.to_json
      end

      it 'does not update license' do
        old_name = license.name
        patch url, headers: auth_header(auth_user), params: license_invalid_params
        license.reload
        expect(license.name).to eq old_name
      end

      it 'returns error messages' do
        patch url, headers: auth_header(auth_user), params: license_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity status' do
        patch url, headers: auth_header(auth_user), params: license_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

  end

  context 'DELETE /licenses/:id' do
    let!(:license) { create(:license) }
    let(:url) { "/admin/v1/licenses/#{license.id}" }

    it 'removes license' do
      expect do
        delete url, headers: auth_header(auth_user)
      end.to change(License, :count).by(-1)
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
