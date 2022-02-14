require 'rails_helper'

RSpec.describe "Admin V1 Products as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /products" do
    let(:url) { "/admin/v1/products" }
    let!(:products) { create_list(:product, 5) }

    it "returns all Products with additional data for each :productable" do
      get url, headers: auth_header(user)
      product_attributes = %i(id name description price image_url)
      game_attributes = %i(mode release_date developer)
      expected_return = products.map do |product|
        build_product_json(product, product_attributes, game_attributes)
      end
      expect(body_json['products']).to eq expected_return
    end

    it "returns success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "POST /products" do
    let(:url) { "/admin/v1/products" }
    let(:category) { create(:category) }
    let(:system_requirement) { create(:system_requirement) }

    context "with valid params" do
      let(:game_params) { attributes_for(:game, system_requirement_id: system_requirement.id) }
      let(:product_params) do
        { product: attributes_for(:product).merge(productable: "game").merge(game_params) }.to_json
      end

      it 'adds a new Product' do
        expect do
          post url, headers: auth_header(user), params: product_params
        end.to change(Product, :count).by(1)
      end

      it 'adds a new productable' do
        expect do
          post url, headers: auth_header(user), params: product_params
        end.to change(Game, :count).by(1)
      end

      it 'returns last added Product' do
        post url, headers: auth_header(user), params: product_params
        product_attributes = %i(id name description price)
        game_attributes = %i(mode release_date developer)
        expected_product = build_product_json(Product.last, product_attributes, game_attributes)
        expect(body_json['product']).to eq expected_product
      end

      it 'returns success status' do
        post url, headers: auth_header(user), params: product_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid Product params" do
      let(:game_params) { attributes_for(:game, system_requirement_id: system_requirement.id) }
      let(:product_invalid_params) do
        { product: attributes_for(:product, name: nil).merge(productable: "game").merge(game_params) }.to_json
      end

      it 'does not add a new Product' do
        expect do
          post url, headers: auth_header(user), params: product_invalid_params
        end.to_not change(Product, :count)
      end

      it 'does not add a new productable' do
        expect do
          post url, headers: auth_header(user), params: product_invalid_params
        end.to_not change(Game, :count)
      end

      it 'returns error message' do
        post url, headers: auth_header(user), params: product_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity status' do
        post url, headers: auth_header(user), params: product_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with invalid :productable params" do
      let(:game_params) { attributes_for(:game, developer: "", system_requirement_id: system_requirement.id) }
      let(:invalid_productable_params) do
        { product: attributes_for(:product).merge(productable: "game").merge(game_params) }.to_json
      end

      it 'does not add a new Product' do
        expect do
          post url, headers: auth_header(user), params: invalid_productable_params
        end.to_not change(Product, :count)
      end

      it 'does not add a new productable' do
        expect do
          post url, headers: auth_header(user), params: invalid_productable_params
        end.to_not change(Game, :count)
      end

      it 'returns error message' do
        post url, headers: auth_header(user), params: invalid_productable_params
        expect(body_json['errors']['fields']).to have_key('developer')
      end

      it 'returns unprocessable_entity status' do
        post url, headers: auth_header(user), params: invalid_productable_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "without :productable params" do
      let(:product_without_productable_params) do
        { product: attributes_for(:product) }.to_json
      end

      it 'does not add a new Product' do
        expect do
          post url, headers: auth_header(user), params: product_without_productable_params
        end.to_not change(Product, :count)
      end

      it 'does not add a new productable' do
        expect do
          post url, headers: auth_header(user), params: product_without_productable_params
        end.to_not change(Game, :count)
      end

      it 'returns error message' do
        post url, headers: auth_header(user), params: product_without_productable_params
        expect(body_json['errors']['fields']).to have_key('productable')
      end

      it 'returns unprocessable_entity status' do
        post url, headers: auth_header(user), params: product_without_productable_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "PATCH /products/:id" do
    let(:product) { create(:product) }
    let(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/products/#{product.id}" }

    context "with valid Product params" do
      let(:new_name) { 'New name' }
      let(:product_params) do
        { product: attributes_for(:product, name: new_name) }.to_json
      end

      it 'updates Product' do
        patch url, headers: auth_header(user), params: product_params
        product.reload
        expect(product.name).to eq new_name
      end

      it 'returns updated Product' do
        patch url, headers: auth_header(user), params: product_params
        product.reload
        product_attributes = %i(id name description price)
        game_attributes = %i(mode release_date developer)
        expected_product = build_product_json(product, product_attributes, game_attributes)
        expect(body_json['product']).to eq expected_product
      end

      it 'returns success status' do
        patch url, headers: auth_header(user), params: product_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid Product params" do
      let(:product_invalid_params) do
        { product: attributes_for(:product, name: nil) }.to_json
      end

      it 'does not update Product' do
        old_name = product.name
        patch url, headers: auth_header(user), params: product_invalid_params
        product.reload
        expect(product.name).to eq old_name
      end

      it 'returns error message' do
        patch url, headers: auth_header(user), params: product_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity status' do
        patch url, headers: auth_header(user), params: product_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with invalid :productable params" do
      let(:invalid_productable_params) do
        { product: attributes_for(:game, developer: "") }.to_json
      end

      it 'does not update productable' do
        old_developer = product.productable.developer
        patch url, headers: auth_header(user), params: invalid_productable_params
        product.productable.reload
        expect(product.productable.developer).to eq old_developer
      end

      it 'returns error message' do
        patch url, headers: auth_header(user), params: invalid_productable_params
        expect(body_json['errors']['fields']).to have_key('developer')
      end

      it 'returns unprocessable_entity status' do
        patch url, headers: auth_header(user), params: invalid_productable_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "without :productable params" do
      let(:new_name) { 'New name' }
      let(:product_without_productable_params) do
        { product: attributes_for(:product, name: new_name) }.to_json
      end

      it 'updates Product' do
        patch url, headers: auth_header(user), params: product_without_productable_params
        product.reload
        expect(product.name).to eq new_name
      end

      it 'returns updated Product' do
        patch url, headers: auth_header(user), params: product_without_productable_params
        product.reload
        product_attributes = %i(id name description price)
        game_attributes = %i(mode release_date developer)
        expected_product = build_product_json(product, product_attributes, game_attributes)
        expect(body_json['product']).to eq expected_product
      end

      it 'returns success status' do
        patch url, headers: auth_header(user), params: product_without_productable_params
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "DELETE /products/:id" do
    let(:productable) { create(:game) }
    let!(:product) { create(:product, productable: productable) }
    let(:url) { "/admin/v1/products/#{product.id}" }

    it 'removes Product' do
      expect do
        delete url, headers: auth_header(user)
      end.to change(Product, :count).by(-1)
    end

    it 'removes productable' do
      expect do
        delete url, headers: auth_header(user)
      end.to change(Game, :count).by(-1)
    end

    it 'returns success status' do
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:no_content)
    end

    it 'does not return any body content' do
      delete url, headers: auth_header(user)
      expect(body_json).to_not be_present
    end

    it 'removes all associated product categories' do
      product_categories = create_list(:product_category, 3, product: product)
      delete url, headers: auth_header(user)
      expected_product_categories = ProductCategory.where(id: product_categories.map(&:id))
      expect(expected_product_categories.count).to eq 0
    end

    it 'does not remove unassociated product categories' do
      product_categories = create_list(:product_category, 3)
      delete url, headers: auth_header(user)
      present_product_categories_ids = product_categories.map(&:id)
      expected_product_categories = ProductCategory.where(id: present_product_categories_ids)
      expect(expected_product_categories.ids).to contain_exactly(*present_product_categories_ids)
    end
  end
end

def build_product_json(product, attributes, productable_attributes)
  json = product.as_json(only: attributes)
  json['productable'] = product.productable_type.underscore
  json.merge product.productable.as_json(only: productable_attributes)
end
