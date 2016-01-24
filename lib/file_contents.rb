class FileContents
  def self.set(filepath, contents)
    @@contents ||= {}
    @@contents[filepath] = contents
  end

  def self.get(filepath)
    return @@contents[filepath]
  end
end
