# slugger.online — Spécification du site officiel

**Version 1.0** — la 1.0 marque le point de départ, pas un jalon d'une série. Ce
document ne sera plus renuméroté : son historique est celui du dépôt, et
`git log docs/design/specification.md` répond mieux qu'un journal des modifications
recopié à la main, qui est lui-même une chose qui se périme.

**Langue :** français, par décision (§1.3). Ce que lit le visiteur est en anglais, par
une autre décision (§6).

---

## 1. Ce document

### 1.1 Ce qu'il est

La référence commune pour concevoir et construire le site de **slugger**, CLI et
bibliothèque .NET qui tirent des noms lisibles dans un vocabulaire fourni par leur
utilisateur.

Il décrit **ce qui est décidé et pourquoi**. Il ne décrit jamais ce qui existe.

Il tient cette forme du document équivalent de justdummies.io, qui l'a payée : trois
brouillons y ont vieilli en six semaines, et l'examen de cette dérive a montré que le
raisonnement n'avait pas bougé — ce qui avait pourri, c'étaient les faits recopiés et la
liste des tâches. Les interdits de §1.2 sont la conséquence de ce constat, reprise ici
plutôt que réapprise.

### 1.2 Ce qu'il ne contient jamais

| Interdit | Raison | Où ça vit à la place |
|---|---|---|
| **Un fait dont ce document n'est pas la source** — nombre de mots d'un thème, nom de paquet, version, syntaxe d'une option, nom d'un thème livré | Ces choses changent sans que personne pense à rouvrir une spécification | §2, sous forme de renvoi à la source |
| **Un état** — ce qui est construit, publié, en cours, manquant | L'état est ce qui se périme le plus vite, et il se périme silencieusement | Le dépôt, les paquets, l'intégration continue |
| **Un calendrier** — phases, ordre des livraisons, ce qui entre dans quel lot | Un plan est faux dès la première surprise, et il en survient toujours une | Le suivi de projet, quelle qu'en soit la forme |
| **Un journal des modifications** | Le dépôt en tient déjà un, exact | `git log` |
| **Une décision sans son raisonnement** | Une décision dont on a perdu la raison sera défaite par accident | §17, le registre de décisions |

Test à appliquer à toute phrase qu'on veut ajouter : *si l'implémentation changeait mais
que la décision tenait, cette phrase devrait-elle être réécrite ?* Si oui, elle n'a pas sa
place ici.

Un cas mérite d'être nommé parce qu'il se présentera souvent : **une exigence adressée à
la bibliothèque n'est pas un état.** Dire « le site ne réécrit jamais une seconde
formulation d'un refus » est une décision ; dire « la bibliothèque ne publie pas encore
ce qu'il faut pour cela » est un état. Le premier s'écrit ici, le second est une issue.
§10.4 tient cette ligne.

### 1.3 Sa langue

Le français. Son lecteur principal travaille dans cette langue, et le dépôt de la
bibliothèque écrit déjà ses décisions et son guide d'auteur de thème en français.

C'est une exception bornée à `docs/design/`. Partout ailleurs, l'anglais : code,
commentaires, commits, branches, titres de pull request, issues. Une exception écrite est
une règle ; une exception tacite est le début d'un dépôt en deux langues.

Elle n'a rien à voir avec §6, qui décide de la langue du site. Les deux se sont décidées
séparément et n'ont pas la même réponse.

### 1.4 Ce qu'il ne fige pas

- la direction artistique détaillée ;
- les textes définitifs, marketing compris ;
- le contenu de la documentation, qui appartient à la bibliothèque (§7.5) ;
- le détail de ce que le playground affiche, tant que §10 est respecté.

---

## 2. Faits volatils et leurs sources

Cette section remplace toute valeur qu'une page pourrait avoir envie de recopier.
**Aucun chiffre, aucune version, aucun nom de thème n'est écrit ici.** Chaque ligne dit où
le site va chercher la vérité, et par quel mécanisme.

| Fait | Source de vérité | Comment le site l'obtient |
|---|---|---|
| Versions des paquets, et celle que le playground exécute | Le registre NuGet, et la déclaration centralisée de versions du dépôt | Métadonnées centralisées, une seule déclaration (§14.1) |
| État de publication, et les commandes d'installation qui en découlent | Les mêmes métadonnées | Rendues, jamais saisies dans une page (§5.7, §14.1) |
| Options du CLI, leurs valeurs admises, leur description | Le type unique sur lequel la ligne de commande est déclarée, et dont l'aide est engendrée | Confronté en intégration continue à ce que le site affiche |
| Quels thèmes existent — embarqués dans le moteur, et transportés par le dépôt de la bibliothèque | Le paquet, et l'instantané épinglé (§7.5) | Énumérés au build, jamais listés dans une page |
| **Tout chiffre portant sur un thème** — noms, adjectifs, participes, combinaisons, marges sur les planchers | Le moteur, par son analyse | Compté au build. Le site n'énonce jamais un nombre qu'il n'a pas compté (§14.2) |
| Les slugs affichés | Le moteur lui-même | Produits au build, graine fixe (§14.3) |
| La prose d'un refus et celle d'une mesure | Le rendu que la bibliothèque publie (§10.4) | Rendu, jamais réécrit |
| Contenu des pages de documentation | La documentation utilisateur de la bibliothèque, à un tag de release publié | Instantané atomique, jamais réécrit (§7.5) |
| Ce qu'un thème dit de lui-même — intitulé, description, auteur, origine, dates | Le bloc descriptif que le thème porte et que le moteur ne consulte jamais, et la commande qui l'affiche | Lu au build ; une clé absente n'est jamais suppléée (§5.7, §7.6) |
| Le nom de chaque chose — slug, terme, mot, nom, épithète, jeton, segment | Le vocabulaire que la bibliothèque fixe, et les types de sa surface publique qui le portent en anglais | Employé tel quel (§5.9) |
| Le protocole qui valide le sens d'un thème, et ce qu'un thème livré lui doit | Le guide d'auteur de thème de la bibliothèque | Repris ou renvoyé selon §6.3, jamais réécrit (§3.7) |
| Données du comparatif | Un fichier de contenu validé par schéma, daté | Rendu depuis ce fichier (§11) |

**Règle générale.** Si le site affiche une information dont la bibliothèque, un paquet ou
un thème est la source, cette information descend jusqu'au site par un mécanisme, et le
mécanisme échoue bruyamment quand la source change. Recopier est interdit, y compris
« provisoirement ».

C'est la règle la plus importante du document. Les autres décrivent un produit ; celle-ci
décrit ce qui empêche le produit et sa vitrine de diverger.

Elle porte ici plus lourd qu'ailleurs, parce que la matière du produit **est** une liste
de mots. Un site qui recopierait ne serait-ce qu'une poignée d'adjectifs publierait un
thème qui n'existe pas.

---

## 3. Vision produit

### 3.1 Ce que slugger n'est pas

La première ligne n'est pas une précaution rhétorique, c'est la confusion la plus
probable du visiteur, et elle est causée par le nom du produit :

- **ce n'est pas un *slugifier*.** Il ne transforme pas un texte existant en slug. Il
  n'en reçoit aucun : il en **tire un** d'un vocabulaire. La famille d'outils qui
  transforme `"Hello World!"` en `hello-world` répond à un autre problème, et les deux se
  rencontrent dans la même phrase sans jamais se remplacer ;
- ce n'est pas un générateur d'identifiant unique — voir §3.6 ;
- ce n'est pas un générateur de secret, de mot de passe ou de jeton — voir §3.6 ;
- ce n'est pas un producteur de données réalistes, ni un *faker* ;
- ce n'est pas une bibliothèque de langue : le code ne sait rien des mots qu'il tire, et
  un nom de catégorie est une chaîne libre sans signification pour lui ;
- ce n'est pas un service : rien n'est appelé sur le réseau, ni par le CLI, ni par le
  playground.

### 3.2 La promesse

> **Tirer un nom qu'un humain retient, dans un vocabulaire qu'on possède, en disant quel
> adjectif a le droit d'accompagner quel nom.**

Deux moitiés, et aucune ne se suffit. Le vocabulaire est un fichier que son auteur écrit,
donc il est à lui. La restriction est ce qui l'empêche de produire des paires que personne
ne voudrait lire.

### 3.3 Les six choses que le visiteur doit comprendre

1. **un slug est lu par un humain** — nom de conteneur, de branche, d'environnement de
   prévisualisation, de fichier de plan. C'est toute la raison pour laquelle ce n'est pas
   un identifiant opaque ;
2. **sur une liste plate, une paire absurde est aussi probable qu'une bonne.** Les
   générateurs existants tirent leur adjectif dans une liste où tout va avec tout :
   `thundering-moon` et `weeping-server` sortent aussi volontiers que `focused-turing` ;
3. **la catégorie partagée est ce qui retire le tirage absurde**, et elle classe par
   **capacité** plutôt que par domaine. C'est la distinction qui décide si le mécanisme
   filtre réellement : une catégorie « astronomie » laisse passer `thundering-moon`, une
   catégorie « sonore » que `moon` ne déclare pas le rend intirable — tout en laissant
   possible `weeping-willow`, qui est un idiome anglais réel ;
4. **`common` est un socle, pas un repli** : tout nom l'atteint **en plus** de ce qu'il
   déclare. La conséquence pratique est qu'aucune catégorie n'a à atteindre seule le
   plancher d'adjectifs — c'est l'addition qui compte. Ce point a été établi par mesure
   contre les thèmes livrés, pas décidé en principe ;
