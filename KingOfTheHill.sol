// SPDX-License-Identifier: MIT
// 0xE17b68560D745ca0CcF676286f655C5b3F9CC62d

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

/// @title King of the Hill Game
/// @author Solène PETTIER
/// @notice You can use this contract to play and earn ETH by overbiding actual smart contract balance
/// @dev Functions calculate when player wins and how much

contract KingOfTheHill {
    // @dev library usage
    using Address for address payable;

    // @dev state variables
    address private _contractOwner;
    uint256 private _blockNumber;
    uint256 private _seedBlock;
    uint256 private _seed; 
    address private _potOwner;
    
    // @dev events
    event ContractOwnerUpdated(address indexed sender, address contractOwner_);
    event BlockNumberUpdated(address indexed sender, uint256 blockNumber_);
    event Seeded(address indexed potOwner_, uint256 seed_);

    // @dev constructor
    constructor (address contractOwner_, uint256 blockNumber_) payable {
        require(msg.value != 0, "KingOfTheHill : You must initialize seed.");
        _contractOwner = contractOwner_;
        _blockNumber = blockNumber_;
        _seedBlock = block.number;
        _seed = msg.value;
        _potOwner = contractOwner_;
    }

    // @dev modifiers
    modifier onlyContractOwner() {
        require(msg.sender == _contractOwner, "KingOfTheHill : Only contract owner can call this function.");
        _;
    }
    modifier enoughSeed() {
        require(msg.value >= _seed, "KingOfTheHill : Must pay at leat seed value.");
        _;
    }
    modifier onlyPotOwner() {
        require(msg.sender == _potOwner, "KingOfTheHill : You do not onw the pot.");
        _;
    }
    modifier notPotOwner() {
        require(msg.sender != _potOwner, "KingOfTheHill : You already onw the pot.");
        _;
    }
    
    // @dev functions
    receive() external payable {
    }
    
    function setContractOwner(address contractOwner_) public onlyContractOwner {
        _contractOwner = contractOwner_; 
        emit ContractOwnerUpdated(msg.sender, contractOwner_);
    }
    
    function setBlockNumber(uint256 blockNumber_) public onlyContractOwner {
        _blockNumber = blockNumber_; 
        emit BlockNumberUpdated(msg.sender, blockNumber_);
    }

    function didWin() internal view returns(bool) {
        // @dev condition to declare last pot owner winner
        if (block.number >= _seedBlock + _blockNumber) {
            return true;
        } else {
            return false;
            
        }
    }

    function checkWin() public onlyPotOwner payable {
        if (didWin()) {
            payable(_potOwner).sendValue(address(this).balance * 80 / 100);
            payable(_contractOwner).sendValue(address(this).balance * 10 / 100);
            _seed = address(this).balance * 10 / 100;
        }
    }
    
    function seed() external enoughSeed notPotOwner payable {
        if (didWin()) {
            payable(_potOwner).sendValue(address(this).balance * 80 / 100);
            payable(_contractOwner).sendValue(address(this).balance * 10 / 100);
            _seed = address(this).balance * 10 / 100;
        }
       
        // @dev condition to refund new player
        if (msg.value > _seed) {
            payable(msg.sender).sendValue(_seed - msg.value);
        }
        
        // @dev new round begin
        _seedBlock = block.number;
        _seed += _seed;
        _potOwner = msg.sender;
        emit Seeded(msg.sender, _seed);
    }
    
    // @dev getters
    function getContractOwner() public view returns (address) {
        return _contractOwner;
    }
    function getBlockNumber() public view returns (uint256) {
        return _blockNumber;
    }
    function getSeedBlock() public view returns (uint256) {
        return _seedBlock;
    }
    function getSeed() public view returns (uint256) {
        return _seed;
    }
    function getPotOwner() public view returns (address) {
        return _potOwner;
    }
}