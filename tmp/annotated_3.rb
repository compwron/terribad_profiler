puts "line_number:0,BEFORE,#{Time.now.utc}"
def tired
puts "line_number:0,AFTER,#{Time.now.utc}"
puts "line_number:1,BEFORE,#{Time.now.utc}"
  sleep 1
puts "line_number:1,AFTER,#{Time.now.utc}"
puts "line_number:2,BEFORE,#{Time.now.utc}"
end
puts "line_number:2,AFTER,#{Time.now.utc}"
puts "line_number:3,BEFORE,#{Time.now.utc}"
tired
puts "line_number:3,AFTER,#{Time.now.utc}"