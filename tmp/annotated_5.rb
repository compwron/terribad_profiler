puts "line_number:0,BEFORE,#{Time.now.to_f}"
class Foo
puts "line_number:0,AFTER,#{Time.now.to_f}"
puts "line_number:1,BEFORE,#{Time.now.to_f}"
  def bar(a)
puts "line_number:1,AFTER,#{Time.now.to_f}"
puts "line_number:2,BEFORE,#{Time.now.to_f}"
    if a > 1
puts "line_number:2,AFTER,#{Time.now.to_f}"
puts "line_number:3,BEFORE,#{Time.now.to_f}"
      1
puts "line_number:3,AFTER,#{Time.now.to_f}"
puts "line_number:4,BEFORE,#{Time.now.to_f}"
    else
puts "line_number:4,AFTER,#{Time.now.to_f}"
puts "line_number:5,BEFORE,#{Time.now.to_f}"
      2
puts "line_number:5,AFTER,#{Time.now.to_f}"
puts "line_number:6,BEFORE,#{Time.now.to_f}"
    end
puts "line_number:6,AFTER,#{Time.now.to_f}"
puts "line_number:7,BEFORE,#{Time.now.to_f}"
  end
puts "line_number:7,AFTER,#{Time.now.to_f}"
puts "line_number:8,BEFORE,#{Time.now.to_f}"
end
puts "line_number:8,AFTER,#{Time.now.to_f}"
puts "line_number:9,BEFORE,#{Time.now.to_f}"

puts "line_number:9,AFTER,#{Time.now.to_f}"
puts "line_number:10,BEFORE,#{Time.now.to_f}"
Foo.new.bar(-1)
puts "line_number:10,AFTER,#{Time.now.to_f}"
puts "line_number:11,BEFORE,#{Time.now.to_f}"
# Foo.new.bar(5)
puts "line_number:11,AFTER,#{Time.now.to_f}"