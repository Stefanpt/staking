// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ERC721Staking is Ownable, ReentrancyGuard {

    // Interfaces for ERC20 and ERC721
    IERC721 public nftCollection;

    // Staker info
    struct Staker {
        uint256[] tokenIdsStaked;
        uint256 amountStaked;
        uint256 timeOfLastUpdate;
        uint256 entries;
    }

    bool public paused = false;

    mapping(address => Staker) public stakers;
    mapping(uint256 => address) public stakerAddress;
    mapping (address => bool) isStaker;
    address[] public Stakers;

    constructor(IERC721 _nftCollection) {
        nftCollection = _nftCollection;
    }


    function stake(uint256[] memory _tokenIds) external nonReentrant {
        require(!paused, "The contract has been paused!");

        for (uint256 i; i < _tokenIds.length; ++i) {
            require( nftCollection.ownerOf(_tokenIds[i]) == msg.sender, "Can't stake tokens you don't own!" );
            nftCollection.transferFrom(msg.sender, address(this), _tokenIds[i]);
            stakers[msg.sender].tokenIdsStaked.push(_tokenIds[i]);
            stakers[msg.sender].amountStaked++;
            stakerAddress[_tokenIds[i]] = msg.sender;
        }

        // check against the mapping
        if (isStaker[msg.sender] == false) {
            // push the unique item to the array
            Stakers.push(msg.sender);
            // don't forget to set the mapping value as well
            isStaker[msg.sender] = true;
        }
        
        stakers[msg.sender].timeOfLastUpdate = block.timestamp;
    }

    function withdraw(uint256[] memory _tokenIds) external nonReentrant {
        require( stakers[msg.sender].amountStaked > 0, "You have no tokens staked" );

        for (uint256 i; i < _tokenIds.length; ++i) {
            require( stakerAddress[_tokenIds[i]] == msg.sender, "You can only wihtdraw your own tokens!" );
            stakerAddress[_tokenIds[i]] = address(0);
            stakers[msg.sender].amountStaked--;

            for ( uint256 j; j < stakers[msg.sender].tokenIdsStaked.length; ++j ) {
                if (stakers[msg.sender].tokenIdsStaked[j] == _tokenIds[i]) {
                    stakers[msg.sender].tokenIdsStaked[j] = stakers[msg.sender].tokenIdsStaked[ stakers[msg.sender].tokenIdsStaked.length - 1 ];
                    stakers[msg.sender].tokenIdsStaked.pop();
                }
            }

            nftCollection.transferFrom(address(this), msg.sender, _tokenIds[i]);
        }

    }


    /*
    *   VIEW FUNCTIONS
    */

    /*
    *   Returns the information of staked users
    *   @params Address of accont ot query
    *   @return Deposit address
    *   @return Amount of tokens staked
    *   @return Token ID's staked
    */
    function userStakeInfo(address _user) public view returns ( uint256 _amountStaked, uint256 _availableEntries, uint256[] memory _tokenIdsStaked ) {
        return (
            stakers[_user].amountStaked,
            stakers[_user].entries,
            stakers[_user].tokenIdsStaked
        );
    }

    function dailyCalculateEntries() public {
        for (uint256 i; i < Stakers.length; ++i) {
            calculateEntries(Stakers[i]);
        }
    }

    /*
    *   INTERNAL FUNCTIONS
    */

    function calculateEntries(address _staker) public { // should be internal
        uint _days = (block.timestamp - stakers[_staker].timeOfLastUpdate) / 60;
        if ( _days >= 1 ) {
            stakers[_staker].entries += _days * stakers[_staker].amountStaked;
            stakers[_staker].timeOfLastUpdate = block.timestamp;
        }

    }

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

}