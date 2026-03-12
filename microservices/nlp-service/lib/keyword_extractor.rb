require_relative "text_normalizer"

module KeywordExtractor
  STOP_WORDS = %w[
    le la les l un une des de du au aux en a y est ce que qui quoi quel quelle quels quelles
    ou où comment pourquoi quand combien estce cest il elle je tu nous vous ils elles on se
    son sa ses mon ma mes ton ta tes notre votre leur leurs sur dans par pour avec sans
    faire fait connais sais dire parle moi dis peux peut donne raconte explique
    jouer joué jouée joues jouent jouait jouaient
    créer creer créé cree crée crees créés créée créées inventer inventé inventée développer developper développé developpe
    trouver trouvé trouve trouves appeler appelé nommer nommé était etait sont été ete avoir être etre
    situer situe situé située situés situées
    connu connue connus connues langage language informatique programmation
    aussi très tres bien plus moins tout tous toute toutes cette cet ces autre autres
    faut falloir prendre donner utiliser comme
    vraiment bon bonne meilleur mieux pire encore même meme
    as ai avons avez ont suis es sommes êtes sera serait
    contre entre chez vers après avant depuis pendant jusque
    si non oui pas ne ni car mais donc or
  ].freeze

  def self.extract(question)
    TextNormalizer.normalize(question).reject { |w| STOP_WORDS.include?(w) || w.length < 2 }
  end
end
