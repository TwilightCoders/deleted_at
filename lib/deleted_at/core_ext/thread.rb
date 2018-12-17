class Thread
  def self.currently(key, value)
    orignal_value, current[key] = current[key], value
    yield(orignal_value, current[key]) if block_given?
  ensure
    current[key] = orignal_value
  end

  def self.currently?(key, value = true)
    current[key] == value
  end
end

# Thread.current[:my_var] = true
# puts Thread.currently[:my_var]

# Thread.currently(:my_var, this_method_returns_false!) do |my_var|
#   puts Thread.currently[:my_var]
#   if my_var
#     puts "Yep"
#   else
#     puts "Nope"
#   end
# end

# puts Thread.currently[:my_var]

# #> true
# #> false
# #> Nope
# #> true
