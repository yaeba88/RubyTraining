class String
  def to_camel
    result = []
    word_count = 0

    self.split(/[_\s]+/).each do |word|
      if word.length === 0
        next
      else
        word.capitalize! unless word_count === 0
        result.push word
        word_count += 1
      end
    end
    return result.join
  end

  def to_snake
    return self
  end
end