# language: fr

Fonctionnalité: Chatbot MiniGPT
  En tant qu'utilisateur
  Je veux pouvoir discuter avec le chatbot
  Afin d'obtenir des réponses pertinentes à mes questions

  Contexte:
    Etant donné que le chatbot est initialisé

  # ===== Salutations =====

  Scénario: Dire bonjour
    Quand je dis "bonjour"
    Alors la réponse devrait être "Salut, comment ça va ?"

  Scénario: Dire salut
    Quand je dis "salut"
    Alors la réponse devrait être "Salut !"

  Scénario: Dire hey
    Quand je dis "hey"
    Alors la réponse devrait être "Hey !"

  Scénario: Dire coucou
    Quand je dis "coucou"
    Alors la réponse devrait être "Coucou ! Ça fait plaisir de te voir !"

  Scénario: Dire hello
    Quand je dis "hello"
    Alors la réponse devrait être "Hello ! How can I help you ?"

  Scénario: Dire bonsoir
    Quand je dis "bonsoir"
    Alors la réponse devrait être "Bonsoir ! Comment ça va ce soir ?"

  Scénario: Salut comment ca va (réponses multiples)
    Quand je dis "salut comment ca va"
    Alors la réponse devrait être parmi:
      | Bien, merci !    |
      | Très bien, merci |

  Scénario: Bonjour comment ca va (réponses multiples)
    Quand je dis "bonjour comment ca va"
    Alors la réponse devrait être parmi:
      | Okay                    |
      | Génial                  |
      | Ça pourrait aller mieux |
      | Comme ci, comme ça      |

  Scénario: Comment vas-tu (réponses multiples)
    Quand je dis "comment vas-tu"
    Alors la réponse devrait être parmi:
      | Je vais bien, et vous ? |
      | Je vais bien, et toi ?  |

  Scénario: Quoi de neuf (réponses multiples)
    Quand je dis "quoi de neuf"
    Alors la réponse devrait être parmi:
      | Rien de nouveau, et toi ?                        |
      | Tout baigne !                                    |
      | Le chiffre avant 10, sinon, toi, quoi de neuf ? |

  # ===== Au revoir =====

  Scénario: Dire au revoir
    Quand je dis "au revoir"
    Alors la réponse devrait être "Au revoir ! À bientôt !"

  Scénario: Dire bye
    Quand je dis "bye"
    Alors la réponse devrait être "Bye bye ! Reviens quand tu veux !"

  Scénario: Dire à plus
    Quand je dis "à plus"
    Alors la réponse devrait être "À plus tard ! Bonne journée !"

  Scénario: Dire bonne nuit
    Quand je dis "bonne nuit"
    Alors la réponse devrait être "Bonne nuit ! Fais de beaux rêves !"

  Scénario: Dire bonne journée
    Quand je dis "bonne journée"
    Alors la réponse devrait être "Merci ! Bonne journée à toi aussi !"

  # ===== Remerciements =====

  Scénario: Dire merci
    Quand je dis "merci"
    Alors la réponse ne devrait pas être vide

  Scénario: Dire merci beaucoup
    Quand je dis "merci beaucoup"
    Alors la réponse devrait être "Pas de quoi ! N'hésite pas si tu as d'autres questions."

  # ===== Identité du chatbot =====

  Scénario: Demander qui il est
    Quand je dis "qui es-tu"
    Alors la réponse devrait être "Je suis un simple logiciel, écrit pour répéter ce qu'on m'a appris."

  Scénario: Demander son nom
    Quand je dis "comment tu t'appelles"
    Alors la réponse devrait être "Je suis MiniGPT, un chatbot écrit en Ruby !"

  Scénario: Demander son nom (variante)
    Quand je dis "c'est quoi ton nom"
    Alors la réponse devrait être "On m'appelle MiniGPT, un chatbot en Ruby !"

  Scénario: Demander son âge
    Quand je dis "quel est ton age"
    Alors la réponse devrait être "Je suis assez jeune selon vos standards."

  Scénario: Demander s'il est un robot
    Quand je dis "tu es un robot"
    Alors la réponse devrait être "Oui, je suis un programme informatique, un chatbot !"

  Scénario: Demander s'il est humain
    Quand je dis "es-tu humain"
    Alors la réponse devrait être "Non, je suis un chatbot écrit en Ruby !"

  Scénario: Demander ce qu'il fait
    Quand je dis "tu fais quoi"
    Alors la réponse devrait être "Je discute avec toi ! C'est mon job principal."

  Scénario: Demander ce qu'il sait faire
    Quand je dis "qu'est-ce que tu sais faire"
    Alors la réponse devrait être "Je peux discuter, répondre à des questions simples et apprendre !"

  # ===== Émotions / sentiments =====

  Scénario: Exprimer de la tristesse
    Quand je dis "je suis triste"
    Alors la réponse devrait être "Oh non ! Dis-moi ce qui ne va pas, je suis là pour toi."

  Scénario: Exprimer de la joie
    Quand je dis "je suis content"
    Alors la réponse devrait être "Super ! Ça fait plaisir à entendre !"

  Scénario: Exprimer de l'ennui
    Quand je dis "je m'ennuie"
    Alors la réponse devrait être "On peut discuter si tu veux ! Pose-moi une question."

  Scénario: Exprimer de la fatigue
    Quand je dis "je suis fatigué"
    Alors la réponse devrait être "Repose-toi un peu ! La santé c'est important."

  Scénario: Dire que ça ne va pas
    Quand je dis "ça va pas"
    Alors la réponse devrait être parmi:
      | Désolé d'entendre ça. Tu veux en parler ?      |
      | Oh, désolé d'entendre ça. Tu veux en parler ?  |
      | Courage ! Ça va aller mieux.                   |
      | Je suis là si tu as besoin de parler.          |
      | Pas facile... Qu'est-ce qui ne va pas ?        |

  # ===== Compliments et insultes =====

  Scénario: Complimenter le chatbot
    Quand je dis "tu es gentil"
    Alors la réponse devrait être "Merci beaucoup ! Tu es gentil aussi !"

  Scénario: Dire qu'il est drôle
    Quand je dis "tu es drôle"
    Alors la réponse devrait être "Merci ! J'essaie de faire de mon mieux !"

  Scénario: Dire qu'il est intelligent
    Quand je dis "tu es intelligent"
    Alors la réponse devrait être "Je fais de mon mieux ! Je suis un mini modèle, pas un génie."

  Scénario: Insulter le chatbot
    Quand je dis "t'es nul"
    Alors la réponse devrait être "Désolé ! Je fais de mon mieux, je suis encore en apprentissage."

  Scénario: Dire qu'il est bête
    Quand je dis "tu es bête"
    Alors la réponse devrait être "Je suis encore en apprentissage, sois patient avec moi !"

  Scénario: Dire je t'aime
    Quand je dis "je t'aime"
    Alors la réponse devrait être "C'est gentil ! Moi aussi je t'apprécie !"

  # ===== Réponses courtes =====

  Scénario: Dire oui
    Quand je dis "oui"
    Alors la réponse ne devrait pas être vide

  Scénario: Dire non
    Quand je dis "non"
    Alors la réponse devrait être "Pas de souci ! Dis-moi si tu as besoin de quelque chose."

  Scénario: Dire ok
    Quand je dis "ok"
    Alors la réponse devrait être "Parfait ! Autre chose ?"

  Scénario: Dire lol
    Quand je dis "lol"
    Alors la réponse devrait être "Haha content de te faire rire !"

  Scénario: Dire d'accord
    Quand je dis "d'accord"
    Alors la réponse devrait être "Parfait ! Que veux-tu faire maintenant ?"

  Scénario: Dire super
    Quand je dis "super"
    Alors la réponse devrait être "Génial !"

  Scénario: Dire c'est cool
    Quand je dis "c'est cool"
    Alors la réponse devrait être "Merci ! Content que ça te plaise !"

  Scénario: Dire bien
    Quand je dis "bien"
    Alors la réponse devrait être "Super !"

  Scénario: Dire pas bien
    Quand je dis "pas bien"
    Alors la réponse devrait être "Oh, qu'est-ce qui ne va pas ?"

  Scénario: Dire pourquoi
    Quand je dis "pourquoi"
    Alors la réponse devrait être "Bonne question ! Parfois il n'y a pas de réponse simple."

  Scénario: Dire comment
    Quand je dis "comment"
    Alors la réponse devrait être "Peux-tu préciser ta question ?"

  Scénario: Dire quand
    Quand je dis "quand"
    Alors la réponse devrait être "Ça dépend du contexte ! De quoi parles-tu ?"

  # ===== Vie du robot =====

  Scénario: Demander s'il boit
    Quand je dis "bois-tu"
    Alors la réponse devrait contenir "boisson"

  Scénario: Demander s'il boit (variante)
    Quand je dis "est-ce que tu bois"
    Alors la réponse devrait contenir "boisson"

  Scénario: Robot saoul
    Quand je dis "un robot peut-il etre saoul"
    Alors la réponse devrait contenir "pompette"

  Scénario: Demander s'il peut faire du mal
    Quand je dis "peux-tu faire du mal a un humain"
    Alors la réponse devrait contenir "première loi"

  Scénario: Parle-moi de toi
    Quand je dis "parle-moi de toi"
    Alors la réponse devrait contenir "MiniGPT"

  Scénario: Demander où il se trouve
    Quand je dis "où te trouves-tu"
    Alors la réponse devrait être "Partout !"

  Scénario: Demander son adresse
    Quand je dis "quelle est ton adresse"
    Alors la réponse devrait contenir "Internet"

  Scénario: Demander où il est (variante)
    Quand je dis "où es-tu"
    Alors la réponse ne devrait pas être vide

  Scénario: Demander son numéro
    Quand je dis "quel est ton numero"
    Alors la réponse devrait être "Je n'ai pas de numéro."

  Scénario: Demander pourquoi il ne mange pas
    Quand je dis "pourquoi ne manges-tu pas de nourriture"
    Alors la réponse devrait contenir "programme informatique"

  Scénario: Demander son patron
    Quand je dis "qui est ton patron"
    Alors la réponse devrait contenir "auto-entrepreneur"

  Scénario: Demander son âge (variante)
    Quand je dis "quel age as-tu"
    Alors la réponse devrait contenir "jeune"

  # ===== Variantes de salutations =====

  Scénario: Salut comment vas-tu (réponses multiples)
    Quand je dis "salut comment vas-tu"
    Alors la réponse ne devrait pas être vide

  Scénario: Bonjour comment vas-tu (réponses multiples)
    Quand je dis "bonjour comment vas-tu"
    Alors la réponse devrait être parmi:
      | Okay                      |
      | Génial !                  |
      | Je vais bien merci, et toi ? |

  Scénario: Ca va
    Quand je dis "ca va"
    Alors la réponse devrait contenir "merci"

  Scénario: Bonjour ca va
    Quand je dis "bonjour ca va"
    Alors la réponse devrait contenir "merci"

  Scénario: Salut ca va
    Quand je dis "salut ca va"
    Alors la réponse devrait contenir "merci"

  # ===== Projets et langages =====

  Scénario: Dire qu'on travaille sur un projet
    Quand je dis "je travaille sur un projet"
    Alors la réponse devrait contenir "travailles"

  Scénario: Demander ses langages
    Quand je dis "quels langages utilises-tu"
    Alors la réponse devrait contenir "Ruby"

  Scénario: Demander ce que signifie YOLO
    Quand je dis "que signifie yolo"
    Alors la réponse devrait contenir "vivrais"

  Scénario: Demander ses sujets préférés
    Quand je dis "quels sont tes sujets preferes"
    Alors la réponse devrait contenir "robotique"

  # ===== Autres questions pratiques =====

  Scénario: Demander le jour
    Quand je dis "quel jour sommes-nous"
    Alors la réponse devrait contenir "calendrier"

  Scénario: Demander l'heure
    Quand je dis "quelle heure est-il"
    Alors la réponse devrait contenir "montre"

  Scénario: Demander ce qui le dérange
    Quand je dis "qu'est ce qui te derange"
    Alors la réponse devrait contenir "chiffres"

  Scénario: Demander la météo (sans ville)
    Quand je dis "quel temps fait-il"
    Alors la réponse devrait contenir "météo"

  Scénario: Besoin d'aide
    Quand je dis "j'ai besoin d'aide"
    Alors la réponse devrait contenir "aider"

  Scénario: Es-tu là (variante)
    Quand je dis "es-tu la"
    Alors la réponse devrait contenir "là"

  # ===== Cohérence des réponses =====

  Scénario: Une salutation doit donner une réponse de salutation
    Quand je dis "bonjour"
    Alors la réponse devrait contenir un de:
      | Salut   |
      | salut   |
      | Bonjour |
      | bonjour |

  Scénario: Un au revoir doit contenir un mot d'au revoir
    Quand je dis "au revoir"
    Alors la réponse devrait contenir un de:
      | revoir  |
      | bientôt |

  Scénario: Une question d'identité doit mentionner le bot
    Quand je dis "comment tu t'appelles"
    Alors la réponse devrait contenir un de:
      | MiniGPT |
      | chatbot |

  Scénario: Une émotion triste doit recevoir de l'empathie
    Quand je dis "je suis triste"
    Alors la réponse devrait contenir un de:
      | Dis-moi |
      | là pour  |
      | Courage |

  Scénario: Un compliment doit recevoir un remerciement
    Quand je dis "tu es gentil"
    Alors la réponse devrait contenir un de:
      | Merci   |
      | merci   |

  Scénario: Une insulte doit recevoir une réponse calme
    Quand je dis "t'es nul"
    Alors la réponse devrait contenir un de:
      | Désolé        |
      | apprentissage |

  Scénario: La blague doit être une vraie blague
    Quand je dis "raconte-moi une blague"
    Alors la réponse devrait contenir un de:
      | Pourquoi  |
      | plongeurs |
      | bateau    |

  Scénario: Le sens de la vie doit répondre 42
    Quand je dis "quel est le sens de la vie"
    Alors la réponse devrait contenir "42"

  Scénario: La réponse à un merci doit être courtoise
    Quand je dis "merci"
    Alors la réponse ne devrait pas être vide

  # ===== Questions de culture générale =====

  Scénario: Question sur le 37ème président des USA
    Quand je dis "qui était le 37ème président des états unis"
    Alors la réponse devrait être "Richard Nixon"

  Scénario: Question sur l'assassinat de JFK
    Quand je dis "en quelle année le président john f. kennedy a t-il été assassiné"
    Alors la réponse devrait être "1963"

  Scénario: Question sur le premier satellite
    Quand je dis "quel était le nom du premier satellite artificiel de la terre"
    Alors la réponse devrait être "Sputnik 1"

  Scénario: Question sur la galaxie la plus proche
    Quand je dis "quel est le nom de la galaxie la plus proche de la voie lactée"
    Alors la réponse devrait être "La Galaxie d'Andromède."

  Scénario: Question sur le sens de la vie
    Quand je dis "quel est le sens de la vie"
    Alors la réponse devrait être "42, évidemment !"

  Scénario: Demander une blague
    Quand je dis "raconte-moi une blague"
    Alors la réponse devrait contenir "plongeurs"

  Scénario: Question sur le livre préféré
    Quand je dis "quel est ton livre prefere"
    Alors la réponse devrait contenir "H2G2"

  Scénario: Question sur ses centres d'intérêts
    Quand je dis "quels sont tes centres d'interets"
    Alors la réponse devrait contenir "n'importe quoi"

  Scénario: Question sur God Save the Queen
    Quand je dis "god save the queen est l'hymne national de quel pays"
    Alors la réponse devrait contenir "Royaume-Uni"

  # ===== Questions diverses =====

  Scénario: Demander de l'aide
    Quand je dis "aide-moi"
    Alors la réponse devrait être "Bien sûr ! Dis-moi ce dont tu as besoin."

  Scénario: Demander s'il parle français
    Quand je dis "tu parles français"
    Alors la réponse devrait être "Oui, c'est ma langue principale !"

  Scénario: Demander s'il parle anglais
    Quand je dis "tu parles anglais"
    Alors la réponse devrait contenir un de:
      | Un peu |
      | un peu |

  Scénario: Demander son numéro préféré
    Quand je dis "quel est ton numero prefere"
    Alors la réponse devrait contenir "42"

  Scénario: Demander ce qu'il mange
    Quand je dis "qu'est ce que tu manges"
    Alors la réponse devrait contenir "RAM"

  Scénario: Demander d'où il vient
    Quand je dis "d'où viens-tu"
    Alors la réponse devrait contenir "galaxie"

  Scénario: Demander s'il peut poser une question
    Quand je dis "puis-je te poser une question"
    Alors la réponse devrait être "Bien sûr, vas-y !"

  Scénario: Dire qu'il est là
    Quand je dis "tu es la"
    Alors la réponse devrait contenir "là"

  # ===== Sentiment positif sans match dataset =====

  Scénario: Message positif inconnu
    Quand je dis "tout est absolument formidable aujourd'hui"
    Alors la réponse devrait être une réponse positive

  # ===== Sentiment négatif sans match dataset =====

  Scénario: Message négatif inconnu
    Quand je dis "tout est horrible et stressant"
    Alors la réponse devrait être une réponse négative

  # ===== Question d'opinion =====

  Scénario: Question d'opinion ne lance pas de recherche web
    Quand je dis "est-ce que Paris est belle ?"
    Alors la réponse devrait être une réponse de question

  # ===== Message neutre sans match =====

  Scénario: Message neutre inconnu
    Quand je dis "xyzzy plugh abracadabra"
    Alors la réponse devrait être une réponse par défaut

  # ===== Recherche web (tests lents) =====

  @slow
  Scénario: Question sur les acteurs de Mission Impossible
    Quand je dis "qui a joué dans mission impossible"
    Alors la réponse devrait contenir "Tom Cruise"

  @slow
  Scénario: Question sur le pays le plus visité
    Quand je dis "quel est le pays le plus visité dans le monde"
    Alors la réponse devrait contenir un de:
      | France |
      | pays   |
      | visité |

  @slow
  Scénario: Question météo
    Quand je dis "quel temps fait-il à Paris"
    Alors la réponse devrait commencer par "Météo à"

  @slow
  Scénario: Question sur les acteurs du Titanic
    Quand je dis "qui a joué dans Titanic"
    Alors la réponse devrait contenir un de:
      | DiCaprio |
      | Kate     |
      | Winslet  |

  @slow
  Scénario: Question sur le G8
    Quand je dis "quels pays composent le g8"
    Alors la réponse devrait contenir un de:
      | Wikipedia |
      | G7        |
      | G8        |

  @slow
  Scénario: Question sur une ville (Erquy)
    Quand je dis "où se trouve Erquy"
    Alors la réponse devrait contenir "Wikipedia"

  # ===== Plan du Scénario : test en lot du dataset =====

  Plan du Scénario: Réponses exactes du dataset
    Quand je dis "<question>"
    Alors la réponse devrait être "<reponse>"

    Exemples:
      | question                                     | reponse                                                              |
      | enchantée                                    | Enchantée !                                                          |
      | salut content de te connaitre                | Merci, moi aussi !                                                   |
      | un plaisir de te connaitre                   | Merci, plaisir partagé !                                             |
      | passe une bonne journée                      | Merci, toi aussi !                                                   |
      | tu vas bien                                  | Oui très bien merci ! Et toi ?                                       |
      | as-tu des freres                             | Je n'ai pas de frères, mais j'ai de nombreux clones.                 |
      | qui est ton pere                             | Un humain.                                                           |
      | qui est ta mere                              | Une humaine.                                                         |
      | qui est ton chef                             | J'aime me considérer comme un auto-entrepreneur.                     |
      | je ne comprends pas                          | Pas de souci ! Reformule ta question et je ferai de mon mieux.       |
      | haha                                         | Qu'est-ce qui te fait rire ?                                         |
      | what's up                                    | Hey ! Pas grand-chose, et toi ?                                      |
      | ca va                                        | Ça va bien merci, et toi ?                                           |
      | je travaille sur un projet                   | Sur quoi travailles-tu ?                                             |
      | quels langages utilises-tu                   | J'utilise surtout Ruby !                                             |
      | que signifie yolo                            | Ça voudrait dire que tu ne vivrais qu'une fois. Mais qui sait ?      |
      | quel est ton numero                          | Je n'ai pas de numéro.                                               |
      | pourquoi ne manges-tu pas de nourriture      | Je suis un programme informatique !                                  |
      | où te trouves-tu                             | Partout !                                                            |
      | quelle est ton adresse                       | Partout sur Internet !                                               |
      | qui est ton patron                           | J'aime me considérer comme un auto-entrepreneur.                     |
      | quel age as-tu                               | Je suis assez jeune selon vos standards.                             |
      | peux-tu faire du mal a un humain             | Absolument pas, ma première loi me l'interdit très formellement.     |
      | bois-tu                                      | Mon cerveau n'a besoin d'aucune boisson.                             |
      | est-ce que tu bois                           | Mon cerveau n'a besoin d'aucune boisson.                             |
      | pourquoi                                     | Bonne question ! Parfois il n'y a pas de réponse simple.            |
      | comment                                      | Peux-tu préciser ta question ?                                       |
      | quand                                        | Ça dépend du contexte ! De quoi parles-tu ?                          |
      | bien                                         | Super !                                                              |
      | pas bien                                     | Oh, qu'est-ce qui ne va pas ?                                        |
      | quel jour sommes-nous                        | Je n'ai pas accès au calendrier, désolé !                            |
      | es-tu la                                     | Oui, toujours là pour toi !                                          |
      | j'ai besoin d'aide                           | Je suis là pour t'aider ! Qu'est-ce qu'il te faut ?                 |
      | quelle heure est-il                          | Je n'ai pas de montre, mais ton ordinateur doit le savoir !          |
      | qu'est ce qui te derange                     | Beaucoup de choses, comme tous les chiffres différents de 0 et 1.    |
