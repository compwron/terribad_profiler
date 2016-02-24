puts "line_number:0,BEFORE,#{Time.now.to_f}"
0.upto(2).each do |i|
puts "line_number:0,AFTER,#{Time.now.to_f}"
puts "line_number:1,BEFORE,#{Time.now.to_f}"
  i
puts "line_number:1,AFTER,#{Time.now.to_f}"
puts "line_number:2,BEFORE,#{Time.now.to_f}"
end
puts "line_number:2,AFTER,#{Time.now.to_f}"