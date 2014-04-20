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
    result = []
    tmp_str = ''
    capitalize_sequence_count = 0

    self.split('').each do |word|
      if word.match(/[A-Z]/)
        if tmp_str.length > 0 && capitalize_sequence_count === 0
          result.push tmp_str
          tmp_str = ''
        end
        tmp_str = tmp_str + word.downcase
        capitalize_sequence_count += 1
      else
        if capitalize_sequence_count > 1
          result.push tmp_str.slice(0, tmp_str.length-1)
          tmp_str = tmp_str.slice(tmp_str.length-1, 1) + word.downcase
        else 
          tmp_str = tmp_str + word.downcase
        end
        capitalize_sequence_count = 0
      end
    end

    result.push tmp_str if tmp_str.length > 0
    return result.join('_')
  end
end