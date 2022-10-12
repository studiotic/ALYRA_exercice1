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
        address     adressDuVotant;
        bool        isRegistered;
        bool        hasVoted;
        uint        votedProposalId;
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
        string description ;
        uint voteCount ;
    }

    Proposal[] public tableauProposition ;

    //creation d'un entier qui va contenir le nombre de proposition
    uint qteProposition ;  





    //###########################################################################################################
    //Events imposés
    //###########################################################################################################

    //sujet : deploiement contrat
    event contratCree(address createur, uint statutVote);
    
    //sujet : votants
    event VoterRegistered(address voterAddress); 
    event VotantDejaAjoute(address createur, uint rang);
    event VotantNonTrouve(address createur);
    event VotantDejaVote(address createur , uint sonVote);
    event dernierVotantSupprime(address votantSupprime, uint QteVotantFinal);

    //sujet : propositions
    event ProposalRegistered(string proposition, uint proposalId);
    event propositionDejaAjoute(string propositionBis, uint rang);
    event dernierPropositionSupprime(address votantSupprime, uint QteVotantFinal);

    //sujet : phase du vote
    event WorkflowStatusChange(uint WorkflowStatusPreviousStatus, uint WorkflowStatusNewStatus);
    
    //sujet : vote
    event Voted (address voter, uint proposalId);

    

    

    

    

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



    //###########################################################################################################
    //déclaration du constructeur et de son import
    //###########################################################################################################
    constructor()  Ownable() {

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

    function ajouteVotant(address adresseNouveauVotant) public {

        //controle l'accès de cette fonction qu'à l'administrateur du contrat 
         _checkOwner() ;

        //Vérifie que nous sommes bien en phase d'ajout de votants
        require( uint(StatutVote) == 0 , "Nous ne sommes plus en ajout de votant ") ;

        //vérifie que le votant n'est pas déjà enregistré
        qteVoter = tableauDesVotants.length ;

        bool isPresent ; 

            for (uint8 i=0 ; i > qteVoter; i++  ){

                if (tableauDesVotants[i].adressDuVotant == adresseNouveauVotant ) { 
                //le votant existe deja
                isPresent = true ;

                //emet un event pour signaler ajout en doublon
                emit VotantDejaAjoute(adresseNouveauVotant , i) ;
                }

            }
   

        require( isPresent == false ,  "Ce votant exite deja !") ;


        //vérifie que l'adresse est bien une adresse


        //cree le votant
        Voter memory nouveauVotant  ;
        nouveauVotant.adressDuVotant    = adresseNouveauVotant ;
        nouveauVotant.isRegistered      = true ;
        nouveauVotant.hasVoted          = false ;
        nouveauVotant.votedProposalId   = 0 ;
        
        //ajoute un votant
        tableauDesVotants.push(nouveauVotant)  ;

        //emet l'event de confirmation
        emit VoterRegistered(adresseNouveauVotant) ; 

    }


    //fonction qui renvoie le nombre de proposition
    function annuleDernierAjoutVotant()  public view {

        //controle l'accès de cette fonction qu'à l'administrateur du contrat 
         _checkOwner() ;

        //Vérifie que nous sommes bien en phase d'ajout de votants
        require( uint(StatutVote) == 0 , "Nous ne sommes pas en phase d'ajout de votants.") ;

        //ajoute un votant
        tableauDesVotants.pop  ; 

    }


    //########################################################
    //temps 2
    // Change la phase de vote
    //########################################################

    function changePhaseVote() public returns(uint) {

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

    //statut et valeur pour mémoire
    //statut 0 : RegisteringVoters,
    //statut 1 : ProposalsRegistrationStarted,
    //statut 2 : ProposalsRegistrationEnded,
    //statut 3 : VotingSessionStarted,
    //statut 4 : VotingSessionEnded,
    //statut 5 : VotesTallied

    }





    //########################################################
    //temps 3
    // ajoute les propositions
    //########################################################


    //fonction qui renvoie le nombre de proposition
    function CombienProposition() public returns(uint){

        //evalue la quantité de propositions
        qteProposition = tableauProposition.length;  

        //renvoie le nombre de propositions
        return qteProposition;
    }




    function ajouteProposition(string memory nouvelleProposition) public   {

        //l'accès de cette fonction est ouverte à tous les votant et à l'administrateur 
        //donc pas de controle

        //vérifie que l'on est bien dans la phase de l'ajout des proposition
        require( uint(StatutVote) == 1 , "Nous ne sommes pas en phase d'ajout de votant") ;

        //verifie que la proposition n'a pas déjà été proposée
        qteProposition = tableauProposition.length;   


        //cree une instance de la structure proposition
        Proposal memory uneNouvelleProposition  ;

        //ajoute l anouvelle proposition à l'instance de structure
        uneNouvelleProposition.description    = nouvelleProposition ;
    

        //ajoute une proposition au tabaleau des proposiitons
        tableauProposition.push(uneNouvelleProposition)  ;

        //met à jour le nombre de propositions
        qteProposition = tableauProposition.length;

        //avant d'emettre l'event accompagné de l'index de la proposition
        //on effectue un calcul pour déterminer l'id (proposition 1 = ID 0)
        uint indexProposition = qteProposition-1 ;

        //emet un evenement suite à l'ajout de proposition
        // en précisant que le nom de la proposition et son ID
        emit ProposalRegistered(nouvelleProposition, indexProposition);

    }


    //########################################################
    //  temps 4
    //  LE vote
    //########################################################

        function jeVote(address adresseVotant, uint ChoixVote1N ) public {

        //l'accès de cette fonction est ouverte à tous les votant et à l'administrateur 
        //donc pas de controle

        //vérifie que l'on est bien dans la phase de vote
        require( uint(StatutVote) == 3  , "Nous ne sommes pas en phase de vote") ;

        //vérifie que choix est autorisé
        qteProposition = tableauProposition.length ;

        //vérifie que le choix du votant est encadré dans les valeurs attendues
        require( qteProposition>0 , "Il n'y a aucune proposition de vote") ;

        //vérifie que le choix du votant est encadré dans les valeurs attendues
        require( (ChoixVote1N <= qteProposition) && (ChoixVote1N>0) , "Ce choix de vote est non valable") ;

 
        //retrouve le votant
        qteVoter = tableauDesVotants.length ;
        uint rangVotant = qteVoter-1 ;


        bool isPresent  = false ; //existe t'il dans le tableau des votant
        bool hasVoted   = false ;  //a til deja voté ?

        //passe en revue le tableau des votants pour retrouver le 
        for (uint8 i=0 ; i > rangVotant; i++  ){

                if (tableauDesVotants[i].adressDuVotant == adresseVotant ) { 

                    //le votant existe et a été trouvé
                    isPresent = true ;

                    if (tableauDesVotants[i].hasVoted = true ) {
                        hasVoted = true; 
                    }


                    //test si a déjà voté
                    if (hasVoted == true ) {
                        //emet un event pour signaler ajout en doublon
                        emit VotantDejaVote(adresseVotant , tableauDesVotants[i].votedProposalId) ;
                    }

                    //sort si ce votant à déjà voté
                    require(hasVoted == false ,"Ce votant a deja vote" ) ; 

                    //procede au vote en complétant le tableau
                    tableauDesVotants[i].votedProposalId = ChoixVote1N ;
                    tableauDesVotants[i].hasVoted = true ;



                } else {

                    //votant non trouvé dans tableau des votants
                    //emet un event pour signaler ajout en doublon
                    emit VotantNonTrouve(adresseVotant) ;
                   
                }

            }



        }





}



  