5. **un thème est un fichier JSON**, déposé dans un dossier, identifié par son nom de
   fichier. Aucun code, aucune recompilation, et un fichier qui porte le nom d'un thème
   embarqué le masque ;
6. **un refus dit tout d'un coup, et une mesure dit de combien.** Une seule exécution
   rapporte tout ce qu'un fichier demande ; et la mesure, qui répond à la question que la
   validation ne pose pas, fonctionne **aussi sur un thème refusé** — c'est même là
   qu'elle sert.

Les points 2 et 3 sont le problème et sa réponse. Les présenter comme une seule idée est
l'erreur à éviter : le visiteur qui n'a pas vu le problème n'a aucune raison de trouver la
réponse intéressante.

### 3.4 Les deux manques que slugger comble

À énoncer distinctement, parce que ce sont deux arguments et non un :

- **restreindre quels adjectifs accompagnent quel nom**, à l'intérieur d'un même thème ;
- **choisir plusieurs thèmes nommés** sur une même exécution, le tirage étant alors
  pondéré et chaque thème restant un espace de noms étanche — on ne concatène jamais deux
  vocabulaires.

Le second est moins spectaculaire et se perd si on ne le nomme pas. Il est pourtant ce qui
distingue un outil d'une liste embarquée dans le programme qui s'en sert.

### 3.5 Le refus est un argument de premier plan

Un thème n'est jamais refusé une raison à la fois. Le parsing et la validation rapportent
**ensemble**, de sorte qu'une exécution dit à un auteur tout ce que son fichier demande —
et chaque refus nomme son sujet, le nom, la catégorie ou la clé, parce qu'un chiffre seul
ne dit pas quoi corriger.

La promesse retenue :

> **slugger refuse un vocabulaire qui ne tient pas, et il dit tout ce qui ne tient pas, en
> une fois.**

C'est la contrepartie exacte de ce que §3.2 demande à l'auteur. Un outil qui laisse écrire
son propre vocabulaire doit répondre de ce vocabulaire, sans quoi il déplace le problème
au lieu de le résoudre.

Le site présente donc le refus et la mesure comme des fonctionnalités, jamais comme des
cas d'erreur relégués à la documentation. Ils sont, avec la restriction par catégorie, ce
qui sépare réellement l'outil de ses voisins.

### 3.6 Deux avertissements

À publier sur le site, pas seulement dans la documentation.

**Un slug n'est pas unique.** Rien ne garantit qu'une exécution ne redonne pas ce qu'elle
a déjà donné. L'espace combinatoire d'un thème est fini, et le plancher que la validation
impose aux catégories est précisément placé au point où un thème a besoin d'un suffixe
pour éviter les collisions — les deux générateurs de référence du domaine sont tous deux
sous ce seuil, et tous deux en ajoutent un. Le site dit ce que le suffixe fait, et ce
qu'il ne fait pas.

**Un slug n'est pas un secret.** Il est tiré d'un vocabulaire public, avec un thème qu'on
peut lire. Il est donc devinable, et rien de ce qui dépend de l'imprévisibilité — mot de
passe, jeton, clé, identifiant de session — ne doit en être tiré.

Un troisième point n'est pas un avertissement mais une honnêteté, et il gagne à être dit :
**aucune règle ne juge le goût.** Rien dans l'outil ne dira qu'un adjectif est un nom mal
employé, ni qu'un participe prête une intention à une pierre. C'est pour cela que
l'exclusion d'un mot pour un nom précis existe **dans le thème** — là où le générateur de
référence a dû coder en dur le refus d'une paire malheureuse.

Ce que le produit fait de cette limite n'est pas rien, et c'est §3.7.

### 3.7 Le protocole qui valide le sens

La bibliothèque documente la façon de trouver ce que le chargement ne peut pas voir : des
familles de défaut nommées, des phases dans un ordre qui compte, et des thèmes livrés qui y
sont passés.

C'est un **troisième argument**, et le plus rare des trois. §3.4 nomme deux manques que
slugger comble chez ses voisins ; celui-ci n'est pas un manque de la concurrence, c'est un
manque du problème. Un outil qui dit comment vérifier ce qu'il ne sait pas vérifier
lui-même est une chose qu'on ne rencontre presque jamais, et le site le présente comme tel.

Trois conséquences ailleurs dans ce document :

- le catalogue dit d'un thème qu'il est passé par là, quand il l'est (§7.6) ;
- le playground porte la seule phase qui soit mécanique, et **jamais les autres** (§10.2) ;
- la prose du protocole appartient à la bibliothèque, pas au site (§2, §6.3).

Et une contrainte éditoriale qui vaut plus que les trois : **le site ne présente jamais le
protocole comme quelque chose que l'outil fait.** C'est un travail, qui se compte en passes
de relecture, et le document qui le décrit l'assume en publiant ses propres rendements. Le
présenter comme une fonctionnalité promettrait de l'automatisme là où il y a de la
discipline — et cette promesse-là se découvre fausse au premier essai, ce qui est le pire
moment.

---

## 4. Publics

Chaque public correspond à un livrable qui le sert. Une exigence d'audience sans page qui
la porte est une intention, pas une décision.

| Public | Ce qu'il doit pouvoir faire | Livrable |
|---|---|---|
| **Développeur .NET qui a besoin de noms lisibles** | Comprendre ce que change la restriction par catégorie, et installer | Page principale, actes I et II |
| **Auteur de thème** | Écrire, mesurer et corriger un thème **sans rien installer** ; comprendre les planchers ; savoir de combien il en est loin | Playground, mode thème (§10.2) ; catalogue de thèmes (§7.6) |
| **Développeur déjà équipé d'un générateur** | Répondre en une minute : qu'est-ce que le mien tire que je ne veux pas ? est-ce que ça remplace ou ça complète ? puis-je l'essayer sans rien changer ? | Page de positionnement (§11) |
| **Consommateur de la bibliothèque** | Voir que le moteur s'utilise sans le CLI, et ce qu'il expose | Documentation |
| **Contributeur** | Trouver le dépôt, les règles, les issues | Pied de page, liens externes |

**L'auteur de thème est le public que ce site sert le mieux, et c'est une décision.** Il
est aujourd'hui obligé d'installer le CLI pour savoir si son fichier tient ; le playground
lui retire cette étape. C'est le seul public pour lequel le site n'est pas une vitrine mais
un outil, et §10.2 en tire ses conséquences.

La réponse à la troisième question du public « déjà équipé » est **oui**, et le site doit
le dire explicitement : un thème s'essaie sur une exécution, sans migration et sans retirer
quoi que ce soit.

« En une minute » est une contrainte, pas une figure de style. Elle interdit que la page de
positionnement ouvre sur l'appareil comparatif qu'elle construit ; §11.3 en tire l'ordre
de la page.

---

## 5. Principes UX et éditoriaux

### 5.1 Montrer avant d'expliquer

De vrais slugs, de vrais thèmes, un vrai refus, une vraie mesure, un playground utilisable.
Les longs paragraphes marketing sont proscrits sur la page principale.

Le produit a un avantage rare ici : sa démonstration tient en une ligne de sortie. Il faut
s'en servir plutôt que de la décrire.

### 5.2 Le slug et le thème sont les objets visuels principaux

La direction graphique ne dépend d'aucune illustration générique — développeurs, robots,
cubes 3D, images décoratives. Les éléments visuels sont le slug produit, le fichier de
thème, le pool d'un nom, le terminal, le rapport de refus, le tableau de mesure, et les
transitions entre eux.

### 5.3 Le mouvement doit expliquer

Toute animation répond à une question fonctionnelle : quels adjectifs ce nom
atteint-il ? qu'est-ce que `common` ajoute ? qu'est-ce que la catégorie retire ? que
devient le slug quand le mode de segment change ? où passe le seuil qu'un thème rate ?

Une animation qui ne répond à aucune question est décorative, et les animations décoratives
restent rares et discrètes.

### 5.4 Une seule idée forte par écran

Chaque étape porte un message court, une transformation principale, un point focal unique.
C'est la règle qui arbitre quand deux éléments se disputent l'attention.

### 5.5 La page principale vend, la documentation explique

La page principale ne documente ni la liste exhaustive des options, ni le détail des quatre
règles de taille, ni le schéma complet d'un fichier de thème, ni le détail du comparatif.

### 5.6 Aucun thème inventé dans ce que le site publie

Tout slug affiché, tout extrait de thème, tout rapport montré vient d'un thème réel — un
embarqué, un transporté par le dépôt de la bibliothèque, ou un thème du dépôt du site écrit
pour l'occasion et soumis aux mêmes règles que les autres.

Un thème inventé pour la vitrine est un thème que personne n'a validé, et il finira par
montrer une paire que l'outil ne produit pas. Le mécanisme de §14.3 rend cette règle
vérifiable plutôt que morale.

Une seule exception, et elle est nommée en §14.4 : l'exemple **minimal** que le guide
utilise pour montrer ce qu'un refus dit est nécessairement un thème refusé. Sa propriété
d'être refusé est son propos.

### 5.7 Rien de visible ne mène nulle part sans que son état soit dit

Une commande, un lien ou un composant présenté sur le site est soit disponible, soit
accompagné d'un libellé d'état lisible.

Modalités, qui sont des exigences d'accessibilité autant que d'honnêteté :

- l'état est affiché **en clair**, jamais réservé au survol — il n'y a pas de survol sur
  mobile ;
