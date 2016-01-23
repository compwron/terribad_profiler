puts "line_number:0,BEFORE,#{Time.now.utc}"
0.upto(2).each do |i|
puts "line_number:0,AFTER,#{Time.now.utc}"
puts "line_number:1,BEFORE,#{Time.now.utc}"
  i
puts "line_number:1,AFTER,#{Time.now.utc}"
puts "line_number:2,BEFORE,#{Time.now.utc}"
end
puts "line_number:2,AFTER,#{Time.now.utc}"