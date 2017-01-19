
require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: 'store.sqlite3'
)

class User < ActiveRecord::Base
  has_many :addresses
  has_many :orders

end

class Item < ActiveRecord::Base

end

class Order < ActiveRecord::Base
  belongs_to :item
  belongs_to :user
end

class Address < ActiveRecord::Base
  belongs_to :user
end


#
#
#
# How much would it cost to buy one of each tool?
# How many total items did we sell?
# How much was spent on books?
# Simulate buying an item by inserting a User for yourself and an Order for that User.


puts "Question: How many users are there?"
puts "Answer: #{User.count}"

puts "Question: What are the 5 most expensive items?"

print "Answer: "
 items = Item.order(price: :desc).first(5)
  items.each do |item|
    puts item.title
  end
# also works
# puts Item.order(price: :desc).limit(5).pluck(:title)

puts "Question: What's the cheapest book?"
item =  Item.where(category: "Books").order(:price).limit(1)
puts "Answer: #{item.pluck(:title)}"

puts "Question  Who lives at '6439 Zetta Hills, Willmouth, WY'? Do they have another address?"
address = Address.where(street: '6439 Zetta Hills', city: 'Willmouth', state: 'WY')

"Answer: "
user = User.find(address.pluck(:user_id)).first(1)
user.each do |u|
  puts "#{u.first_name} #{u.last_name}"
end

addresses = Address.first(2).count
puts addresses

puts "Question: Correct Virginie Mitchell's address to 'New York, NY, 10108.'"
puts "Answer: "
user = User.find_by(first_name: 'Virginie', last_name: 'Mitchell')
user_id = user.id
address = Address.where(user_id: user_id).first
address.update(city: 'New York', state: 'NY', zip: '10108')
puts "#{address.city}, #{address.state}, #{address.zip}"

puts "Question: How much would it cost to buy one of each tool?"
puts "Answer: "
print "exclusive: "

like_keyword = "%Tools%"
tools = Item.where(category: 'Tools');
tools2 = Item.where("category LIKE ?", like_keyword)
puts tools.sum('price')
print "inclusive: "
puts tools2.sum('price')