- un élément en attente reste **focalisable** et porte `aria-disabled`, jamais l'attribut
  `disabled`, qui le retire de la navigation clavier et rend son explication inatteignable ;
- **aucune commande copiable n'est proposée pour ce qui n'est pas installable** ;
- l'état de chaque composant est une donnée de contenu, pas une décision prise dans un
  composant d'interface ;
- **contrôlé en intégration continue** : un composant présenté comme disponible dont la
  version n'est pas résoluble fait échouer le build. C'est ce contrôle qui fait la
  différence entre une règle et une intention.

Cette règle est ici plus qu'un principe de rédaction : le site peut être construit et
publié avant que tout ce qu'il présente soit installable, et c'est §5.7 seule qui décide de
ce qu'il a le droit d'afficher dans cet intervalle. Ce que le registre contient à un instant
donné est un état (§1.2) ; que le site le lise plutôt que de le supposer est la décision.

### 5.8 Le frappeur est la figure de la maison, jamais le sujet

Le nom du produit désigne un frappeur puissant au baseball, et le thème embarqué qui porte
son nom est construit autour de ce sport. La figure a donc le même statut que le mannequin
de crash-test sur justdummies.io : elle est la chose que le nom nomme, ce qui l'autorise à
revenir d'une page à l'autre sans contredire §5.2.

Les modalités sont celles qui gardent cette réponse vraie :

- **un seul par page.** Deux dessins sur un même écran, et la page parle d'eux ;
- **seulement là où la page n'a rien à montrer** : une 404, une marge vide, une colonne que
  la mesure du texte n'atteint pas. Jamais sur un écran qui démontre quelque chose (§5.4) ;
- **jamais devant du texte ni devant un slug.** Il passe derrière, ou il n'est pas là ;
- **il disparaît plutôt que de rétrécir.** En dessous de la place qu'il lui faut, il n'est
  pas dessiné du tout ;
- **une seule famille graphique** — même origine, même palette, même lumière ;
- **contrôlé en intégration continue** : un second dessin sur une même page, ou un dessin
  qu'une ligne de texte touche, fait échouer la suite navigateur, qui compare le texte aux
  pixels peints et non au CSS qui les place.

Le contrôle ne voit que les dessins qui se déclarent comme tels. Un dessin ajouté sans
cette marque lui échappe : c'est la limite du garde-fou, écrite ici plutôt que découverte.

### 5.9 Le site emploie les mots de la bibliothèque

La bibliothèque fixe son vocabulaire dans un document à elle : un mot par niveau, et un
seul, parce qu'un même mot en désignait deux. Ce que le site appelle les choses vient de là
et de nulle part ailleurs.

Ce document est en français ; les mots, eux, existent en anglais sur la surface publique du
moteur, qui les porte en types. Le site n'a donc rien à traduire (§6.3) : il lit les noms
que le code expose, et le document reste le raisonnement qui les a choisis.

L'enjeu n'est pas la cohérence pour elle-même. Un visiteur qui lit un mot sur le site, un
autre mot pour la même chose dans le guide, et un troisième dans un message d'erreur conclut
que le produit est plus compliqué qu'il n'est. §11.4 demande d'enseigner chaque terme ;
encore faut-il qu'il n'y en ait qu'un à enseigner.

### 5.10 Le site ne vend pas la fabrication

La bibliothèque est construite avec un soin qui se lit dans son dépôt : un portique de
qualité, deux moteurs de mutation, des tests qui remplacent un découpage en assemblages, un
registre de décisions, un vocabulaire fixé, une provenance signée à la publication. **Rien de
cela n'est sur le site.**

Ce n'est pas un oubli, c'est une décision, et elle est écrite ici parce qu'elle sera
rouverte — vraisemblablement par quelqu'un qui vient de lire le dépôt et qui trouve dommage
de ne pas le dire.

Le motif est que **ce n'est pas ce qui distingue l'outil.** Ce qui le distingue est en §3.4,
et un visiteur qui n'a pas encore compris la restriction par catégorie n'a aucune raison
d'être impressionné par un portique. Un site qui ouvre sur sa fabrication vend l'auteur
plutôt que l'outil, et c'est le piège classique d'une bibliothèque bien faite. §5.5 dit que
la page principale vend et que la documentation explique ; ici c'est **le dépôt** qui
explique, et il le fait mieux que ne le ferait une page.

Ce que la décision coûte, nommé pour qu'on puisse la rouvrir en connaissance de cause : le
lecteur qui demande ce que la bibliothèque mettra dans son build n'a pas de page qui lui
réponde, et il doit aller au dépôt. §5.7 continue par ailleurs d'exiger qu'un état soit dit —
une préversion est donc annoncée comme telle sur le bloc d'installation (§7.4) — mais sans la
raison qui la cause. Un état sans son motif est admis ici ; un état tu ne l'est pas.

**Une sous-règle survit à un renversement de la décision : aucune métrique de qualité,
jamais.** Ni score de mutation, ni nombre de tests, ni couverture, ni compte
d'avertissements. Trois motifs, et le dernier suffirait : ces chiffres sont volatils, ils
sont invérifiables depuis l'extérieur, et le score de mutation est documenté comme instable
par celui-même qui le mesure. §2 interdit déjà un fait dont le site n'est pas la source ;
publier un chiffre dont la source dit qu'on ne peut pas encore s'y fier serait pire que de
le recopier.

Deux choses ne relèvent pas de cette règle, et il faut le dire ici ou elles seront
supprimées par application zélée :

- **le protocole de §3.7.** Il décrit un travail que le *visiteur* fait sur *son* thème, pas
  un travail que l'auteur a fait sur la bibliothèque. Le premier est un outil pour le
  lecteur, le second un titre pour le producteur ; le site porte le premier et pas le
  second ;
- **ce que ce document raisonne.** La règle porte sur ce que le site **affiche**. Rien
  n'interdit à une décision d'ici d'être motivée par une contrainte de publication — §7.4
  l'est — tant que le motif reste dans la spécification et n'arrive pas sur une page.

---

## 6. Langue

### 6.1 Une seule langue pour le visiteur

**L'anglais, et lui seul.** Aucun préfixe de locale, aucune négociation, aucun sélecteur.

Le motif est le public : la bibliothèque est un paquet .NET dont le lecteur arrive par
NuGet, par GitHub ou par une recherche, et dont le README est déjà en anglais. Une seconde
locale ajouterait une synchronisation permanente pour un lectorat que rien ne mesure.

C'est une divergence assumée d'avec justdummies.io, qui est bilingue. La divergence est
écrite ici parce que le dépôt voisin sert de modèle technique (§12) et que reprendre son
montage sans reprendre ce choix-là doit être un acte, pas un oubli.

### 6.2 Ce que la décision coûte, et ce qu'elle n'interdit pas

Elle coûte le lecteur francophone qui aurait préféré sa langue, et le dépôt l'assume.

Elle **n'interdit pas** d'y revenir, et l'architecture ne doit pas rendre le retour
impossible :

- aucune chaîne affichée n'est écrite en dur dans un composant ; toutes vivent dans une
  table de chaînes, comme si une seconde locale existait ;
- le schéma d'URL ne réserve rien, mais ne s'interdit rien non plus : la racine sert
  l'anglais sans préfixe, ce qui est exactement la forme qu'aurait une locale par défaut.

Le coût de revenir est ainsi borné à l'écriture des traductions, ce qui est le coût
irréductible, plutôt qu'à une réécriture des composants.

### 6.3 Le désaccord avec la documentation de la bibliothèque

Il faut le nommer, parce qu'il se découvrirait autrement au moment de publier `/docs`.

La bibliothèque écrit son README en anglais et **son guide d'auteur de thème en
français**. Or §7.5 veut que le site reprenne cette documentation sans l'écrire, et §6.1
veut qu'il publie en anglais. Les deux règles ne peuvent pas être satisfaites ensemble par
ce site seul.

**La règle qui tranche est : le site ne traduit jamais ce que la bibliothèque a écrit.**
Traduire serait créer une seconde source de vérité, qui dériverait de la première au
premier correctif, et §2 existe pour empêcher exactement cela.

Deux issues, et ce document ne choisit pas laquelle arrive :

- la bibliothèque publie la moitié anglaise du document concerné, et la route le reprend
  comme n'importe quelle autre ;
- la route ne reprend pas ce document et **renvoie vers lui en disant qu'il est en
  français**, ce qui est §5.7 appliqué à une langue.

Ce qui est décidé, c'est que la troisième issue — le site écrit sa propre version anglaise
— est exclue.

Une remarque sur l'arbitrage, parce qu'elle en déplace le coût : ce document ne cesse pas de
grossir, et ce qu'il gagne est précisément ce que le site voudrait le plus — la façon de
valider le sens d'un thème (§3.7). La seconde issue, celle du renvoi, devient donc
progressivement moins acceptable. Elle reste ouverte ; elle n'est plus neutre.

---

## 7. Architecture de l'information

### 7.1 Navigation

Elle reste courte. Elle porte le playground, le catalogue de thèmes, le positionnement, la
documentation et le dépôt.

La **commande d'installation est présente en permanence dans l'en-tête** dès que le hero
est dépassé, sous forme compacte avec bouton de copie, et soumise à §5.7. Elle n'apparaît
pas au niveau du hero, qui porte déjà son propre appel à l'action.

Motif : répéter le bloc d'installation complet à chaque moment fort produit une cécité au
bloc, et chaque occurrence entre en concurrence avec le point focal de sa scène, ce qui
contredit §5.4.

### 7.2 Arborescence

