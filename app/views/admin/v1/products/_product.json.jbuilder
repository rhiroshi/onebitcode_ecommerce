json.(product, :id, :name, :description, :price)
json.productable product.productable_type.underscore
json.productable_id product.productable_id
json.categories product.categories.pluck(:name)
