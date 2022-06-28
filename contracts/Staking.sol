// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IRewardToken is IERC20 {
    function mint(address to, uint256 amount) external;
}

contract ERC721Staking is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Interfaces for ERC20 and ERC721
    IRewardToken public rewardsToken;
    IERC721 public nftCollection;

    // Staker info
    struct Staker {
        uint256[] tokenIdsStaked;
        uint256 amountStaked;
        uint256 timeOfLastUpdate;
        uint256 unclaimedRewards;
    }

    uint256 private rewardsPerHour = 100000;

    mapping(address => Staker) public stakers;
    mapping(uint256 => address) public stakerAddress;

    constructor(IERC721 _nftCollection, IRewardToken _rewardsToken) {
        nftCollection = _nftCollection;
        rewardsToken = _rewardsToken;
    }


    function stake(uint256[] memory _tokenIds) external nonReentrant {
        if (stakers[msg.sender].amountStaked > 0) {
            uint256 rewards = calculateRewards(msg.sender);
            stakers[msg.sender].unclaimedRewards += rewards;
        }

        for (uint256 i; i < _tokenIds.length; ++i) {
            require( nftCollection.ownerOf(_tokenIds[i]) == msg.sender, "Can't stake tokens you don't own!" );
            nftCollection.transferFrom(msg.sender, address(this), _tokenIds[i]);
            stakers[msg.sender].tokenIdsStaked.push(_tokenIds[i]);
            stakers[msg.sender].amountStaked++;
            stakerAddress[_tokenIds[i]] = msg.sender;
        }
        
        stakers[msg.sender].timeOfLastUpdate = block.timestamp;
    }

    function withdraw(uint256[] memory _tokenIds) external nonReentrant {
        require( stakers[msg.sender].amountStaked > 0, "You have no tokens staked" );
        uint256 rewards = calculateRewards(msg.sender);
        stakers[msg.sender].unclaimedRewards += rewards;

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

        stakers[msg.sender].timeOfLastUpdate = block.timestamp;
    }

    /*
    *   Release all reward tokens
    */
    function claimRewards() external nonReentrant {
        uint256 rewards = calculateRewards(msg.sender) + stakers[msg.sender].unclaimedRewards;
        require(rewards > 0, "You have no rewards to claim");
        stakers[msg.sender].timeOfLastUpdate = block.timestamp;
        stakers[msg.sender].unclaimedRewards = 0;
        rewardsToken.mint(msg.sender, rewards);
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
    function userStakeInfo(address _user) public view returns ( uint256 _amountStaked, uint256 _availableRewards, uint256[] memory _tokenIdsStaked ) {
        return (
            stakers[_user].amountStaked,
            availableRewards(_user),
            stakers[_user].tokenIdsStaked
        );
    }


    /*
    *   INTERNAL FUNCTIONS
    */

    /*
    *   Returns ERC20 rewards available for claim. Currently accrued + calculated since last call 
    *   @params Address of accont ot query
    *   @return Amount in wei
    */
    function availableRewards(address _user) internal view returns (uint256) {
        require(stakers[_user].amountStaked > 0, "User has no tokens staked");
        uint256 _rewards = stakers[_user].unclaimedRewards +
            calculateRewards(_user);
        return _rewards;
    }

    /*
    *   If user has NFT's staked, calculate the rewards accumulated per hour since last update
    *   @params Address of accont ot query
    *   @return Amount in wei
    */
    function calculateRewards(address _staker) internal view returns (uint256 _rewards) {
        return (((
            ((block.timestamp - stakers[_staker].timeOfLastUpdate) *
                stakers[msg.sender].amountStaked)
        ) * rewardsPerHour) / 3600);
    }

}