```text
/
├── playground
├── themes
│   └── {theme}
├── why-slugger
├── docs
├── release-notes
├── about
├── privacy
└── 404
```

Les sections sont des **décisions de route** : le schéma d'URL est décidé ici. Les **pages
feuilles** ne sont jamais énumérées — `{theme}` vient du catalogue (§7.6) et quels thèmes
existent est un fait dont ce document n'est pas la source (§1.2, §2).

La distinction est ce qui fait tenir l'ajout : décider qu'un thème a une page à lui est une
décision d'architecture, qui survit à n'importe quel changement de la bibliothèque ; écrire
combien il y en a n'en est pas une.

### 7.3 Condition de publication d'une route

Ce document ne dit pas *quand* une route est publiée — c'est du calendrier (§1.2). Il dit à
quelles conditions elle *peut* l'être :

- son contenu est réellement utile à quelqu'un, et pas une page d'attente ;
- ce qu'elle présente satisfait §5.7 ;
- ce qu'elle affiche descend de sa source par un mécanisme (§2) ;
- elle n'apparaît dans la navigation que si les trois conditions précédentes tiennent.

### 7.4 Bloc d'installation

Composant unique, instancié aux moments de récompense de la narration et dans l'en-tête
sous forme réduite.

Il est conçu comme une **rangée à emplacements**, pas comme une composition figée. Le
produit se livre en **deux paquets distincts** — le moteur, et le CLI qui l'utilise — et
ces deux-là ne s'installent pas de la même façon ni pour le même lecteur. La rangée porte
donc au moins ces deux emplacements dès sa conception, et un emplacement dont la cible
n'est pas disponible suit §5.7.

Les deux emplacements ne portent pas forcément le même état, et la rangée doit l'admettre :
l'un peut être stable quand l'autre est en préversion. Le cas n'est pas accidentel — un
paquet ne peut pas se déclarer stable tant qu'il dépend d'une préversion, et celui qui
embarque ses dépendances n'a pas cette contrainte. Une rangée qui n'offrirait qu'une seule
forme de commande en rendrait donc une fausse, et §5.7 ne porte pas que sur l'absence : un
état mal dit est aussi un état non dit.

Le contenu de chaque emplacement — nom de paquet, commande, URL — vient des métadonnées
centralisées (§2, §14.1).

### 7.5 Contenu repris de la bibliothèque

Les routes sous `/docs` rendent un contenu que **le site n'écrit pas**. Il est repris de la
documentation de la bibliothèque, qui en reste l'unique auteur.

La reprise est **atomique et épinglée à un tag de release publié** — la version que le site
propose d'installer, de sorte que la documentation et la commande d'installation soient
deux affirmations sur le même artefact.

Trois conséquences, qui sont des règles et non des commodités :

- **§6.3 s'applique** : ce qui n'est pas publié en anglais par la source n'est pas traduit
  ici ;
- **rien de ce qui est repris n'est corrigé ici.** Un défaut trouvé dans une page reprise
  se corrige à la source, sans quoi la correction disparaît au prochain instantané ;
- **la péremption avertit, elle ne bloque pas.** Une documentation qui décrit une version
  dépassée est signalée, jamais transformée en échec de publication.

### 7.6 Le catalogue de thèmes

C'est la route que justdummies.io n'a pas d'équivalent pour, et elle est au centre de ce
site.

Elle présente **les thèmes embarqués dans le moteur et ceux que le dépôt de la bibliothèque
transporte sans les embarquer**, sans les distinguer par leur emplacement mais par ce
qu'ils demandent au lecteur : les premiers fonctionnent sans rien faire, les seconds
s'enregistrent.

Chaque thème a une page, et cette page **n'est pas écrite à la main**. Elle rend :

- ce que le thème produit — des slugs générés au build, par le moteur (§14.3) ;
- comment il classe ses mots — ses catégories, et ce que chacune permet ;
- **sa mesure**, telle que le moteur la produit : les marges sur chaque plancher, les noms
  déclarés deux fois, les catégories que personne ne porte, l'écart entre le mot le plus
  rare et le plus commun, la taille de son espace combinatoire ;
- ce qu'il doit à d'autres, quand il le doit : certains thèmes livrés reprennent le
  vocabulaire de générateurs existants, sous leur licence, et la page le dit. §11.1 explique
  pourquoi ce n'est pas une note de bas de page ;
- **ce que le thème dit de lui-même**, quand il le dit : un thème peut déclarer un intitulé
  d'affichage, une description, un auteur, une origine et des dates. Le moteur ne consulte
  jamais ce bloc — il existe pour qui distribue ou reprend un thème, et une page de catalogue
  est exactement ce lecteur-là. C'est la source de la prose de cette page, et la seule : le
  site ne décrit jamais un thème à sa place.

Deux conséquences, et les deux sont des pièges.

**L'intitulé d'affichage n'est jamais une identité.** Un thème est identifié par son nom de
fichier, et c'est ce nom qui est la clé de la route `{theme}`. Indexer sur l'intitulé
recréerait la seconde source de vérité que la bibliothèque a écartée exprès, et un thème
renommé d'un côté sans l'autre casserait des liens que rien ne vérifie.

**Tout y est optionnel, le bloc compris.** Un thème qui ne dit rien de lui-même a une page
qui ne dit rien de lui — pas une page avec une description inventée, et pas un blanc qui
laisse croire à un défaut d'affichage. C'est §5.7 appliqué à de la prose.

Cette page est le meilleur argument du produit, parce qu'elle n'argumente pas : elle montre
un thème mesuré par l'outil qu'elle vend, avec des chiffres que personne n'a choisis — et,
quand le thème est passé par le protocole de §3.7, elle le dit.

---

## 8. Direction artistique

### 8.1 Positionnement

Outil développeur précis : sobriété, confiance, lisibilité, une personnalité qui assume le
clin d'œil du nom sans verser dans le pastiche sportif. L'inspiration peut emprunter la
précision d'un outil comme Linear et les conventions visuelles d'un éditeur de code
moderne — sans copier aucun site existant.

Le produit est un outil de nommage : ce que le site doit dégager est le soin qu'on met à
choisir un mot, pas l'énergie d'un stade.

### 8.2 Palette

Fond sombre presque noir, légèrement chaud. Surfaces graphite. Texte blanc cassé. Une
couleur d'accent vive et distinctive pour le slug produit, qui est le point focal de
presque tous les écrans. Une couleur secondaire pour les mots du thème. Le vert réservé à
ce qui passe une règle, un corail ou rouge doux réservé aux refus, un ton neutre dédié aux
marqueurs d'état de §5.7 — distinct de l'accent comme de l'erreur.

Un besoin propre à ce produit : **le pool d'un nom se dessine.** Montrer qu'un adjectif est
atteignable et qu'un autre ne l'est pas demande deux traitements visuels qui ne sont ni une
réussite ni une erreur. La palette leur réserve donc une paire à elle, et §13.4 interdit que
la distinction repose sur la seule couleur.

Les valeurs exactes vivent dans les design tokens, jamais dans ce document : ce sont des
faits que le code possède.

### 8.3 Typographie

Une sans-serif lisible et expressive, une monospace hautement lisible pour le code, le
terminal et les slugs. Titres courts et généreux. Peu de capitales. Tailles fluides entre
mobile et desktop.

La monospace porte ici une exigence supplémentaire : un thème peut contenir des mots
accentués, et le moteur offre de plier les accents ou de forcer l'ASCII sans y être obligé.
Une police dont la couverture Latin Extended est incomplète rendrait donc illisible
exactement ce que le site veut montrer. C'est à vérifier au moment du choix, pas après.

### 8.4 Mode clair

Le site peut être conçu en mode sombre d'abord. Mais les tokens doivent permettre un mode
clair, et l'architecture CSS ne doit pas le rendre impossible : chaque couleur est nommée
par ce qu'elle fait, jamais par ce qu'elle est.

### 8.5 Identité

Marque typographique, symbole lisible à 16 px utilisable en favicon et en avatar,
déclinaison monochrome, gabarit d'image de partage. L'image de partage contenant le logo,
le logo la précède.

Le slug affiché sur l'image de partage est produit au build comme les autres (§14.3). Une
image qui montrerait un slug écrit à la main serait la seule surface du site à mentir, et
la plus partagée.

---

## 9. La narration

### 9.1 Technologie narrative

Le scroll pilote une narration visuelle continue : sections longues, panneaux adhérents,
timeline liée à la progression, transformation progressive du même thème, transitions de
focus entre le fichier, le pool d'un nom, le terminal et le slug produit.

Le parallax peut créer de la profondeur mais n'est pas la technologie principale.

### 9.2 Règle de continuité

Le visiteur ne doit pas avoir l'impression de consulter une succession de slides
indépendantes. La séquence est **une seule transformation**, en trois actes.

```text
ACTE I — le tirage absurde
  un générateur ordinaire, sa liste plate
  → une paire que personne ne voudrait lire, tirée aussi volontiers qu'une bonne
  → le nom déclare ce qu'il peut faire
  → l'adjectif qui ne partage rien avec lui devient intirable
  → la même liste, et plus aucune paire absurde

ACTE II — le vocabulaire est à vous
  → l'installation
  → un fichier JSON, déposé, reconnu par son nom
  → plusieurs thèmes nommés sur une même exécution
  → le style du thème voyage avec son vocabulaire

ACTE III — le thème répond de lui-même
  → un thème écrit trop vite
  → le refus, qui dit tout d'un coup
  → la mesure, qui dit de combien
  → le thème corrigé, et ce qu'il tire
```

