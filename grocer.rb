require "pry"

def consolidate_cart(cart)
  items=cart.map{|i| i.keys}.flatten
  ans={}
  items.uniq.each do |i|
    ans[i]={}
  end
  ans.each{|item,stats| cart.each{|i| i.each{|item1,attribute| attribute.each{|k,v|
  if item1==item then ans[item][k]=v end}}}}
  ans.each do |item,stats|
    ans[item][:count]=items.count(item)
  end
  ans
end

def apply_coupons(cart, coupons)
  coupon={}
  coupons.each do |i|
    coupon["#{i[:item]} W/COUPON"]={}
  end
  coupon_item_arr=[]
  coupons.each do |i|
    coupon_item_arr.push(i[:item])
  end
  if cart.keys.any?{|item| coupon_item_arr.include?(item)}
    cart.each{|item,stats| coupons.each{|i| if item==i[:item] && cart[item][:count]>=i[:num] then
    coupon["#{item} W/COUPON"][:price]=i[:cost]
    coupon["#{item} W/COUPON"][:clearance]=cart[item][:clearance]
    coupon["#{item} W/COUPON"][:count]=coupon_item_arr.count(item)
    cart[item][:count]=cart[item][:count]-i[:num]
    end}}
    cart.merge!(coupon)
    cart
  else
    cart
  end
end


def apply_clearance(cart)
  cart.each{|item,stats| if cart[item][:clearance]==true
  then cart[item][:price]=(cart[item][:price]*0.8).round(2) end}
  cart
end


def checkout(cart, coupons)
  items=cart.map{|i| i.keys}.flatten
  item_counts={}
  items.each do |i|
    item_counts[i]=items.count(i)
  end
  #creating item_counts to be used in the function where we
  #adjust the coupon numbers to account for min quantities
  cart1=consolidate_cart(cart)
  cart2=apply_coupons(cart1,coupons)
  cart3=apply_clearance(cart2)
  total=0
  #modify the coupon number here in cart3
  cart3.each do |item,stats|
    coupons.each do |i|
      if i[:item]==item
        cart3["#{item} W/COUPON"][:count]= (item_counts[item]/i[:num]).floor
      end
    end
  end
  #the above is to modify the number of coupons to accommodate the min
  #eligible quantity for coupons
  cart3.each{|item,stats| if cart3[item][:price]!=nil && cart3[item][:count]!=0
  then total+=cart3[item][:price]*cart3[item][:count] end}
  if total>100
    (total*0.9).round(2)
  else
    total
  end
end
