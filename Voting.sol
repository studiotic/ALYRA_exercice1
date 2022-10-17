/*
Projet #1 Voting
Sébastien HOFF
ALYRA Promotion Rinkeby

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

//déclaration des librairie externes
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol" ; 

contract Voting is Ownable {

    //###########################################################################################################
    // Librairie et héritage
    // le contrat herite de la librairie openZeppelin Ownable
    // Nous allons utiliser une fonction de cette librairie pour controler l'acces 
    // à certaines fonctions qui sont réservées à l'administrateur (owner du contrat) via l'appel de la function onlyOwner
    //###########################################################################################################


    //###########################################################################################################
    // declaration de la structure d'un votant
    // Elle comprend une description sous la forme d'un boolen 
    // elle intègre le vote pour les deux tour en cas d'exaequo
    //###########################################################################################################
    struct Voter {
        address     adressDuVotant;
        bool        isRegistered;
        bool        hasVoted1;
        bool        hasVoted2;
        uint        votedProposalId1; //de 1 à n pour le tour 1
        uint        votedProposalId2; //de 1 à n pour le tour 2
    } 

    //creation d'un tableau des votants basé sur la structure Voter
    Voter[] public tableauDesVotants ;

    // variable qui va contenir le numero de la proposition gagnante
    // l'index du tableau des propositions sera numeroPropositionGagnante--
    uint numeroPropositionGagnante ; // de 1 à n 
    uint qteVoixGagnant ;           // contient le nom de voix du gagnant


    //est vrai si on est dans le second tour
    // déclare vrai par le dépouillement du premier tour lors de la consolidation des résultats
    bool isSecondTour  ; // si exaequo
    bool isSecondTourTermine ; //devient vrai à l'issue du depouillement du second tour
    bool isDepouillementT1ok ; // est vrai si le depuillement du tour1 a eu lieu 
    bool isDepouillementT2ok ; // est vrai si le depuillement du tour1 a eu lieu 
    bool isPretPourTour2 ; //est vrai quand a été excuté le script de lancement du tour 2
    //cyle des resultats
    uint8 cycleResult ; 

    //###########################################################################################################
    // declaration de la structure d'une proposition de vote
    // Elle comprens une descritpion sous la forme d'une chaine et un compteur représentant le nombre de votes
    // dans le cas d'un deuxième tour les résultat du premier tour sont conservés et stockés dans le champs voteCountTour1
    // la variable isTour2 est vrai si la proposition participe au tour2
    //###########################################################################################################
    struct Proposal {
        string laProposition ;
        uint voteCount ;
        bool isGagnant ;

        //ne sert que pour le second tour
        uint voteCountTour1 ; //
        bool isTour2 ;

    }

    Proposal[] public tableauProposition ;






    //###########################################################################################################
    //Events imposés
    //###########################################################################################################

    //sujet : deploiement contrat
    event contratCree(address createur, uint statutVote);
    
    //sujet : votants
    event VoterRegistered(address voterAddress); 
    event VotantDejaAjoute(address createur, uint rang);
    event VotantInconnu(address votantInconnu);
    event VotantDejaVote(address createur , uint sonVote);
    event dernierVotantSupprime(address votantSupprime, uint QteVotantFinal);

    //sujet : propositions
    event ProposalRegistered(uint proposalId, string proposition );
    event propositionDejaExistante(string propositionBis);
    event dernierPropositionSupprime(string propositionBis, uint QtePropositionRestant);
    event ProposalRegistered2EmeTour(uint proposalId, string proposition );
    //sujet : phase du vote
    event WorkflowStatusChange(uint WorkflowStatusPreviousStatus, uint WorkflowStatusNewStatus);
    
    //sujet : vote
    event Voted (address voter, uint proposalId);

    //sujet : depouillement
    event depouillementOk (uint propositionGagnante, string proposition, uint voteCumul );

    //sujet : second tour
    event debutSecondTour (string debut2Tour);

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
    WorkflowStatus private StatutVote ;




    //###########################################################################################################
    //déclaration du constructeur et de son import
    //###########################################################################################################
constructor()   {

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

function ajouteVotant(address adresseNouveauVotant) public onlyOwner {


          
        //controle l'accès de cette fonction qu'à l'administrateur du contrat via le modifier hérité de Ownable
        
        //creation d'un entier qui va contenir le nombre de votants
        uint qteVoter ;

        //Vérifie que nous sommes bien en phase d'ajout de votants
        require( uint(StatutVote) == 0 , "Nous ne sommes plus en ajout de votant ") ;

        //vérifie que le votant n'est pas déjà enregistré
        qteVoter = tableauDesVotants.length ;

        bool isPresent ; 

            for (uint8 i=0 ; i < qteVoter; i++  ){

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
        nouveauVotant.hasVoted1         = false ;
        nouveauVotant.hasVoted2         = false ;
        nouveauVotant.votedProposalId1  = 0 ;
        nouveauVotant.votedProposalId2  = 0 ;

        //ajoute un votant
        tableauDesVotants.push(nouveauVotant)  ;

        //emet l'event de confirmation
        emit VoterRegistered(adresseNouveauVotant) ; 
      
    }


    //fonction qui annule l'ajout du dernier votant
function effaceDernierAjoutVotant()  public  onlyOwner {

        
        //controle l'accès de cette fonction qu'à l'administrateur du contrat 

        //Vérifie que nous sommes bien en phase d'ajout de votants
        require( uint(StatutVote) == 0 , "Nous ne sommes pas en phase d'ajout de votants.") ;

        //evalue le dernier votant ajouté etl aquantité de votant
        uint QteVotant = tableauDesVotants.length;
        address adresseDernierVotant = tableauDesVotants[QteVotant-1].adressDuVotant ;

        //controle qu'il y a au moins un votant dans le tableau des votants
        if (QteVotant > 0){

        //supprime le dernier ajouté
        tableauDesVotants.pop()  ; 
        QteVotant = tableauDesVotants.length;

        emit dernierVotantSupprime(adresseDernierVotant,QteVotant );
      
        }
        
    }






    //getter du nombre de votants enregistrés
function getVotants() public view returns(uint votants){
        return(tableauDesVotants.length) ;
    }


    //getter du nombre de votants enregistrés
function getVoteVotant(address leVotant) public view returns(string memory libelle, uint vote1, uint vote2){

        uint qtevotants =  tableauDesVotants.length ; 

        //parcours la table des votants à la recherche du votant et de ses votes
        for (uint i = 0 ; i < qtevotants ; i++ ){

           if (tableauDesVotants[i].adressDuVotant == leVotant){
                return("Votant enregistre votes : " , tableauDesVotants[i].votedProposalId1 , tableauDesVotants[i].votedProposalId2 ) ;
           }

        }

        return("Votant non trouve", 0, 0 ) ;
    }






    //########################################################
    // temps 2
    // Change la phase de vote
    //########################################################

function nextStep() public onlyOwner  {

    //controle l'accès de cette fonction qu'à l'administrateur du contrat 
    //onlyOwner() ;
    uint  etapeVote =  uint(StatutVote) ;

    if          ( etapeVote ==0 ) {
        //controle que l'on a au moins 1 votant
        require( tableauDesVotants.length >0 , unicode"Il n'y a pas de votant");
        StatutVote = WorkflowStatus.ProposalsRegistrationStarted ; 

    } else if   ( etapeVote ==1 ) {
        //controle que l'on a au moins 1 proposition
        require( tableauProposition.length >0 , unicode"Il n'y a pas de proposition");
        StatutVote = WorkflowStatus.ProposalsRegistrationEnded ; 

    } else if   ( etapeVote ==2 ) {
        StatutVote = WorkflowStatus.VotingSessionStarted ; 
    } else if   ( etapeVote ==3 ) {
        StatutVote = WorkflowStatus.VotingSessionEnded ; 
    } else if   ( etapeVote ==4 ) {
        StatutVote = WorkflowStatus.VotesTallied ; 
    }  

    emit WorkflowStatusChange(etapeVote, uint(StatutVote));

    //statut du vote  et valeur pour mémoire
    //statut 0 : RegisteringVoters,
    //statut 1 : ProposalsRegistrationStarted,
    //statut 2 : ProposalsRegistrationEnded,
    //statut 3 : VotingSessionStarted,
    //statut 4 : VotingSessionEnded,
    //statut 5 : VotesTallied

    }


    //fonction getter qui renvoie l'etape
function getEtape() public view returns(uint phase , string memory etape){

        //evalue l'etat du vote
        uint  etapeVote =  uint(StatutVote) ;
        string memory monEtape ; 

        if      (etapeVote==0) {monEtape ="RegisteringVoters" ;}
        else if (etapeVote==1) {monEtape ="ProposalsRegistrationStarted" ;}
        else if (etapeVote==2) {monEtape ="ProposalsRegistrationEnded" ;}
        else if (etapeVote==3) {monEtape ="VotingSessionStarted" ;}
        else if (etapeVote==4) {monEtape ="VotingSessionEnded" ;}
        else if (etapeVote==5) {monEtape ="VotesTallied" ;}
        else                   {monEtape ="autre" ;}

        //statut 0 : RegisteringVoters,
        //statut 1 : ProposalsRegistrationStarted,
        //statut 2 : ProposalsRegistrationEnded,
        //statut 3 : VotingSessionStarted,
        //statut 4 : VotingSessionEnded,
        //statut 5 : VotesTallied


        //renvoie l'etape
        return (etapeVote,monEtape);
      
    }



    //########################################################
    //temps 3
    // ajoute les propositions
    // note pour le correcteur

    // les propositions sont numérotées ainsi : 
    // proposition 1 xxxxxxxx rang 0
    // proposition 2 xxxxxxxx rang 1
    // proposition 3 xxxxxxxx rang 2
    //########################################################


    //fonction getter qui renvoie le nombre de propositions
function getPropositions() public view returns(uint){


        //creation d'un entier local qui va contenir le nombre de proposition
        uint qteProposition = tableauProposition.length;

        //renvoie le nombre de propositions
        return qteProposition;

    
    }


function ajouteProposition(string memory nouvelleProposition) public   {


        //l'accès de cette fonction est ouverte à tous les votant(verif2) et à l'administrateur (verif1)
    
        //vérification 1
        //vérifie que l'on est bien dans la phase de l'ajout des proposition
        require( uint(StatutVote) == 1 , "Nous ne sommes pas en phase d'ajout de proposition") ;


        //vérification 2
        //vérifie bien que le soumissionnaire est bien dans la whitelist ou le owner du contrat

        //creation d'un entier qui va contenir le nombre de votants
        uint qteVoter = tableauDesVotants.length ;

        //creation d'un bool qui va controler le clearing
        bool isClear = false ;

        //test si le soumissionnaire est dans la liste des votants
        for (uint8 i=0 ; i < qteVoter; i++  ){

            if (tableauDesVotants[i].adressDuVotant == msg.sender) { 
                //le sender est votant et à est donc autorisé à déposer une proposition 
                isClear = true ;
            }

        }

   
        //test si le soumissionnaire est le owner
        if (Ownable.owner() ==  msg.sender){
            //le sender est le owner  
             isClear = true ;
        }

        //kill si il est pas clearé
        require( isClear == true ,  unicode"Vous n'etes pas habilité à modifier la liste des propositions") ;

        //vérification 3
        //verifie que la proposition n'a pas déjà été proposée et stockee dans le tableau

        //creation d'un entier qui va contenir le nombre de proposition
        uint qteProposition = getPropositions() ;   

        //creation d'un bool qui va controler le clearing
        bool isDejaPresent = false ;



       //verifie que la proposition n'a pas déjà été proposée et stockee dans le tableau
       for (uint i =0 ; i < qteProposition ; i++ ){

           if (  keccak256(abi.encodePacked(tableauProposition[i].laProposition)) == keccak256(abi.encodePacked(nouvelleProposition )) ){

               //la proposition existe deja
                isDejaPresent = true ;

                //on emet l'event avant le require
                emit propositionDejaExistante(nouvelleProposition) ; 

                require(isDejaPresent == false , unicode"Cette proposition existe déjà" );
     
           }

       }

        //les controles sont passés et ok
        //on ajoute la proposition

        //cree une instance de la structure proposition
        Proposal memory uneNouvelleProposition  ;

        //ajoute la nouvelle proposition à l'instance de structure
        uneNouvelleProposition.laProposition    = nouvelleProposition ;
    
        //ajoute une proposition au tabaleau des proposiitons
        tableauProposition.push(uneNouvelleProposition)  ;

        //met à jour le nombre de propositions
        qteProposition = tableauProposition.length;

        //avant d'emettre l'event accompagné de l'index de la proposition
        //on effectue un calcul pour déterminer l'id (proposition 1 = ID 0)
        uint indexProposition = qteProposition-1 ;

        //emet un evenement suite à l'ajout de proposition
        // en précisant que le nom de la proposition et son ID
        emit ProposalRegistered( indexProposition, nouvelleProposition);

    }


function effaceDerniereProposition() public onlyOwner{

        uint qtePropositions = tableauProposition.length;

        require (qtePropositions > 0 , unicode"Il n'y a pas de proposition à supprimer");

        string memory nomPropositionSupprimer = tableauProposition[qtePropositions-1].laProposition ;

        //l'accès de cette fonction est réservée à l'administrateur 
        //elle permet de supprimer la dernière proposition ajoutée
    
        //vérification 1
        //vérifie que l'on est bien dans la phase de l'ajout des proposition
        require( uint(StatutVote) == 1 , "Nous ne sommes pas en phase d'ajout de proposition") ;

        //efface la dernière entrée au tableau des propositions
        tableauProposition.pop();

        //emet un evenement suite à la suppression de la proposition
        // en précisant que le nom de la proposition et son ID
        emit dernierPropositionSupprime(nomPropositionSupprimer, qtePropositions-1);

    }

function getLibelleProposition(uint rangProposition) public  returns(string memory proposition, uint Tour1 , uint Tour2  ){
   

   require ( rangProposition > 0 && rangProposition<= tableauProposition.length, "Aucune proposition avec ces criteres." ) ;

    uint qteVoteT1 =0  ; 
    uint qteVoteT2 =0  ;

    //ne présente le total que si l'etape du vote est dépouillement (5)
   




    if   ( uint(StatutVote) == 5 ) {

        if ( (isSecondTour == true ) && (isSecondTourTermine = true) ){
             
            //second tour terminé
            qteVoteT2 = tableauProposition[rangProposition-1].voteCount ;
            qteVoteT1 = tableauProposition[rangProposition-1].voteCountTour1 ;
            
        } else  if ( (isSecondTour == true ) && (isSecondTourTermine = false )){
            
            //second tour mais non terminé
            qteVoteT2 = tableauProposition[rangProposition-1].voteCount ;
            qteVoteT1 = tableauProposition[rangProposition-1].voteCountTour1 ;
            
        } else  if ( isSecondTour == false){
            
            //second tour mais non terminé
            qteVoteT1 = tableauProposition[rangProposition-1].voteCount ;
            qteVoteT2 = 0 ;
            
           
        }
 
    } else if ( ( uint(StatutVote) == 5 ) && (isSecondTour == true ) && (isSecondTourTermine = false)){
        //on autorise lors du vote du second tour de voir le resultat du premier tour car il est connu de tous
        qteVoteT1 = tableauProposition[rangProposition-1].voteCountTour1 ;
        qteVoteT2 = 0 ;
    }
   
    return( tableauProposition[rangProposition-1].laProposition, qteVoteT1 , qteVoteT2 ) ;
    
    }







    //########################################################
    //  temps 4
    // LE vote
    // pour mémoire
    // les propositions sont numérotées ainsi : 
    // proposition 1 xxxxxxxx index 0  => valeur de vote attendue = 1
    // proposition 2 xxxxxxxx index 1  => valeur de vote attendue = 2
    // proposition 3 xxxxxxxx index 2  => valeur de vote attendue = 3
    // le vote est toujours supérieur à 0. Il n'y a pas 
    // on aurait pu imaginer un vote blanc à 0 ou à 255
    // mais le traitement ne tient compte que des exprimés
    // dans le cas du tour 2 on ne prend que les propositions qui sont elliginle au tour 2
    //########################################################

function Vote( uint8 ChoixVote1N ) public {

        //l'accès de cette fonction est ouverte à tous les votant et à l'administrateur si il est dans la liste des votants
    

        //vérification 1
        //vérifie que l'on est bien dans la phase de vote
        require( uint(StatutVote) == 3  , "Nous ne sommes pas en phase de vote") ;


        //verification 2
        //on vérifie que le votant (msg.sender) est bien dans la liste des votant et n'a pas voté

        //creation d'un entier qui va contenir le nombre de votants
        uint qteVoter = tableauDesVotants.length ; 

        //retrouve le votant
        uint rangMax = qteVoter-1 ;
        bool isWhiteListe ; 
        uint rangVotant ;

        //passe en revue le tableau des votants pour vérifier 2 conditons (optimisation du gas)
        // le msg.sender est dans la liste et il n'a pas encore voté

        for (uint i=0 ; i < rangMax; i++  ){

            if ( isSecondTour == false){

                //tour1
                if ((tableauDesVotants[i].adressDuVotant == msg.sender) && (tableauDesVotants[i].hasVoted1 == false)  ) {
                
                    //est whitelisté
                    isWhiteListe = true ;
                    rangVotant = i ; 
                }

            }else{

                //tour 2
                if ((tableauDesVotants[i].adressDuVotant == msg.sender) && (tableauDesVotants[i].hasVoted2 == false)  ) {
                    //est whitelisté
                    isWhiteListe = true ;
                    rangVotant = i ; 
                }

            }    

        }


        //si il est non whitelisté on envoie l'event avant le kill du require
        //on economise du gas en couplant le test car on parcours le array potentiellement intégralement
        if (isWhiteListe == false){
            emit VotantInconnu(msg.sender);
        }
       
       //bloque ni non clearé
        require (isWhiteListe == true , unicode"Votant ayant déjà voté ou inconnu") ;



        //vérification 3
        //vérifie que choix est autorisé
        //c'est à dire que il y a au moins une proposition
        //que le choix du votant est bien dans les propositions

   

       //creation d'un entier qui va contenir le nombre de propositions
        uint qteProposition = tableauProposition.length ;  

        //vérifie que le choix du votant est encadré dans les valeurs attendues
        //
        require( qteProposition > 0 , "Il n'y a aucune proposition de vote") ;

        //vérifie que le choix du votant est encadré dans les valeurs attendues pour le tour 1
        require(  (ChoixVote1N>0) && (ChoixVote1N <= qteProposition)  , "Ce choix de vote est non valable") ;

        //on verifie que le choix est bien dans la liste des propositions attendues pour le tour 2
        if ( isSecondTour == true){
            require(  (ChoixVote1N > 0) && (tableauProposition[ChoixVote1N-1].isTour2 == true ) , "Ce choix de vote est non valable pour le second tour") ;
        }

        //procede au vote en complétant le tableau
        if ( isSecondTour == false){
            //tour1
            //on remplit le vote1
            tableauDesVotants[rangVotant].votedProposalId1 = ChoixVote1N ;
            tableauDesVotants[rangVotant].hasVoted1 = true ;
        }else{
            //tour2
            //on empli le vote2
            tableauDesVotants[rangVotant].votedProposalId2 = ChoixVote1N ;
            tableauDesVotants[rangVotant].hasVoted2 = true ;
        }   
    }





    //########################################################
    //  temps 5
    //  Le  depouillement (tour 1 et tour 2) 
    //########################################################


function depouillement() public  onlyOwner returns (string memory libelle, string memory PropositionGagnante , uint numeroProposition, uint qteVotePourGagnant, uint QteGagnant) {
    
    
        //l'accès de cette fonction est ouverte uniquement à l'administrateur
    
        //vérification 1
        //vérifie que l'on est bien dans la phase de epouillement
        require( uint(StatutVote) == 5  , unicode"Nous ne sommes pas en phase de dépouillement") ;

        //premier tour : depouillement relancé :interdit
        //lors du premier depouillement et en cas  aexequo on tope isSecondTour
        //or en cas de relance de ce script on dépouille le tour 2 donc on doit bloquer un nouveau dépuillement tour 1
        //if ( isSecondTour == true && isDepouillementT1ok==true && isSecondTourTermine ==false  ){
        //    require(  isDepouillementT1ok == false , unicode"Le dépouillement du tour 1 a deja eu lieu") ;
        //}
        

        //va evaluer ls totaux par proposition et les stocker dans la structure
        //dans le cas du second tour il n'y a pas d'incidence à analyser les propositions qui ne participe pas 
        uint QteProposition  = tableauProposition.length;
        uint QteVotants      = tableauDesVotants.length;

        uint totalComptage ; 

        if (isPretPourTour2 == false){

            //depouillement premier tour

            for  (uint t2proposition=1 ; t2proposition <= QteProposition ; t2proposition++){
                for  ( uint rangVotant =0 ; rangVotant < QteVotants ; rangVotant++){
                    if (tableauDesVotants[rangVotant].votedProposalId1 == t2proposition  ){ 
                        //on incremente le compteur
                        totalComptage++ ; 
                        }
                }

                //fin de la boucle des participants
                //on connait le score de la proposition
                tableauProposition[t2proposition-1].voteCount         = totalComptage ;

                //on stocke également le score dans le resultat du tour 1
                tableauProposition[t2proposition-1].voteCountTour1    = totalComptage ;

                //remise à 0 du compteur
                totalComptage = 0;
            }

            //on flag la fin du depouillement tour 1    
            isDepouillementT1ok = true;



        }else  {

            //depouillement second tour

            for  (uint Proposition=1 ; Proposition <= QteProposition ; Proposition++){
                for  ( uint rangVotant =0 ; rangVotant < QteVotants ; rangVotant++){
                    if (tableauDesVotants[rangVotant].votedProposalId2 == Proposition  ){ 
                        //on incremente le compteur
                        totalComptage++ ; 
                        }
                }

              

                //fin de la boucle des participants
                //on connait le score de la proposition
                tableauProposition[Proposition-1].voteCount = totalComptage ;

                //remise à 0 du compteur
                totalComptage = 0;
            }

            //on clot le tour 2
            isSecondTourTermine = true ; 

            //on flag la fin du depouillement tour 2
            isDepouillementT2ok = true;    

        }




        //depouillement terminé c'est à dire que pour le premier et second tour 
        // les propositions sont scorées
        //
        //evaluation du gagnant 
        //
        //initialisation des variables locales
        uint  voixMax             = 0 ; //variable utilitaire qui va contenir le nombre de voix maximum
        uint  indexDuMax          = 0 ; //variable utilitaire qui va contenir l'index de la proposition qui a le max
        uint  totalVoteExprim     = 0 ; //variable utilitaire
        uint  qteGagnant          = 0 ; //variable utilitaire

        //parcours les propositions chiffrées pour déterminer la proposition qui à le max de compte
        //comptaible tour 2 puisque qu'on utilise le meme compteur pour le tour 1 et 2
        for ( uint numProposition=1 ; numProposition <= QteProposition ; numProposition++){

                totalVoteExprim += tableauProposition[numProposition-1].voteCount ;

                //test si la valeur est 
                if ( tableauProposition[numProposition-1].voteCount > voixMax ) {
                    //on reevalue le max
                    voixMax      = tableauProposition[numProposition-1].voteCount ;
                    indexDuMax   = numProposition-1; 
                }
        }

        //on connait le nombre de voix max pour au moins une proposition.
        // en parcourant le tableau des propositions on va découvrir celle(s) qui ont ce score


        //on ne peut pas savoir si on a plusieurs gagnant sans avoir tout parcouru pour comparer les totaux de voix
        //détermine également si il n'y a pas dexaequo et donc de potentiel deuxieme tour
        //voixMax  = nombre de votes max pour une proposition

        //consolidation des résultats et détermination des propositions gagnantes qui ont le voixMax
        for ( uint numeProposition=1 ; numeProposition <= QteProposition ; numeProposition++){

            //top les gagnants et evalue si il y a plusieurs propositions gagnantes
            if ( tableauProposition[numeProposition-1].voteCount == voixMax ) {

                //on flag la proposition comme étant gagnante
                tableauProposition[numeProposition-1].isGagnant = true ;

                //on inscrement le compteur local du nombre de gagnant
                qteGagnant++;

            }else {
                tableauProposition[numeProposition-1].isGagnant = false ;
            }    
        
        }



        //on détermine l'issue du vote à savoir si il y a 1un gagnant  ou plusieurs aexequo


        if (qteGagnant == 1){

            //gagnant unique  

            //on indique au variable globale le numero de la proposition gagnante en redressant IndexduMax
            numeroPropositionGagnante = indexDuMax+1 ;

            //on précise le nombre de voix qu'il a obtenu
            qteVoixGagnant = voixMax ;

            return( "gagnant unique ", tableauProposition[indexDuMax].laProposition , numeroPropositionGagnante ,  voixMax , QteGagnant) ;


        } else if (qteGagnant > 1){

            if (isSecondTour == false) {
                //TOUR 1
                //plusieurs gagnants
                //necessité d'un second tour

                //on ne precise pas de gagnant
                numeroPropositionGagnante = 0 ;

                //par contre on précise le nombre de voix qu'ont obtenu les exaequo
                qteVoixGagnant = voixMax ;

                //on declare un second tour
                isSecondTour = true ; 

                //on est en statut depouillement et on attend que la personne passe à l'étape
                //suivante pour preparer les data pour le second tour et basculer à l'etape debut de vote

                 return( "Exaequo. necessite second tour" , "plusieurs",numeroPropositionGagnante, voixMax , QteGagnant ); 

            }else {
                //TOUR 2
                //plusieurs gagnants
                //necessité d'un troisèeme tour
                //cas non couvert

                //on ne precise pas de gagnant
                numeroPropositionGagnante = 0 ;

                //par contre on précise le nombre de voix qu'ont obtenu les exaequo
                qteVoixGagnant = voixMax ;

                return( "Exaequos au second tour abandon" , "plusieurs", numeroPropositionGagnante, voixMax , QteGagnant ); 
            }

            
        } 

 
    }




function getWinner() public view returns (string memory gagnant , uint qteVote) {

        ////vérifie que l'on est bien dans la phase de depouillement
        require( uint(StatutVote) == 5  , unicode"Nous ne sommes pas en phase de dépouillement") ;
     
        //verifie que le depouillement du tour 1 à eu lieu
        require(isDepouillementT1ok == true , unicode"Le dépouillement du premier tour n'a pas eu lieu") ;


        //en cas de second tour n'affiche pas les resultats si le depouillement n'a pas eu lieu
        if (isSecondTour == true && isPretPourTour2 == true && isDepouillementT2ok ==false){
            require( isDepouillementT2ok == true, unicode"Le dépouillement du second tour n'a pas eu lieu") ;
        }

        //si la proposition gagnante est existante alors elle est strictement > 0 entre 1 et N
        if (numeroPropositionGagnante > 0) {
            //une proposition gagnante trouve
            return( tableauProposition[numeroPropositionGagnante-1].laProposition ,tableauProposition[numeroPropositionGagnante-1].voteCount ); 
        }else {

            //resultat inconnu 

            if (isSecondTour == false) {
                //plusieurs gagnants au tour 1
                return( "il y a des exaequos au tour 1" ,qteVoixGagnant );    
            } else if ( (isSecondTour == true) && (isSecondTourTermine == false))  {
                 //apres le depouillement du tour 1 et avant le lancement du second tour
                return( "il y a des exaequos au tour 1. Besoin d'un second tour." ,qteVoixGagnant );    
            } else if ( (isSecondTour == true) && (isSecondTourTermine == true))  {
                 //plusieurs gagnants
                return( "il y a des exaequos au tour 2. abandon" , qteVoixGagnant );    
            } 
        }
    } 


function getResults() public  returns (string memory proposition , uint tour1, uint tour2) {

        //vérifie que l'on est bien dans la phase de depouillement
        require( uint(StatutVote) == 5  , unicode"Nous ne sommes pas en phase de dépouillement") ;      

        //incremente le cylce de presentation des resultats
       cycleResult++ ;  

        //fait cycler les résultats
       if( cycleResult > tableauProposition.length )  {
           cycleResult = 1 ;  
        }
      

            
        if ( isSecondTour == false ){
            //premie tour : on presente un seul résultat
            return( tableauProposition[cycleResult-1].laProposition , tableauProposition[cycleResult-1].voteCount  , 0  ) ;
        }else if ( (isSecondTour == true )&& (isSecondTourTermine == false ) ){
            //début du second tour : on presente le resultat du tour 1
            return( tableauProposition[cycleResult-1].laProposition , tableauProposition[cycleResult-1].voteCount  , 0  ) ;           
        }else if ( (isSecondTour == true) && (isSecondTourTermine == true ) ){
            //second tour terminé: on presente les deux résultats
            return(tableauProposition[cycleResult-1].laProposition , tableauProposition[cycleResult-1].voteCountTour1  ,tableauProposition[cycleResult-1].voteCount);           
        }    


       
    }




function lanceSecondTour() public onlyOwner {

        require(isSecondTour == true , "Il n'y a pas de second tour") ;

        require(isSecondTourTermine == false , unicode"Le second tour est terminé") ;

        require(isPretPourTour2 == false , unicode"Les données sont déjà prete pour le second tour") ;


        emit debutSecondTour ("Preparation des donnees du second tour");

        uint QteProposition = tableauProposition.length ;

        

        //on organise un second tour dans la mesure ou 2 ou plusieurs propositions ont recue le meme nombre de voix
        //on va invalider dans la liste des propositions celles qui sont pas au second tour


        //on parcour le tableau des propositions pour préparer les donénes pour le second tour
        for ( uint numeroProposition =1 ; numeroProposition <= QteProposition ; numeroProposition++) {

           

            //on effectue le transfer du resultat du premier tour dans l'archive des resultats du premier tour
            tableauProposition[numeroProposition-1].voteCountTour1 = tableauProposition[numeroProposition-1].voteCount ;

            //on efface le compteur en vue du prochain vote
            tableauProposition[numeroProposition-1].voteCount = 0 ;

            //on flag la proposition si elle participe au second tour
            // on verifie que la proposition à bien le nombre de voix pour etre elligible au second tour
            if (tableauProposition[numeroProposition-1].voteCountTour1 == qteVoixGagnant  ){

                 //emet l'event pour signaler que la proposition participe au second tour
                emit ProposalRegistered2EmeTour(numeroProposition-1, tableauProposition[numeroProposition-1].laProposition );

                tableauProposition[numeroProposition-1].isTour2 = true;
            }

        }
        
        //les propositions sont pretes pour le second tour
        isPretPourTour2 = true ; 

        //on relance le vote en se placant en phase de vote
       StatutVote = WorkflowStatus.VotingSessionStarted ;
      
     


    }






function DataGenerator() public onlyOwner {
    //
    // ce script est destiné au correcteur permet de creer un jeu de données pour le tour 1 et pour tester les différents résultats des votes
    // il doit etre supprimé lors de la mise en production

        

        //creation de 7 votants
        Voter memory newVotant ; 
        newVotant.isRegistered      = true ; 
        newVotant.adressDuVotant    = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 ; 
        newVotant.hasVoted1          = true ;
        newVotant.votedProposalId1   = 4 ;
        newVotant.votedProposalId2   = 1 ;
        tableauDesVotants.push(newVotant);

        newVotant.isRegistered      = true ; 
        newVotant.adressDuVotant    = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 ; 
        newVotant.hasVoted1          = true ;
        newVotant.votedProposalId1   = 2 ;
        newVotant.votedProposalId2   = 4 ;
        tableauDesVotants.push(newVotant);

        newVotant.isRegistered      = true ; 
        newVotant.adressDuVotant    = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB ; 
        newVotant.hasVoted1          = true ;
        newVotant.votedProposalId1   = 1 ;
        newVotant.votedProposalId2   = 1 ;
        tableauDesVotants.push(newVotant);

        newVotant.isRegistered      = true ; 
        newVotant.adressDuVotant    = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2 ; 
        newVotant.hasVoted1          = true ;
        newVotant.votedProposalId1   = 1 ;
        newVotant.votedProposalId2   = 1 ;
        tableauDesVotants.push(newVotant);

        newVotant.isRegistered      = true ; 
        newVotant.adressDuVotant    = 0x17F6AD8Ef982297579C203069C1DbfFE4348c372 ; 
        newVotant.hasVoted1          = true ;
        newVotant.votedProposalId1   = 4 ;
        newVotant.votedProposalId2   = 4 ;
        tableauDesVotants.push(newVotant);

        newVotant.isRegistered      = true ; 
        newVotant.adressDuVotant    = 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678 ; 
        newVotant.hasVoted1          = true ;
        newVotant.votedProposalId1   = 1 ;
        newVotant.votedProposalId2   = 4 ;
        tableauDesVotants.push(newVotant);

        newVotant.isRegistered      = true ; 
        newVotant.adressDuVotant    = 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7 ; 
        newVotant.hasVoted1          = true ;
        newVotant.votedProposalId1   = 4 ;
        newVotant.votedProposalId2   = 4 ;
        tableauDesVotants.push(newVotant);

        //resultats attendus
        // tour 1  exaequo les 1 et 4 avec 3 voix
        //proposition 1 : index 0 : 3 vote(s)
        //proposiiton 2 : index 1 : 1 vote(s)
        //proposition 3 : index 2 : 0 vote(s)
        //proposition 4 : index 3 : 3 vote(s)

        //resultats attendus
        // tour 2  exaequo les 1 et 4 avec 3 voix
        //proposition 1 : index 0 : 3 vote(s)
        //proposition 4 : index 3 : 4 vote(s)

        //gagnant proposition 4 avec 4 voies



        //creation de 4 propositions
        Proposal memory newProposition ; 

        newProposition.laProposition = "Proposition 1"; 
        tableauProposition.push(newProposition);
        
        newProposition.laProposition = "Proposition 2"; 
        tableauProposition.push(newProposition);
        
        newProposition.laProposition = "Proposition 3"; 
        tableauProposition.push(newProposition);
        
        newProposition.laProposition = "Proposition 4"; 
        tableauProposition.push(newProposition);
  

        //passe directement à la phase fin de vote
        StatutVote = WorkflowStatus.VotingSessionEnded ;
    }

}//fin contract

 