L'acte I est le seul qui doit convaincre. Les deux suivants répondent à des questions que
seul un visiteur déjà convaincu se pose : où sont mes mots, et qu'est-ce qui me dit qu'ils
tiennent.

### 9.3 Chaque acte se termine par une sortie

Un visiteur convaincu à la fin de l'acte I n'a aucune raison de continuer, et la page doit
le laisser partir avec la commande d'installation en main.

Les sorties sont **graduées**, et la gradation suit §7.4 : l'acte I a montré le moteur et
sort sur lui ; l'acte II a montré la ligne de commande et sort sur les deux ; l'acte III a
montré l'écriture d'un thème et sort sur le playground, qui est ce dont son visiteur a
besoin ensuite. Une sortie qui propose ce que le visiteur n'a pas encore vu est du bruit.

### 9.4 La charnière de l'acte III

C'est le point de couture le plus délicat de la page : le visiteur vient de comprendre que
le vocabulaire est à lui, et l'acte suivant lui montre un fichier refusé. Sans phrase de
charnière explicite, il lit une mauvaise nouvelle là où on lui offre une garantie.

Une phrase de charnière est donc **obligatoire** à l'ouverture de l'acte III. Sa
formulation est un travail éditorial ; son existence est une décision, et son contenu est
contraint : elle doit énoncer que le refus est la contrepartie de la liberté de l'acte II,
et non un défaut de l'outil.

### 9.5 Ce que l'acte I ne dramatise pas

Le tirage absurde n'est pas présenté comme une faute des générateurs existants. Une liste
plate est un choix raisonnable pour qui n'a pas besoin de mieux, et les générateurs de
référence ont rendu le service qu'on leur demandait pendant des années.

L'acte I montre une limite, pas une erreur. §11.1 est la même règle, appliquée plus loin
dans le site ; les deux tomberaient ensemble.

### 9.6 Ce que la narration ne promet pas

La page ne promet jamais l'unicité (§3.6), ni qu'un thème valide est un bon thème (§3.6,
troisième point). L'acte III promet qu'un fichier qui ne tient pas est refusé et mesuré —
pas qu'un fichier qui tient se lit bien.

La formulation retenue doit rester compatible avec ce que la bibliothèque dit d'elle-même.

### 9.7 Ce que la narration coûte

Chaque scène animée doit être construite **quatre fois** : desktop, mobile, mouvement
réduit, et sans JavaScript. C'est le vrai coût d'une scène, et il se budgète avant d'écrire
la première.

Quand ce coût devient intenable, les ajustements se font dans cet ordre, du moins coûteux
au plus coûteux pour la narration :

1. fusionner deux scènes structurellement proches d'un même acte ;
2. fusionner la charnière et la scène qui la suit ;
3. rétrograder l'acte II, puis l'acte III, en bloc statique.

L'acte I n'est jamais rétrogradé. Il porte seul la démonstration, et un bloc statique qui
montre deux listes de mots ne démontre rien. L'ordre est délibéré, et le décider d'avance
évite de le décider sous contrainte.

### 9.8 Le hero

Il présente la marque et permet une première interaction : un slug, et de quoi en tirer un
autre.

Contraintes de chargement :

- le contenu principal est disponible sans charger le runtime .NET ;
- le premier affichage n'en dépend pas ;
- le runtime n'est **jamais** chargé sans action explicite du visiteur ;
- avant chargement, le slug affiché est un vrai slug produit au build par le vrai moteur
  (§14.3) ; après chargement, les slugs sont produits en direct.

**Il n'existe qu'un seul producteur de slugs, le moteur.** Aucun générateur n'est écrit en
JavaScript, donc aucune divergence n'est possible.

C'est une règle que ce produit rendrait particulièrement facile à enfreindre : tirer un mot
au hasard dans deux tableaux JavaScript est un exercice de quelques lignes, et le résultat
ressemblerait à s'y méprendre à ce que l'outil produit. Il ne respecterait ni les
catégories, ni les exclusions, ni le style du thème — c'est-à-dire précisément ce que le
site existe pour montrer.

### 9.9 Le comportement à ne pas neutraliser

Le hero permettant de retirer, un visiteur finira par tomber sur une paire qui le fait
sourire, ou sur un slug plus long qu'il n'espérait. **La démonstration se défend
elle-même** : rien n'est filtré après coup pour embellir la sortie.

Un filtre au-dessus du moteur serait la même faute que §9.8 refuse, dans l'autre sens : le
site montrerait autre chose que ce que l'outil produit. Ce qui doit changer quand une paire
déplaît, c'est le thème — et c'est exactement ce que l'acte III enseigne.

---

## 10. Le playground

### 10.1 Nature

Une application exécutée **entièrement dans le navigateur**, sans backend, qui fait tourner
le vrai moteur.

Elle est montée **sous un préfixe du site**, pas sur un sous-domaine. Un seul artefact, un
seul Worker, une seule politique de contenu, un seul déploiement — et les deux moitiés
vérifiées ensemble à chaque build (§12.2). Un sous-domaine coûterait un second pipeline,
une seconde politique et une mesure dédoublée, pour une indépendance dont rien n'a besoin.

### 10.2 Deux usages, un seul moteur

C'est la décision structurante de la route, et ce qui la distingue d'un playground de
démonstration.

**Tirer.** Le visiteur choisit un ou plusieurs thèmes parmi ceux du catalogue (§7.6), règle
les options que la ligne de commande offre, et génère. C'est la version en ligne de ce que
le CLI fait.

**Éprouver un thème.** L'auteur de thème ouvre son fichier et reçoit, du même moteur que le
CLI exécute :

- le **refus complet** si le fichier ne tient pas — toutes les raisons, chacune nommant son
  sujet ;
- la **mesure** s'il veut savoir de combien : marges sur chaque plancher, doublons,
  catégories que personne ne porte, écart d'exposition entre les mots. Elle fonctionne sur
  un thème refusé, ce qui est le cas qui compte ;
- de quoi **tirer immédiatement** avec son thème, y compris en levant les planchers pour
  un fichier en cours d'écriture ;
- le **contrôle mécanique** du protocole de §3.7 : redécomposer chaque slug tiré en ses
  termes et vérifier chacun contre les exclusions que le thème déclare. C'est un filtre et
  non une lecture, et un navigateur le passe sur des milliers de tirages sans se fatiguer —
  là où son auteur, lui, se fatigue.

Ce dernier point porte une limite qu'il faut écrire plutôt que laisser deviner : **le
playground ne valide pas le sens d'un thème, et ne le prétend jamais.** Les phases du
protocole qui trouvent le plus sont des lectures humaines, et aucune ne s'automatise. Un
bandeau vert après le contrôle mécanique dirait à un auteur que son thème est bon là où il
dit seulement que le fichier est cohérent avec ce qu'il déclare — exactement le malentendu
que le protocole existe pour dissiper.

Le second usage est ce que §4 appelle le public le mieux servi. Il retire à l'auteur de
thème la seule étape qui l'obligeait à installer quelque chose avant de savoir si son
travail tenait.

Les deux usages partagent un moteur et une interface. Ils ne sont pas deux applications
côte à côte : un thème qu'on vient d'éprouver se tire dans la foulée, sans changer de page.

### 10.3 Ce qu'il ne fait jamais

Exécuter du JavaScript saisi par le visiteur, compiler du code libre, effectuer un appel
réseau arbitraire, accéder au système de fichiers au-delà du fichier que le visiteur ouvre
lui-même, ou persister une saisie ailleurs que dans le navigateur.

### 10.4 Ce que le playground demande à la bibliothèque

Le moteur sépare les faits de la prose : il rend des données, et c'est la ligne de commande
qui écrit les phrases. C'est une bonne séparation, et le playground est exactement le
second consommateur qu'elle prévoyait.

Il en découle **deux exigences adressées à la bibliothèque**, et elles sont écrites ici
pour être satisfaites plutôt que découvertes :

- **la formulation d'un refus doit être atteignable par un autre rendu que le CLI.**
  Aujourd'hui une seule formulation existe, ce qui est précisément la qualité à préserver :
  un refus lu dans le playground et le même refus lu dans un terminal doivent être le même
  texte ;
- **le modèle de la mesure doit être publiable.** Le rapport est calculé par le moteur et
  mis en forme par son consommateur ; un consommateur écrit en .NET qui n'atteint pas le
  modèle ne peut pas le mettre en forme.

**La règle que ces exigences servent : le site ne réécrit jamais une seconde formulation
d'un refus ni d'une mesure.** Une seconde formulation dérive de la première au premier
correctif, et elle dérive en silence — les deux textes restent plausibles, et rien ne les
compare.

Tant qu'une exigence n'est pas satisfaite, c'est §7.3 qui s'applique : la route ne publie
pas ce qu'elle ne peut pas rendre fidèlement. Elle ne publie pas une approximation.

### 10.5 Pourquoi il n'y a pas de catalogue généré

justdummies.io fait descendre la surface de sa bibliothèque jusqu'à son playground par un
catalogue de code engendré au build, parce que son playground interprète une expression que
le visiteur écrit, sur toute la surface publique.

Ce playground n'en a pas besoin, et il faut dire pourquoi plutôt que de laisser croire à un
oubli : **il ne pilote pas un langage, il pilote un jeu d'options fixe** — celui de la
ligne de commande. Le pont est donc un appel typé ordinaire vers le paquet publié, et un
bris de compatibilité de la bibliothèque devient une erreur de compilation du site, ce qui
est la propriété qu'on cherchait.

