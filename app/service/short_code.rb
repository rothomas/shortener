class ShortCode

  ID_LENGTH = 8

  def self.generate
    SecureRandom.alphanumeric(ID_LENGTH)
  end

end
