# ALYRA
Exercice 1 
Sébastien HOFF

Promotion Rinbeky


Principe de fonctionnement : 

Ce contrat permet de gérer un vote sur un nombre important de votants et de propositions
Ce contrat gère également un second tour en cas d'un ou plusieurs exaequos au premier tour


Mode d'emploi
##############

1) déployer le contrat


2) saisir les adresse Ethereum des votants via la fonction ajoutVotant.
 
Un controle d'unicité est appliqué à toute nouvelle proposition de votant.

En cas d'erreur de saisie la fonction annuleDernierAjoutvotant(orange) permet d'effacer la dernière entrée 

Pour connaitre le nombre de votants utiliser la fonction getVotant(bleu)



3) pour passer à l'étape suivante du vote cliquer sur la fonction nextStep (orange). 

A tout moment on peut connaitre l'etape du vote en cours via la fonction getEtape (bleu) qui retourne le numéro de l'étape de 0 à 5 et le libellé de l'etape

J'ai suivi à la lettre l'enum des phases du vote imposée dans l'énoncé. 

Dans mon analyse de la solution, j'aurai limité les phases à :
étape 0 : saisie des votants 
etape 1 : saisie des propositions 
etape 2 : vote 
etape 3 : dépouillement 


4) Saisir les propositions de vote en complétant le champs ajoutProposition.

Un controle d'unicité est appliqué à toute nouvelle proposition.

En cas d'erreur de saisie la fonction annuleDerniereProposition(orange) permet d'effacer la dernière entrée

Pour connaitre le nombre de propositions utiliser la fonction getPropositions(bleu). 

En cas de second tour cette fonction renvera toujours le nombre de propositions totales car nous conservons les archives de tous les votes et des résultats consolidés au niveau des propositions permettant le controle a posteriori

5) pour passer à l'étape suivante du vote cliquer sur la fonction nextStep (orange). 

6) l'étape 3 VotingSession started , est le debut de la session de vote.

Compléter le vote en saisissant le numéro de la proposition : de 1 à N

Un système controle l'unicité du vote, la validité des choix de vote et que le votant est whitelisté et correspond au msg.sender

Pour obtenir de l'aide sur le choix des propositions, la fonction getlibelleProposition affiche le numéro de la proposition et son intitulé.(en phase 5 de dépouillement , cette fonction renvoie également les résultats)

7) une fois que vous avez clos l'etape du vote, vous pouvez cliquer sur la fonction dépouillement

on aurait pu lancer automatiquement le dépouillement via la fonction nextstep mais j'ai préféré que l'administrateur garde le controle des phases

8) le dépouillement est lancé via la fonction éponyme dépouillement une fois en phase 5

9) la fonction getWinner renvoie le nom de la proposition gagnante et son score en nombre de voix. 

En cas de resultats exaequos. la fonction annonce la necessité d'un second tour si des propositions totalisent le meme nombre de voix


Cas des resultats exaequos :

10) le second tour se déroule de la manière suivant : 

- on prepare les données pour le second tour via le bouton LanceSecondTour
- on repasse automatiquement en phase 3 de vote

Chaque votant enregistré peut revoter pour les propositions qui participent au second tour.

on controle que le choix est autorisé et que le votant est bien enregistré et qu'il n'a pas encore voté au second tour.

8) pour passer à l'étape suivante du vote cliquer sur la fonction nextStep (orange). 

9) le dépouillement est lancé via la fonction eponyme depouillement une fois rendu en phase 5

10) la fonction getWinner renvoie le nom de la proposition gagnante et son score en nombre de voix. 
En cas de resultats exaequos le cas n'est pas traité.


//fonctions supplémentaires

getLibellé : permet à tout moment pour le votant de connaitre quelle proposition correspond à quel numéro

getResults : permet de connaitre apres le dépouillement (phase 5) les résultats en cycle pour chaque propositions. chaque clic passe à la proposition suivante