Ce qui reste vrai malgré tout : **les options que le playground offre et celles que le CLI
accepte sont la même liste.** Une option ajoutée à la ligne de commande et oubliée ici n'est
pas une erreur de compilation, c'est un playground silencieusement en retard. C'est le seul
endroit où la dérive reste possible, et §16 porte le contrôle qui la ferme.

Le risque n'est pas théorique, et il valait d'être mesuré avant d'être cru : la ligne de
commande a gagné des options dans les semaines qui ont suivi la rédaction de cette section.
Le contrôle qui compare les deux listes est donc une condition de publication de la route,
pas une amélioration ultérieure.

### 10.6 Le thème du visiteur ne quitte jamais son navigateur

Un fichier ouvert dans le playground n'est envoyé nulle part, n'est enregistré nulle part,
et n'est connu de personne.

Ce n'est pas seulement une position sur la vie privée. Un thème est un travail
d'écriture — parfois des mois de collecte de vocabulaire — et son auteur a le droit de
l'éprouver sans le publier. Le dire explicitement sur la page est une condition de l'usage
que §10.2 vise.

La propriété est **structurelle et non déclarative** : il n'y a pas de serveur applicatif à
qui l'envoyer (§12.3).

### 10.7 Ce qui est partageable, et ce qui ne l'est pas

L'état d'un tirage — les thèmes choisis, les options réglées — s'encode dans le **fragment
d'URL**, qui ne coûte rien côté serveur et n'atteint aucun journal.

**Un thème que le visiteur a ouvert n'est pas partageable**, et ce n'est pas une limite à
lever. Le rendre partageable demanderait de le transmettre, ce que §10.6 refuse. Le site le
dit plutôt que de laisser chercher le bouton.

### 10.8 Contraintes d'élagage

Élagage activé. **Avertissements d'élagage traités comme des erreurs**, et non regroupés,
pour que chacun soit visible. Aucune réflexion dans le code du playground.

Et la règle qui compte plus que les précédentes réunies : **les tests de bout en bout
s'exécutent sur l'artefact publié**, jamais sur un build de développement. C'est la seule
qui attrape la classe de défauts qui n'existe qu'après élagage — et le moteur charge ses
thèmes embarqués comme des ressources, ce qui est exactement le genre de chose qu'un
élagueur retire quand rien ne la nomme.

### 10.9 Chargement

Le shell s'affiche immédiatement. Le téléchargement du runtime est visible par un état de
chargement avec **progression réelle**, non simulée.

La compilation anticipée n'est pas activée par défaut, et ne sera envisagée qu'après mesure
du compromis entre taille téléchargée et vitesse d'exécution.

---

## 11. Positionnement comparatif

### 11.1 Principe directeur

Une page de comparaison ne convainc que si elle est manifestement capable de dire du bien
des autres. Ce principe prime sur l'envie de gagner chaque ligne.

Ce produit a de quoi le prouver mieux qu'un argument : **deux de ses thèmes livrés
reprennent le vocabulaire de générateurs existants, sous leur licence et avec leur
attribution.** Il ne se contente pas de dire du bien d'eux, il les transporte. La page le
montre, et c'est ce qui rend crédible tout ce qu'elle dit d'autre.

### 11.2 Le concurrent qu'il ne faut pas oublier

Le comparatif couvre les générateurs du domaine, **l'identifiant opaque**, et **la liste
écrite à la main**.

L'identifiant opaque est le concurrent réel, et l'ignorer ferait parler la page à côté de
son lecteur : quiconque a besoin d'un nom unique et n'a pas besoin qu'on le lise prend un
GUID et a raison. La page doit dire à quel moment ce choix cesse d'être le bon, ce qui est
la seule chose qui distingue le domaine entier.

La liste écrite à la main est le second : un tableau d'une vingtaine d'adjectifs dans une
classe utilitaire est ce que la plupart des équipes ont réellement, et c'est un choix
défendable tant que personne n'a besoin d'en changer.

### 11.3 La conclusion d'abord, la preuve ensuite

§4 demande à un développeur déjà équipé de répondre **en une minute**. Une matrice ne se
lit pas en une minute : elle demande d'abord d'apprendre ses critères, puis de les
appliquer soi-même.

**La page conclut, puis prouve.** Elle se lit à quatre profondeurs, et aucune n'est le
prérequis de la précédente :

| Profondeur | Ce que le lecteur en repart avec |
|---|---|
| **le problème** | ce que fait slugger et pourquoi il existe, sans comparatif ni vocabulaire spécialisé |
| **le besoin** | une situation de nommage par option, pour se reconnaître avant de comparer ; la coexistence ; l'essai sans migration |
| **les critères** | chaque critère enseigné là où il sert, puis appliqué aux options |
| **la preuve** | les nuances, les limites, la matrice, les sources, la date, le droit de réponse |

La richesse n'est pas retirée, elle est rangée.

### 11.4 Aucun critère n'est affiché sans être enseigné

« Restriction par catégorie partagée », « espace combinatoire », « pool résolu » : ces
intitulés ont un sens précis. Avoir un sens précis n'est pas être compréhensible.

Chaque axe porte donc, **en donnée et non en balisage** :

- un **intitulé en langue courante**, lisible sans expertise préalable ;
- la **question concrète** qu'il tranche, posée comme le lecteur se la poserait ;
- une **explication courte**, une idée par phrase ;
- le **terme technique**, quand il en existe un, en information secondaire ;
- un **exemple**, facultatif, et seulement quand il apprend plus qu'une phrase de plus.

Un axe de cette page a une chance que les autres n'ont pas : son exemple peut être une
paire de mots. `thundering-moon` enseigne « restriction par catégorie » plus vite que
n'importe quelle définition, et il ne demande au lecteur de connaître ni le domaine ni le
produit.

L'intitulé, la question et l'explication sont **visibles**. Ce qui approfondit peut être
replié, à trois conditions : le mécanisme est natif, il s'ouvre au clavier, et il se voit
sans survol. Il n'y a pas de survol sur mobile, et une information indispensable rangée dans
une infobulle est une information absente.

### 11.5 Axes

Ce que cette section fixe, c'est ce que chacun compare ; leurs intitulés définitifs sont du
contenu et vivent avec lui (§2) :

- si l'adjectif tiré doit pouvoir s'appliquer au nom qu'il accompagne ;
- à qui appartient le vocabulaire, et ce qu'il en coûte d'en changer ;
- s'il faut recompiler, ou redéployer, pour ajouter des mots ;
- ce qui arrive à un vocabulaire mal formé : refus, ou acceptation silencieuse ;
- si l'outil dit **de combien** on rate une règle, ou seulement qu'on la rate ;
- si plusieurs vocabulaires peuvent servir sur une même exécution ;
- ce que le résultat garantit sur l'unicité, et ce qu'il faut ajouter pour l'approcher ;
- si un tirage se rejoue à l'identique ;
- si le nom produit est destiné à être lu par un humain ;
- ce qu'il faut installer, et dans quel écosystème cela existe.

L'avant-dernier axe est celui qui range l'identifiant opaque à sa place, et il doit le
ranger honnêtement : sur l'unicité, il gagne, et la page le dit.

### 11.6 Coexistence

À dire explicitement et **tôt**, parce que c'est le principal frein à l'essai : slugger
n'exige aucune migration, s'essaie sur une exécution, et n'oblige à retirer quoi que ce
soit. Un projet qui garde son générateur actuel peut lui emprunter son vocabulaire — deux
des thèmes livrés sont exactement cela.

Tôt ne veut pas dire en premier. La phrase répond à une objection, et une objection sans
désir n'existe pas encore : le haut de page dit d'abord ce que fait l'outil.

### 11.7 Règles éditoriales et gouvernance

- ton factuel, aucune formulation dépréciative, aucun superlatif comparatif ;
- **une idée principale par phrase** ;
- **le concret avant l'abstrait** — la situation de nommage avant le nom théorique ;
- **aucun métadiscours** : une phrase affichée aide à comprendre, à choisir ou à
  approfondir ; elle ne commente jamais la façon dont ce comparatif a été construit ;
- **aucun renvoi qu'un autre rendu peut casser** : une note ne dit ni « ci-dessus » ni
  « ci-dessous », puisqu'un duel masque des colonnes ;
- **rien de décoratif** : toute phrase affichée apporte une information ;
- toute affirmation sur un outil tiers est **vérifiable dans sa documentation officielle ou
  son dépôt, et datée** — et la page **montre ces sources** ;
- les noms et la casse retenus par leurs auteurs sont respectés ;
- une remarque sur l'activité d'un projet n'est admise que sous forme de fait daté et
  sourçable ;
- une **date de dernière vérification** est affichée, et c'est une donnée de contenu :
  au-delà d'un délai déclaré, le build émet un avertissement ;
- une issue dédiée invite les auteurs des outils cités à signaler toute inexactitude, et
  **cette invitation est visible sur la page**.

Les données du comparatif sont un fichier structuré validé par schéma (§2), pas du
balisage — l'enseignement de chaque axe compris. La comparaison critère par critère, le duel
et la matrice sont trois rendus d'une même source.

---

## 12. Architecture technique

### 12.1 Découpage

Un générateur de site statique porte la page principale, la narration, le catalogue de
thèmes, les pages de contenu et le référencement. Une application WebAssembly porte le
playground, et **uniquement là où l'exécution réelle du moteur apporte une valeur**.

La page principale n'impose jamais le téléchargement du runtime .NET au visiteur qui
consulte seulement la présentation (§9.8).

