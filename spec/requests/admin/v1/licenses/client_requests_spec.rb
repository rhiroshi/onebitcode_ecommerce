require 'rails_helper'

RSpec.describe "Admin::V1::License as client", type: :request do
  let(:user) { create(:user, profile: :client) }
  let(:game) { create(:game) }

  context "GET /games/:game_id/licenses" do
    let(:url) { "/admin/v1/games/#{game.id}/licenses" }
    let!(:licenses) { create_list(:license, 5, game: game) }

    before(:each) { get url, headers: auth_header(user) }

    include_examples "forbidden_access"
  end

  context "GET /games/:game_id/licenses/:id" do
    let!(:license) { create(:license, game: game) }
    let(:url) { "/admin/v1/games/#{game.id}/licenses/#{license.id}" }

    before(:each) { get url, headers: auth_header(user) }

    include_examples "forbidden_access"
  end

  context "POST /games/:game_id/licenses" do
    let(:url) { "/admin/v1/games/#{game.id}/licenses" }

    before(:each) { post url, headers: auth_header(user) }
    include_examples "forbidden_access"
  end

  context "PATCH /licenses" do
    let(:license) { create(:license, game: game) }
    let(:url) { "/admin/v1/licenses/#{license.id}" }

    before(:each) { patch url, headers: auth_header(user) }
    include_examples "forbidden_access"
  end

  context "DELETE /licenses" do
    let(:license) { create(:license, game: game) }
    let(:url) { "/admin/v1/licenses/#{license.id}" }
    before(:each) { delete url, headers: auth_header(user) }
    include_examples "forbidden_access"
  end
end
