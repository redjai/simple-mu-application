class Hash
  # Destructively convert all keys to symbols, as long as they respond
  # to +to_sym+. This includes the keys from the root hash and from all
  # nested hashes and hashes nested in arrays.
  def deep_symbolize_keys!
    keys.each do |key|
      val = delete(key)
      self[(key.to_sym rescue key)] = val.is_a?(Hash) || val.is_a?(Array) ? val.deep_symbolize_keys! : val
    end
    self
  end
end

