puts "line_number:0,BEFORE,#{Time.now.utc}"
a = false
puts "line_number:0,AFTER,#{Time.now.utc}"
puts "line_number:1,BEFORE,#{Time.now.utc}"
if a
puts "line_number:1,AFTER,#{Time.now.utc}"
puts "line_number:2,BEFORE,#{Time.now.utc}"
  puts "this line does not happen"
puts "line_number:2,AFTER,#{Time.now.utc}"
puts "line_number:3,BEFORE,#{Time.now.utc}"
end
puts "line_number:3,AFTER,#{Time.now.utc}"
puts "line_number:4,BEFORE,#{Time.now.utc}"
b = "cat"
puts "line_number:4,AFTER,#{Time.now.utc}"
puts "line_number:5,BEFORE,#{Time.now.utc}"
sleep 1
puts "line_number:5,AFTER,#{Time.now.utc}"
puts "line_number:6,BEFORE,#{Time.now.utc}"
puts b
puts "line_number:6,AFTER,#{Time.now.utc}"