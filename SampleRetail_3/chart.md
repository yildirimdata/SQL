classDiagram
      
class category {
    category_id
          category_name
          
}
        
class brand {
    brand_id
          brand_name
          
}
        
class product {
    brand_id
          category_id
          list_price
          model_year
          product_id
          product_name
          
}
        
class customer {
    city
          customer_id
          email
          first_name
          last_name
          phone
          state
          street
          zip_code
          
}
        
class store {
    city
          email
          phone
          state
          store_id
          store_name
          street
          zip_code
          
}
        
class staff {
    active
          email
          first_name
          last_name
          manager_id
          phone
          staff_id
          store_id
          
}
        
class orders {
    customer_id
          order_date
          order_id
          order_status
          required_date
          shipped_date
          staff_id
          store_id
          
}
        
class order_item {
    discount
          item_id
          list_price
          order_id
          product_id
          quantity
          
}
        
class stock {
    product_id
          quantity
          store_id
          
}
        
      product --|> brand: brand_id
            product --|> category: category_id
            staff --|> staff: staff_id
            staff --|> store: store_id
            orders --|> customer: customer_id
            orders --|> staff: staff_id
            orders --|> store: store_id
            order_item --|> orders: order_id
            order_item --|> product: product_id
            stock --|> product: product_id
            stock --|> store: store_id
            
      