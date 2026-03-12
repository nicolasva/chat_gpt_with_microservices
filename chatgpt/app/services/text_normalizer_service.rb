module TextNormalizerService
  def self.normalize(text)
    text.downcase.gsub(/['''`\u2018\u2019\-]/, " ").gsub(/[^a-zà-ÿ0-9\s]/, "").split
  end

  def self.strip_accents(word)
    word.tr("àâäáãåèéêëìíîïòóôöõùúûüýÿñç", "aaaaaaeeeeiiiiooooouuuuyync")
  end
end
