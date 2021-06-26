# Diamond
Etude du prix des diamants à l'aide du logiciel SAS et R

Le but de projet est d’analyser un jeu de données et de construire un modèle
de régression. La démarche sera donc la suivante :
1. analyse descriptive du jeu de données : taille du jeu de données, type des
variables à disposition, observations manquantes/aberrantes...
2. analyse des variables du jeu de données : traitements univariés (répartition, adéquation à une loi théorique...)
3. analyse de la liaison entre la variable que l’on veut expliquer et les autres
variables du jeu de données
4. construction de modèles de régressions simples
5. construction d’un modèle de régression multiple
6. si possible, une ACP suivie d’une CAH
Les parties 4 et 5 sont à faire en SAS, la partie 6 en R, il n’y a pas de contrainte
pour les parties 1 à 3.


L’objectif est construire un modèle de valorisation raisonnable pour les diamants
basé sur les données relatives à leur poids (en carats), leur couleur(soit D, E, F,
G, H ou I) et de clarté (soit SI, VVS1, VVS2, VS1 ou VS2). La valeur relative
des différentes qualités est particulièrement intéressante, ainsi que l’impact potentiel de l’organisme de certification (soit GIA, IGI ou DRH).
Par ailleurs, pour estimer correctement le modèle, il faudra transformer la variable, ce qui implique de la transformer en sens inverse pour juger de la qualité
du modèle.
Ce sujet permet des prolongations, car on dispose de jeux de données très importants, ce qui permet l’emploi de méthodes non-paramétriques performantes
