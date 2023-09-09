// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

error NotEnoughETHEntered();
error You_Already_Entered_MaxTimes();
error Nishaq__TransferWinnerFailed();
error Nishaq_Closed();
error NoUpkeepNeeded(uint256 balance, uint256 numplayers,  uint256 nishaq_state);

contract Nishaq is VRFConsumerBaseV2, AutomationCompatibleInterface{
    // Enums For State of Open of the Lottery
    enum NishaqState {
        OPEN,
        CALC,
        CLOSED
    }

    address private immutable owner;
    address private lastWinner;
    // setting the owner variable on the above line to  set the Owner of the Contract

    uint256 private entrance_fee;
    uint256 public maxEnterCount;
    address payable[] public n_players;
    mapping(address => uint256) public enter_count;
    mapping(address => uint256) public total_funds;

    // VRF-Coordinator Address
    VRFCoordinatorV2Interface private immutable i_vrf_coordinator_addr;

    // Values to create a requestId for VRF-Chainlink
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subscriptionId;
    uint16 private constant i_request_confirmation_vrf = 3;
    uint32 private immutable i_call_back_gas_limit_vrf;
    uint32 private immutable i_num_words;
    NishaqState private nishaq_state;
    uint private s_timeStamp;
    uint private nishaq_interval;

    // events
    event RequestedNishaqWinner(uint256 indexed requestId, uint32 indexed numWords);
    event WinnerPicked(address indexed recent_winner);
    event NishaqEntered(address indexed player);

    constructor(
        uint256 entrance_fee_init,
        uint256 maxEnterCount_init, 
        address vrf_coordinator_addr,
        bytes32 c_keyHash,
        uint64 c_subscriptionId,
        uint32 c_call_back_gas_limit,
        uint32 c_num_words,
        uint256 c_nishaq_interval
    ) VRFConsumerBaseV2(vrf_coordinator_addr) AutomationCompatibleInterface(){
        entrance_fee = entrance_fee_init;
        maxEnterCount = maxEnterCount_init;
        i_vrf_coordinator_addr = VRFCoordinatorV2Interface(vrf_coordinator_addr);
        i_keyHash = c_keyHash;
        i_subscriptionId = c_subscriptionId;
        i_call_back_gas_limit_vrf = c_call_back_gas_limit;
        i_num_words = c_num_words;
        owner = msg.sender;
        nishaq_state = NishaqState.OPEN;
        s_timeStamp = block.timestamp;
        nishaq_interval = c_nishaq_interval;
    }

    function enter_nishaq() public payable {
        if(nishaq_state != NishaqState.OPEN) revert Nishaq_Closed();
        if(msg.value < entrance_fee)revert NotEnoughETHEntered();
        // Finding if player already exists in the array or not
        n_players.push(payable(msg.sender));
        total_funds[msg.sender] += msg.value;
        enter_count[msg.sender] += 1;
        emit NishaqEntered(msg.sender);
    }

    function getEntranceFee() public view returns(uint256){
        return entrance_fee;
    }
    // Modifier Only_Entered_One
    modifier entered_one(uint256 index){
        require(n_players[index] == msg.sender, "You cannot see the players address because you are not that one");
        _;
    }

    function get_player(uint256 index) entered_one(index) public view returns(address) {
        return n_players[index];
    }

    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        bool isOpen = NishaqState.OPEN == nishaq_state;
        bool timePassed = ((block.timestamp - s_timeStamp) > nishaq_interval);
        bool hasPlayers = n_players.length > 0;
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = (timePassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(bytes calldata /* performData */) external {
        // Running the Winner Deciding Function here
        (bool upkeep, ) = checkUpkeep("");
        if (!upkeep) revert NoUpkeepNeeded(address(this).balance, n_players.length, uint256(nishaq_state));
        // Blocking the lottery here
        nishaq_state = NishaqState.CALC;
        uint256 requestId = i_vrf_coordinator_addr.requestRandomWords(
            i_keyHash,
            i_subscriptionId,
            i_request_confirmation_vrf,
            i_call_back_gas_limit_vrf,
            i_num_words
        );
        emit RequestedNishaqWinner(requestId, i_num_words);
    }

    function fulfillRandomWords(uint256 /* requestId */, uint256[] memory randomWords) internal override {
        uint256 index_of_winner = randomWords[0] % n_players.length;
        address payable recentWinner = n_players[index_of_winner];
        lastWinner = recentWinner;
        nishaq_state = NishaqState.OPEN;
        // Opening the Lottery in the Above Line Again
        // sending all the ETH-Balance to RecentWinner
        n_players = new address payable[](0);
        s_timeStamp = block.timestamp;
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        emit WinnerPicked(recentWinner);
        if (!success) revert Nishaq__TransferWinnerFailed();
    }

    function getTotalFunding() public view returns(uint256) {
        uint256 temp_total_funding = 0;
        for(uint256 pla_index; pla_index < n_players.length; pla_index++){
            temp_total_funding += total_funds[address(n_players[pla_index])];
        }
        return temp_total_funding;
    }

    function GetYourDetails() public view returns(uint256) {
        return total_funds[address(msg.sender)];
    }

    function getNishaqState() public view returns(string memory){
        uint256 temp_nishaq = uint256(nishaq_state);
        if (temp_nishaq == 0) return "Open";
        if (temp_nishaq == 1) return "Calculating";
        return "None";
    }

    function lotteryWinnerInterval() public view returns(uint256){
        return nishaq_interval;
    }
    
    function getLastWinner() public view returns(address) {
        return lastWinner;
    }

    function numberOfWinners() public view returns(uint256){
        return i_num_words;
    }

    function getOwner() public view returns(address) {
        return owner;
    }

    function getLatestTimeStamp() public view returns(uint){
        return s_timeStamp;
    }

    function getNumberOfPlayers() public view returns(uint256) {
        return n_players.length;
    }
}