/*
Projet #1 Voting

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

    Votre smart contract doit définir les structures de données suivantes : 

    struct Voter {
    bool isRegistered;
    bool hasVoted;
    uint votedProposalId;
    }

    struct Proposal {
    string description;
    uint voteCount;
    }

    Votre smart contract doit définir une énumération qui gère les différents états d’un vote

    enum WorkflowStatus {
    RegisteringVoters,
    ProposalsRegistrationStarted,
    ProposalsRegistrationEnded,
    VotingSessionStarted,
    VotingSessionEnded,
    VotesTallied
    }

    Votre smart contract doit définir un uint winningProposalId qui représente l’id du gagnant ou une fonction getWinner qui retourne le gagnant.
    Votre smart contract doit importer le smart contract la librairie “Ownable” d’OpenZepplin.
    Votre smart contract doit définir les événements suivants : 

    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);
*/

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.17;

//déclaration des librairie externes
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol" ; 

contract Voting is Ownable {

    //###########################################################################################################
    // Librairie et héritage
    // le contrat herite de la librairie openZeppelin Ownable
    // Nous allons utiliser une fonction de cette librairie pour controler l'acces 
    // à certaines fonctions qui sont réservées à l'administrateur (owner du contrat)
    //###########################################################################################################


    //###########################################################################################################
    // declaration de la structure d'un votant
    // Elle comprend une description sous la forme d'un boolen 
    //###########################################################################################################
    struct Voter {
        address adressVotant;
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    //creation d'un tableau des votants basé sur la structure Voter
    Voter[] public tableauDesVotants ;

    //creation d'un entier qui va contenir le nombre de votants
    uint qteVoter ;  

    //###########################################################################################################
    //declaration de la structure d'une proposition de vote
    //Elle comprens une descritpion sous la forme d'une chaine et un compteur représentant le nombre de votes
    //###########################################################################################################
    struct Proposal {
        string description;
        uint voteCount;
    }

    Proposal[] public tableauProposition ;

    //creation d'un entier qui va contenir le nombre de proposition
    uint qteProposition ;  


    //###########################################################################################################
    //Events imposés
    //###########################################################################################################
    event ProposalRegistered(string proposition, uint proposalId);

    event VoterRegistered(address voterAddress); 

    event WorkflowStatusChange(uint WorkflowStatusPreviousStatus, uint WorkflowStatusNewStatus);
    
    event Voted (address voter, uint proposalId);

    event contratCree(address createur, uint statutVote);

    event VotantDejaAjoute(address createur, uint rang);

    //###########################################################################################################
    //statuts de vote imposés
    //###########################################################################################################
    enum WorkflowStatus {
    RegisteringVoters,
    ProposalsRegistrationStarted,
    ProposalsRegistrationEnded,
    VotingSessionStarted,
    VotingSessionEnded,
    VotesTallied
    }

    //on cree une instance de l'enumération 
    WorkflowStatus public StatutVote ;

    constructor(){
        //lors de la creation du contrat
        //on détermine que le statut est le premier de la liste
        StatutVote = WorkflowStatus.RegisteringVoters ; 

        address adminContrat = msg.sender ;
        emit contratCree(adminContrat , uint(StatutVote) ) ;
    }


    //########################################################
    // temps 1
    // ajoute les votants
    //########################################################

    function ajouteVotant(address adresseVotant) public  {

    //controle l'accès de cette fonction qu'à l'administrateur du contrat 
    //onlyOwner() ;

    //Vérifie que nous sommes bien en phase d'ajout de votants
    require( uint(StatutVote) > 0 , "Nous ne sommes plus en ajout de votant ") ;

    //vérifie que le votant n'est pas déjà enregistré
    qteVoter = tableauDesVotants.length ;

    bool isPresent ; 

    for (i=0 , i++ , i>qteVoter){
        if (tableauDesVotants[i].adresseVotant ==adresseVotant ) then { 
            isPresent = true ;
            //emet un event pour signaler ajout en doublon
            emit VotantDejaAjoute(adresseVotant ,i) ;
            }
    }

    require( isPresent, unicode "Ce votant exite déjà !") ;


    //vérifie que l'adresse est bien une adresse


    //cree le votant
    Voter memory nouveauVotant  ;
    nouveauVotant.adressVotant      = adresseVotant ;
    nouveauVotant.isRegistered      = true ;
    nouveauVotant.hasVoted          = false ;
    nouveauVotant.votedProposalId   = 0 ;
    
    //ajoute un votant
    tableauDesVotants.push(nouveauVotant)  ;

    //emet l'event de confirmation
    emit VoterRegistered(adresseVotant) ; 

    }




    function changePhaseVote() public returns(uint){

    //controle l'accès de cette fonction qu'à l'administrateur du contrat 
    //onlyOwner() ;


    if          ( uint(StatutVote) ==0 ) {
        StatutVote = WorkflowStatus.ProposalsRegistrationStarted ; 
    } else if   ( uint(StatutVote) ==1 ) {
        StatutVote = WorkflowStatus.ProposalsRegistrationEnded ; 
    } else if   ( uint(StatutVote) ==2 ) {
        StatutVote = WorkflowStatus.VotingSessionStarted ; 
    } else if   ( uint(StatutVote) ==3 ) {
        StatutVote = WorkflowStatus.VotingSessionEnded ; 
    } else if   ( uint(StatutVote) ==4 ) {
        StatutVote = WorkflowStatus.VotesTallied ; 
    }

    return uint(StatutVote);

    //statut et valeur
    //statut 0 : RegisteringVoters,
    //statut 1 : ProposalsRegistrationStarted,
    //statut 2 : ProposalsRegistrationEnded,
    //statut 3 : VotingSessionStarted,
    //statut 4 : VotingSessionEnded,
    //statut 5 : VotesTallied
    }


/*



    //########################################################
    //temps 2
    // ajoute les propositions
    //########################################################

    function ajouteProposition(string nouvelleProposition) public   {

        //l'accès de cette fonction est ouverte à tous les votant et à l'administrateur 
        
        //

        //vérifie que l'on est bien dans la phase de l'ajout des proposition
        

        //verifie que la proposition n'a pas déjà été proposée
        qteProposition = proposition.length;   


        //

        //ajoute la nouvelle proposition au tableau
        proposition[].push(nouvelleProposition);

        //met à jour le nombre de propositions
        qteProposition = proposition[].length;

        //avant d'emettre l'event accompagné de l'index de la proposition
        //on effectue un calcul pour déterminer l'id (proposition 1 = ID 0)
        uint indexProposition = qteProposition-1 ;

        //emet un evenement suite à l'ajout de proposition
        // en précisant que le nom de la proposition et son ID
        emit ProposalRegistered(nouvelleProposition, indexProposition);


    }
*/

}
