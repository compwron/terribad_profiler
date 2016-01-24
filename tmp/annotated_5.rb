puts "line_number:0,BEFORE,#{Time.now.utc}"
class Foo
puts "line_number:0,AFTER,#{Time.now.utc}"
puts "line_number:1,BEFORE,#{Time.now.utc}"
  def bar(a)
puts "line_number:1,AFTER,#{Time.now.utc}"
puts "line_number:2,BEFORE,#{Time.now.utc}"
    if a > 1
puts "line_number:2,AFTER,#{Time.now.utc}"
puts "line_number:3,BEFORE,#{Time.now.utc}"
      1
puts "line_number:3,AFTER,#{Time.now.utc}"
puts "line_number:4,BEFORE,#{Time.now.utc}"
    else
puts "line_number:4,AFTER,#{Time.now.utc}"
puts "line_number:5,BEFORE,#{Time.now.utc}"
      2
puts "line_number:5,AFTER,#{Time.now.utc}"
puts "line_number:6,BEFORE,#{Time.now.utc}"
    end
puts "line_number:6,AFTER,#{Time.now.utc}"
puts "line_number:7,BEFORE,#{Time.now.utc}"
  end
puts "line_number:7,AFTER,#{Time.now.utc}"
puts "line_number:8,BEFORE,#{Time.now.utc}"
end
puts "line_number:8,AFTER,#{Time.now.utc}"
puts "line_number:9,BEFORE,#{Time.now.utc}"

puts "line_number:9,AFTER,#{Time.now.utc}"
puts "line_number:10,BEFORE,#{Time.now.utc}"
Foo.new.bar(-1)
puts "line_number:10,AFTER,#{Time.now.utc}"
puts "line_number:11,BEFORE,#{Time.now.utc}"
# Foo.new.bar(5)
puts "line_number:11,AFTER,#{Time.now.utc}"