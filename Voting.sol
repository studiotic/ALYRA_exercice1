
/* 
Projet #1 Voting
ECOLE ALYRA
Sébastien HOFF
Promotion Rinkeby
*/

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.17;


Import ("https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol")

contract Voting{

    struct Voter {
    bool isRegistered;
    bool hasVoted;
    uint votedProposalId;
    }

    struct Proposal {
    string description;
    uint voteCount;
    }

    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    enum statusDuVote{
    EnregistrementElecteurs,
    DebutEnregistrementChoix,
    FinEnregistrementChoix,
    DebutDuVote,
    FinDuVote,
    VoteDepouille
    }

  

    address MonAddressDestinataire ;

    //temps 1
    // ajoute les votants
    function ajouteVotant(address addressNouveauVotant) public {

    }


    function transfer(address monAdress) public payable returns(bool) {
        return state.balance;
    }

    function voirVote( address adresseVotant) public returns(string ChoixVotant) {
        return 
    }

    function getWinner()  public returns(){

    }

}