Une fonction de reset aurait pu etre développé simplement mais n'a pas été demandée dans l'enoncé. 

C'est une décision d'ethique personnelle car elle permettait à l'administrateur de supprimer les résultats d'un vote ce qui va un peu à l'encontre de l'éternité des données sur la blockchain et la possibilité pour quiconque de controler les résultats a posteriori. 

Autre évolution possible
Rajouter une structure pour gérer les campagnes de votes grace à un idVote permettant au contrat de gérer plusieurs campagnes de votes en parallèle.

################
IMPORTANT
################
Pour le correcteur et uniquement dans le cadre de cet exercice pour faciliter la correction. 
Un jeu de données est mis à disposition pour illustrer le fonctionnement avec des données de 7 votants pour un vote avec 2 aexequos au premier tour et  1 gagnant au second tour.

mode operatoire : après le deploiement du contrat cliquer sur dataGenerator(orange) 
vous retrouvez en statut 3 VotingSession started
reprennez à l'étape 5 ci-dessus

Merci.








###########################
Enoncé du devoir: 
###########################

Un smart contract de vote peut être simple ou complexe, selon les exigences des élections que vous souhaitez soutenir. 

Le vote peut porter sur un petit nombre de propositions (ou de candidats) présélectionnées, 
ou sur un nombre potentiellement important de propositions suggérées de manière dynamique par les électeurs eux-mêmes.

Dans ce cadres, vous allez écrire un smart contract de vote pour une petite organisation. 

Les électeurs, que l'organisation connaît tous, sont inscrits sur une liste blanche (whitelist) grâce à leur adresse Ethereum, 
peuvent soumettre de nouvelles propositions lors d'une session d'enregistrement des propositions, 
et peuvent voter sur les propositions lors de la session de vote.

✔️ Le vote n'est pas secret pour les utilisateurs ajoutés à la Whitelist
✔️ Chaque électeur peut voir les votes des autres
✔️ Le gagnant est déterminé à la majorité simple
✔️ La proposition qui obtient le plus de voix l'emporte.


👉 Le processus de vote :  

Voici le déroulement de l'ensemble du processus de vote :

    L'administrateur du vote enregistre une liste blanche d'électeurs identifiés par leur adresse Ethereum.
    L'administrateur du vote commence la session d'enregistrement de la proposition.
    Les électeurs inscrits sont autorisés à enregistrer leurs propositions pendant que la session d'enregistrement est active.
    L'administrateur de vote met fin à la session d'enregistrement des propositions.
    L'administrateur du vote commence la session de vote.
    Les électeurs inscrits votent pour leur proposition préférée.
    L'administrateur du vote met fin à la session de vote.
    L'administrateur du vote comptabilise les votes.
    Tout le monde peut vérifier les derniers détails de la proposition gagnante.

 

👉 Les recommandations et exigences :

    👉 Votre smart contract doit s’appeler “Voting”. 

    👉 Votre smart contract doit utiliser la dernière version du compilateur.

    👉 L’administrateur est celui qui va déployer le smart contract. 

      👉 Votre smart contract doit définir les structures de données suivantes : 

      👉 struct Voter {
    bool isRegistered;
    bool hasVoted;
    uint votedProposalId;
    }

      👉 struct Proposal {
    string description;
    uint voteCount;
    }

      👉 Votre smart contract doit définir une énumération qui gère les différents états d’un vote

    enum WorkflowStatus {
    RegisteringVoters,
    ProposalsRegistrationStarted,
    ProposalsRegistrationEnded,
    VotingSessionStarted,
    VotingSessionEnded,
    VotesTallied
    }

      👉 Votre smart contract doit définir un uint winningProposalId qui représente l’id du gagnant ou une fonction getWinner qui retourne le gagnant.
      👉 Votre smart contract doit importer le smart contract la librairie “Ownable” d’OpenZepplin.
    
    Votre smart contract doit définir les événements suivants : 

    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);
	
