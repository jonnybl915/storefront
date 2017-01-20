
require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: 'store.sqlite3'
)

class User < ActiveRecord::Base
  has_many :addresses
  has_many :orders
  has_many :items, through: :orders

end

class Item < ActiveRecord::Base
  has_many :orders
end

class Order < ActiveRecord::Base
  belongs_to :item
  belongs_to :user
end

class Address < ActiveRecord::Base
  belongs_to :user
end





# Simulate buying an item by inserting a User for yourself and an Order for that User.


puts "Question: How many users are there?"
puts "Answer: #{User.count}"

print "\n"
puts "Question: What are the 5 most expensive items?"

print "Answer: "
 items = Item.order(price: :desc).first(5)
  items.each do |item|
    puts item.title
  end
# also works
# puts Item.order(price: :desc).limit(5).pluck(:title)

print "\n"
puts "Question: What's the cheapest book?"
item =  Item.where(category: "Books").order(:price).limit(1)
puts "Answer: #{item.pluck(:title)}"

print "\n"
puts "Question  Who lives at '6439 Zetta Hills, Willmouth, WY'? Do they have another address?"
address = Address.where(street: '6439 Zetta Hills', city: 'Willmouth', state: 'WY')

"Answer: "
user = User.find(address.pluck(:user_id)).first(1)
user.each do |u|
  puts "#{u.first_name} #{u.last_name}"
end

addresses = Address.first(2).count
puts addresses

print "\n"
puts "Question: Correct Virginie Mitchell's address to 'New York, NY, 10108.'"
puts "Answer: "
user = User.find_by(first_name: 'Virginie', last_name: 'Mitchell')
user_id = user.id
address = Address.where(user_id: user_id).first
address.update(city: 'New York', state: 'NY', zip: '10108')
puts "#{address.city}, #{address.state}, #{address.zip}"

print "\n"
puts "Question: How much would it cost to buy one of each tool?"
puts "Answer: "
print "exclusive: "

like_keyword = "%Tools%"
tools = Item.where(category: 'Tools');
tools2 = Item.where("category LIKE ?", like_keyword)
puts tools.sum('price')
print "inclusive: "
puts tools2.sum('price')

print "\n"
puts "Question: How many total items did we sell?"
total_items = Order.sum('quantity')
puts "Answer: #{total_items}"

print "\n"
puts "Question: How much was spent on books?"
all_book_orders = Item.joins(:orders).where("category = 'Books'").sum("price * quantity")
puts all_book_orders

print "\n"
"Question: Simulate buying an item by inserting a User for yourself and an Order for that User."
jon = User.create(first_name: 'Jon', last_name: 'Black', email: 'jblack@gmail.com')
jons_order = Order.create(item_id: 2, user_id: 51, quantity: 4, created_at: 'CURRENT_TIMPESTAMP')
puts "Answer: #{jon.first_name}, #{jon.last_name}, #{jon.email}"
puts "#{jons_order.id}, #{jons_order.user_id}, #{jons_order.item_id}, #{jons_order.quantity}, #{jons_order.created_at}"

print "\n"
puts "Question: What item was ordered most often? Grossed the most money?"

print "Ordered Most: "
most_purchased_items = Order.joins(:item)
most_purchased_items.group(:item_id)
most_purchased = most_purchased_items.order(:quantity).last(1)
most_purchased.each do |mp|
  puts Item.find(mp.item_id).title
end

print "Grossed the most: "
item_which_grossed_most = Order.joins(:item)
item_which_grossed_most.group(:item_id)
grossed_most = item_which_grossed_most.order("price * quantity").last(1)
grossed_most.each do |gm|
  puts Item.find(gm.item_id).title
end
print "\n"
puts "Question: What user spent the most?"
print User.joins(:orders, :items).group('orders.user_id').order('orders.quantity * items.price DESC').limit(1).pluck(:first_name, :last_name)