Le catalogue de thèmes est du site statique, pas du playground : ses pages montrent des
mesures et des slugs produits **au build** (§7.6, §14.3), et rien n'y demande au visiteur de
télécharger un runtime pour lire un tableau.

### 12.2 Un seul artefact

Le site est livré comme **un seul répertoire statique**, construit en un seul endroit, le
playground étant assemblé dedans sous son préfixe. Les deux moitiés s'accordent sur ce
préfixe par construction — configuration de build d'un côté, base de résolution des URL de
l'autre — et non par une correction appliquée après coup.

Ce désaccord-là ne produit pas d'erreur : le document se charge, chaque URL relative résout
un niveau trop haut, et le visiteur voit une page blanche. Il est donc **vérifié à chaque
build**.

### 12.3 Hébergement

Un hébergeur d'assets statiques, sans serveur applicatif.

**Aucun script serveur par défaut.** Les requêtes servies comme assets statiques sont
gratuites et illimitées ; celles qui invoquent un script comptent dans un quota, dont
l'épuisement répond par une erreur plutôt que par un repli sur les assets. La différence
entre un script et pas de script est celle entre un site qui se dégrade et un site qui
tombe.

En introduire un est une décision à prendre exprès, jamais à découvrir dans un diff, et
elle n'est acceptable qu'à une condition : que le script reste **hors du chemin** de tout
ce que le site sert, de sorte que le quota qu'il peut épuiser soit le sien seul.

Le cas qui tentera de le faire est celui des URL partageables du playground, et la réponse
y est non (§10.7) : le fragment d'URL ne coûte rien côté serveur.

### 12.4 Construction et déploiement

Le build et la validation s'exécutent dans l'intégration continue, et l'hébergeur reçoit un
répertoire **déjà construit et déjà vérifié**.

Le pipeline exécute **les mêmes scripts qu'un mainteneur exécute**, jamais une
réimplémentation en YAML : un pipeline qui redit le build local dérive de lui, et la dérive
ne se découvre que lorsque l'un des deux est déjà faux.

Une branche ne publie jamais. Ce qui publie est un acte nommé d'avance et vérifié.

Chaque pull request produit une URL de prévisualisation isolée, non indexée, servie avec les
mêmes en-têtes de sécurité que la production.

### 12.5 Ce qui doit être validé par un déploiement réel

Certaines propriétés ne se vérifient pas en local, et les supposer est le meilleur moyen de
les découvrir en production :

- la prise en compte effective des fichiers d'en-têtes et de redirections ;
- l'ordre entre le service d'un asset et l'application d'une règle de réécriture ;
- l'unicité, la stabilité et la rétention des URL de prévisualisation ;
- la compression réellement appliquée aux ressources WebAssembly.

Chacune est marquée comme telle là où elle est configurée, pour que la vérification ait un
lecteur.

---

## 13. Sécurité, performance, accessibilité

### 13.1 En-têtes

Politique de sécurité du contenu, protection contre le sniffing de type, politique de
référent, politique de permissions, protection contre l'intégration en iframe, et transport
strict une fois le domaine validé.

Le cache distingue trois régimes : le HTML est **toujours revalidé**, car c'est le document
qui nomme les assets empreintés ; les assets empreintés sont immuables ; ce qui n'est pas
empreinté prend une durée courte.

### 13.2 La politique de contenu et WebAssembly

Une politique qui interdit toute évaluation dynamique rend le playground impossible : un
runtime WebAssembly ne démarre pas sans autorisation d'instancier un module.

L'autorisation requise est **étroite** — elle permet la compilation WebAssembly et rien
d'autre, ni évaluation de chaîne, ni construction de fonction, ni script en ligne. Elle est
**autorisée et documentée** ; l'autorisation large reste **interdite**.

Deux règles complètent :

- **aucun script ni style en ligne non couvert.** Ce qui reste en ligne malgré tout est
  couvert par une empreinte nommée dans la politique, recalculée à chaque build ;
- **toute évolution de la politique est validée par un chargement réel** du playground,
  jusqu'à la génération d'un slug. Une politique correcte au regard d'une revue de code peut
  être fausse au regard du navigateur.

### 13.3 Performance

Objectifs de Core Web Vitals au 75e percentile lorsque les données terrain existent.

Pour la page principale : aucune ressource du playground dans le chemin critique, budget
chiffré pour le JavaScript initial, animation et narration chargées seulement là où elles
servent, images vectorielles préférées, polices limitées.

Pour le playground, la contrainte qui compte est **le temps que le visiteur attend avant son
premier slug**. Ce délai est budgété, mesuré à chaque build, et mesuré séparément à froid et
avec cache.

Une charge propre à ce produit mérite d'être budgétée à part : **les thèmes pèsent.** Un
thème est une liste de mots, et une liste de mots assez grande pour passer les planchers
n'est pas petite. Le playground n'a donc pas à embarquer tout le catalogue pour démarrer, et
ce qui n'est pas requis pour le premier tirage est chargé à la demande.

Deux propriétés du catalogue rendent cette règle structurante plutôt que prudente : il
**grandit**, puisque rien ne limite le nombre de thèmes qu'un dépôt peut transporter, et il
est **inégal**, un thème pouvant peser plusieurs fois ce que pèse son voisin. Un budget
mesuré sur la somme du catalogue serait donc faux dans les deux sens. Ce qui est budgété est
le premier tirage, et le coût marginal d'un thème de plus.

Ce qui n'est pas négociable, c'est qu'un budget chiffré existe et soit mesuré à chaque
build : sans cela, le poids d'une application WebAssembly ne fait que croître.

### 13.4 Accessibilité

Cible **WCAG 2.2 niveau AA**.

Navigation clavier complète, ordre de focus logique, focus visible, contrastes conformes,
labels explicites, titres hiérarchisés, liens externes identifiables.

**Aucun contenu transmis par la seule couleur.** Cela vaut pour les refus, pour les
marqueurs d'état de §5.7, pour les cellules du comparatif — et tout particulièrement pour
la distinction de §8.2 entre un mot qu'un nom atteint et un mot qu'il n'atteint pas, qui est
une information et non un effet.

Un terminal animé est aussi représenté comme texte, les boutons de copie ont un retour
accessible, et les messages d'erreur sont associés à la zone qui les provoque. Un rapport de
refus est une liste, et il est balisé comme telle : c'est ce qui permet de l'atteindre
raison par raison.

### 13.5 La narration accessible

Le DOM contient les informations dans un ordre logique, indépendamment des animations. Le
contenu n'est jamais rendu inaccessible par un positionnement hors écran, par un ordre DOM
différent de l'ordre visuel, par une narration qui dépend d'un scroll précis, ou par du
texte intégré à une image.

**Sans JavaScript, une version linéaire simplifiée de l'histoire reste compréhensible.**

Sous préférence de mouvement réduit : pas de scrub continu, pas de mouvement automatique
persistant, les zooms et déplacements remplacés par des fondus courts ou des changements
instantanés, chaque étape présentée dans l'ordre du document, et **l'intégralité de
l'information conservée**.

---

## 14. Gouvernance du contenu

C'est la section qui empêche le site de mentir sur son propre produit, et §2 en est le
résumé exécutable.

### 14.1 Métadonnées centralisées

Noms de paquets, versions, commandes d'installation, URL de registre et état de publication
vivent en **un seul endroit**. Aucune page ne les écrit.

### 14.2 Aucun chiffre sur un thème n'est énoncé

**Tout nombre qu'une page affiche au sujet d'un thème est compté au build par le moteur.**
Combien de noms, combien d'adjectifs un nom atteint, combien de combinaisons une catégorie
totalise, de combien un thème dépasse un plancher : aucune de ces valeurs n'est saisie.

Le motif est plus fort ici que le motif général de §2 : ces chiffres **changent à chaque
mot ajouté**, par quelqu'un qui n'a aucune raison de penser au site en ajoutant un mot. Un
nombre recopié serait faux avant d'être relu.

La même règle vaut pour les planchers eux-mêmes. Ils sont un cliquet du côté de la
bibliothèque — le jour où l'un d'eux monte, les thèmes montent avec —, et une page qui les
recopierait annoncerait une règle que l'outil n'applique plus.

### 14.3 Slugs générés

**Tout slug affiché sur le site est produit au build par le vrai moteur.**

Un slug écrit à la main dans le contenu est un mensonge à retardement : le jour où le
format produit évolue — un séparateur, une casse, un suffixe — la page continue d'afficher
l'ancien. L'exécution est **déterministe**, avec une graine fixe, pour qu'un build ne
produise pas une différence gratuite à chaque commit.

Le moteur offre cette graine ; la règle ne demande donc aucun mécanisme qui n'existe pas
déjà.

Bénéfice secondaire, qui vaut la peine d'être nommé : ce mécanisme est un test de bout en
bout permanent du moteur. Si un thème mis en avant cesse de produire un slug, le build du
site échoue.

### 14.4 Aucun exemple publié n'est refusé par le moteur

> Aucun thème publié sur le site n'est refusé par la validation, et aucun slug affiché n'est
> une paire que son thème ne peut pas tirer.

Mise en œuvre : les thèmes que le dépôt du site écrit pour ses exemples sont chargés en
intégration continue avec les règles ordinaires, sans dérogation — exactement ce que le
dépôt de la bibliothèque fait déjà pour les thèmes qu'il transporte.

