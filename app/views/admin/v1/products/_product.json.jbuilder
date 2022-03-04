json.(product, :id, :name, :description, :price)
json.status product.status
json.categories product.categories.pluck(:name)
json.image_url rails_blob_url(product.image)
json.productable product.productable_type.underscore
json.productable_id product.productable_id
