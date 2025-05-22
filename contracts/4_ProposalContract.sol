// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract ProposalContract {

    address public owner;
    uint256 private counter;
    mapping(uint256 => Proposal) public proposal_history;
    mapping(address => bool) private hasVoted;

    struct Proposal {
        string title;
        string description;
        uint256 approve;
        uint256 reject;
        uint256 pass;
        uint256 total_vote_to_end;
        bool current_state;
        bool is_active;
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can create proposal");
        _;
    }

    modifier active() {
        require(proposal_history[counter].is_active == true, "The proposal is not active");
        _;
    }

    modifier newVoter(address _address) {
        require(!hasVoted[_address], "Address has already voted");
        _;
    }

    function create(string calldata _title, string calldata _description, uint256 _total_vote_to_end) external onlyOwner {
        counter += 1;
        proposal_history[counter] = Proposal({
            title: _title,
            description: _description,
            approve: 0,
            reject: 0,
            pass: 0,
            total_vote_to_end: _total_vote_to_end,
            current_state: false,
            is_active: true
        });

        // Reset vote tracking for new proposal
        resetVotes();
    }

    function vote(uint8 choice) external active newVoter(msg.sender) {
        Proposal storage proposal = proposal_history[counter];

        require(choice == 0 || choice == 1 || choice == 2, "Invalid vote choice");

        if (choice == 1) {
            proposal.approve += 1;
        } else if (choice == 2) {
            proposal.reject += 1;
        } else if (choice == 0) {
            proposal.pass += 1;
        }

        hasVoted[msg.sender] = true;
        proposal.current_state = calculateCurrentState();

        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;
        if (total_vote >= proposal.total_vote_to_end) {
            proposal.is_active = false;
        }
    }

    function calculateCurrentState() private view returns (bool) {
        Proposal storage proposal = proposal_history[counter];

        uint256 approve = proposal.approve;
        uint256 reject = proposal.reject;
        uint256 pass = proposal.pass;

        if (pass % 2 == 1) {
            pass += 1;
        }
        pass = pass / 2;

        return approve > (reject + pass);
    }

    function resetVotes() private {
        // Reset all voting records
        for (uint256 i = 0; i < voted_addresses.length; i++) {
            hasVoted[voted_addresses[i]] = false;
        }
        delete voted_addresses;
    }

    address[] private voted_addresses;

    function isVoted(address _addr) private view returns (bool) {
        return hasVoted[_addr];
    }
}