Une exception, nommée : **le thème volontairement refusé** dont l'acte III et la
documentation se servent pour montrer ce qu'un refus dit. Sa propriété d'être refusé est son
propos, et il est sorti du contrôle par son nom plutôt qu'en abaissant le contrôle. Une
exception qui tient sur une ligne qu'un lecteur peut retrouver vaut mieux qu'une règle qu'on
baisse.

Une seconde, déjà écrite ailleurs : ce qu'un visiteur ouvre dans le playground lui appartient
(§9.9, §10.2). La règle porte sur ce que le site publie, pas sur ce qu'un visiteur saisit.

### 14.5 Contenu provisoire

Un texte provisoire est autorisé pendant la conception, à condition d'être **marqué comme
tel et centralisé**. Aucun faux-texte n'est livré — et en particulier, aucun faux slug :
§14.3 n'a pas de régime transitoire.

---

## 15. Mesure

### 15.1 Approche

Des métriques de fréquentation et de performance respectueuses de la vie privée.

### 15.2 Les événements qui portent une dimension

Un événement de copie de la commande d'installation, émis sans dimension, ne dit que « des
gens copient ». L'information utile est **quel moment les a convaincus**, qui est précisément
ce pour quoi la page est construite.

L'événement porte donc :

- un **emplacement**, identifiant stable et **indépendant de la position** ;
- une **variante**, disant ce qui a été copié — le produit se livre en deux paquets (§7.4),
  et copier l'un ou l'autre ne dit pas la même chose du lecteur.

Le numéro de scène n'est **jamais** une clé. Une page narrative gagne et perd des scènes, et
un événement indexé sur la position rendrait incomparables deux périodes de mesure portant
sur le même moment narratif. L'ordinal peut voyager en champ secondaire ; jamais comme
identifiant.

### 15.3 Le playground rapporte qu'on a mesuré, jamais ce qu'on a mesuré

Il est utile de savoir que des auteurs de thème se servent du mode de §10.2 : c'est ce qui
dit si le public que §4 déclare le mieux servi existe réellement.

Il n'est **jamais** acceptable de savoir quoi que ce soit de leur thème. Ni les mots, ni les
catégories, ni le nom du fichier, ni sa taille — une taille est une empreinte quand les
fichiers sont peu nombreux.

Ce qui peut être rapporté est la **forme de l'usage** : qu'un thème a été éprouvé, qu'il a
été refusé ou accepté, qu'une mesure a été demandée. Rien qui distingue un thème d'un autre.

§10.6 promet que le fichier ne quitte pas le navigateur ; un événement qui en dirait quelque
chose ferait de cette promesse un mensonge par un chemin détourné, et c'est précisément le
chemin qu'une mesure prend sans qu'on y pense.

### 15.4 Le parcours, et ce qu'il demande d'abord

Les mesures ci-dessus ne demandent leur accord à personne, parce qu'aucune ne sait
reconnaître un lecteur.

Le parcours — quelles scènes ont été lues, où l'on s'arrête, ce qui a été comparé avant de
se décider — demande une mesure capable de relier deux visites, donc capable de reconnaître.
**Elle est soumise au consentement**, et le consentement est un oui explicite : rien n'est
chargé, et rien n'est envoyé, avant qu'il soit donné.

Elle est une **voie séparée**. Les autres n'en dépendent jamais : un refus coûte un parcours
et jamais un total. C'est ce qui garde un taux lisible, puisque son dénominateur reste celui
de la voie que personne ne refuse.

Ce qu'elle mesure ne sert jamais la publicité. Cette exclusion est portée par la politique de
contenu, de sorte qu'un changement d'avis casse un contrôle au lieu d'être livré.

Le refus est offert aussi visiblement que l'accord, et se révise à tout moment.

---

## 16. Ce qui est vérifié, et par quoi

Une règle dont rien ne vérifie l'application est un vœu. Ce tableau est la liste des vœux
transformés en contrôles ; il est aussi la liste de ce qu'on saura *ne pas* avoir cassé.

| Règle | § | Contrôle |
|---|---|---|
| Les deux moitiés s'accordent sur le préfixe du playground | 12.2 | Vérification de l'artefact |
| Aucun script ni style en ligne non couvert par la politique | 13.2 | Vérification de l'artefact |
| Le playground démarre sous la politique de production, jusqu'à un slug | 13.2 | Test de bout en bout dédié, sur l'artefact publié |
| Tout slug affiché vient du moteur | 14.3 | Génération au build ; l'absence de slug casse le build |
| Tout chiffre sur un thème est compté | 14.2 | Génération au build ; aucun nombre littéral dans le contenu des pages de thème |
| Aucun thème publié n'est refusé par la validation | 14.4 | Chargement en intégration continue, règles ordinaires |
| Les options du playground et celles du CLI sont la même liste | 10.5 | Confrontation en intégration continue à la déclaration de la ligne de commande |
| Le site ne porte aucune seconde formulation d'un refus ou d'une mesure | 10.4 | Vérification des chaînes : aucune ne reproduit un message du moteur |
| Une commande copiable proposée pour ce qui n'est pas installable | 5.7 | Échec de build |
| Une commande d'installation qui tait la préversion d'un paquet qui en est une | 5.7, 7.4 | Échec de build |
| La route d'un thème est indexée sur son nom de fichier, jamais sur son intitulé | 7.6 | Vérification de l'artefact |
| Aucune description de thème que le thème ne déclare pas | 7.6, 14.2 | Génération au build ; une clé absente laisse la page muette |
| Le playground ne présente aucun contrôle comme une validation du sens | 10.2 | Vérification des chaînes |
| Aucun mot employé hors du vocabulaire de la bibliothèque | 5.9 | Vérification des chaînes, contre la surface publique |
| Aucune métrique de qualité affichée | 5.10 | Vérification des chaînes |
| Un composant présenté comme disponible sans version résoluble | 5.7 | Échec de build |
| Une chaîne affichée écrite en dur dans un composant | 6.2 | Échec de build |
| Un second dessin sur une page, ou un dessin qu'un texte touche | 5.8 | Test de navigateur, sur les pixels peints |
| Budgets de taille et de délai, playground compris | 13.3 | Mesuré à chaque build |
| Accessibilité | 13.4 | Audit automatisé |
| Liens internes | 7.2 | Vérification de l'artefact |
| Fraîcheur du comparatif | 11.7 | Avertissement de build au-delà du délai déclaré |
| Chaque axe porte son enseignement — question et explication | 11.4 | Échec de compilation : le type de l'axe les exige |
| Aucune note ne renvoie à ce qu'un autre rendu masque | 11.7 | Vérification des chaînes |
| Un emplacement de mesure indexé sur une position | 15.2 | Vérification de l'artefact, et refus du collecteur |
| Aucun événement du playground ne porte de donnée du thème | 15.3 | Vérification de l'artefact, et refus du collecteur |
| Rien n'atteint un tiers avant que le visiteur ait accepté | 15.4 | Test de navigateur dédié |
| La version reprise par la documentation et celle proposée à l'installation | 7.5 | Avertissement planifié, jamais un échec de publication |

Quand une règle de ce document n'a pas de ligne ici, c'est qu'elle repose sur l'attention.
Le dire est plus utile que de faire semblant.

---

## 17. Où vivent les décisions

Ce document porte les décisions **de conception du site**. Deux catégories vivent ailleurs,
et confondre les trois est ce qui fait vieillir un document comme celui-ci.

| | Où | Nature |
|---|---|---|
| **Décisions durables d'architecture** | `docs/for-maintainers/adr/` | Ce qu'un futur mainteneur remettra en cause : le choix d'hébergement, l'absence de script serveur, le préfixe plutôt que le sous-domaine, la langue unique, le pont vers la bibliothèque. Une décision, son contexte, ses conséquences, ses alternatives écartées |
| **Conception du site** | Ce document | La narration, les règles éditoriales, l'architecture de l'information, les principes |
| **Le travail à faire** | Le suivi de projet | Petit, fermable, daté |

Une quatrième catégorie existe et n'appartient pas à ce dépôt : **les décisions du
produit**. Pourquoi un adjectif est restreint par catégorie, pourquoi `common` est un socle,
pourquoi un refus dit tout d'un coup — tout cela vit dans le registre de décisions de la
bibliothèque, et ce document s'y réfère sans jamais le réécrire. Le site explique ces
décisions à un visiteur ; il n'en est pas l'auteur.

Une décision consignée ici et qui mérite de survivre à ce document migre vers
`docs/for-maintainers/adr/`. Une tâche qui apparaît ici est une erreur de rangement.

---

## 18. Le message

Le site doit être une vitrine de marque, une démonstration, **un outil réel pour l'auteur de
thème**, une réponse honnête à « pourquoi pas ce que j'utilise déjà », et une base durable
pour la documentation.

La page principale ne se limite pas à énumérer des fonctionnalités : elle fait vivre une
transformation, d'un tirage où tout peut accompagner tout vers un tirage où l'auteur a dit
ce qui va ensemble.

Trois règles traversent ce document et suffiraient à le résumer :

1. **Le site ne montre aucun slug qu'un thème réel ne peut pas produire** — sinon il fait
   une promesse à la place du produit.
2. **Rien de ce que le site affiche d'un thème n'est saisi à la main** — ni les slugs, ni les
   comptes, ni les marges, ni la prose d'un refus. Tout descend du moteur au moment du build,
   sinon la vitrine et le produit divergent, toujours.
3. **La comparaison dit du bien des autres** — et ce produit peut le prouver plutôt que
   l'affirmer, puisqu'il transporte leur vocabulaire sous leur licence.

> **You bring the words. slugger never draws a pair you didn't allow.**
