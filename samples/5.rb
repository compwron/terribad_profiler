class Foo
  def bar(a)
    if a > 1
      1
    else
      2
    end
  end
end

Foo.new.bar(-1)
# Foo.new.bar(5)
