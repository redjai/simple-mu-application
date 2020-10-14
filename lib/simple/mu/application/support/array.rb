class Array
  def deep_symbolize_keys!
    each_with_index do |val, index|
      self[index] = val.is_a?(Hash) || val.is_a?(Array) ? val.deep_symbolize_keys! : val
    end
  end
end
