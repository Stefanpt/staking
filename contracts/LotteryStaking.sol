// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LotteryStaking {
    IERC721 public nftCollection;

    uint256 public constant SECONDS_IN_A_DAY = 86400;

    struct Token {
        uint256 timeOfLastStake;
        uint256 timeStakedBefore;
        address staker;
    }

    mapping(uint256 => Token) tokens;
    mapping(address => uint256[]) tokenIdsStaked;

    address[] public stakers;

    constructor(IERC721 _nftCollection) {
        nftCollection = _nftCollection;
    }

    function stake(uint256[] memory _tokenIds) external {
        if (tokenIdsStaked[msg.sender].length == 0) {
            stakers.push(msg.sender);
        }
        for (uint256 i; i < _tokenIds.length; i++) {
            require(
                nftCollection.ownerOf(_tokenIds[i]) == msg.sender,
                "Can't stake tokens you don't own!"
            );
            nftCollection.transferFrom(msg.sender, address(this), _tokenIds[i]);
            tokenIdsStaked[msg.sender].push(_tokenIds[i]);
            tokens[_tokenIds[i]].timeOfLastStake = block.timestamp;
            tokens[_tokenIds[i]].staker = msg.sender;
        }
    }

    function withdraw(uint256[] memory _tokenIds) external {
        for (uint256 i; i < _tokenIds.length; i++) {
            require(tokens[_tokenIds[i]].staker == msg.sender);
            for (uint256 j; j < tokenIdsStaked[msg.sender].length; ++j) {
                if (tokenIdsStaked[msg.sender][j] == _tokenIds[i]) {
                    tokenIdsStaked[msg.sender][j] = tokenIdsStaked[msg.sender][
                        tokenIdsStaked[msg.sender].length - 1
                    ];
                    tokenIdsStaked[msg.sender].pop();
                }
            }
            nftCollection.transferFrom(address(this), msg.sender, _tokenIds[i]);
            tokens[i].timeStakedBefore =
                block.timestamp -
                tokens[i].timeOfLastStake;
            tokens[i].timeOfLastStake = 0;
        }
    }

    function calculateDaysStaked(address _user) public view returns (uint256) {
        uint256 totalTimeStaked;
        for (uint256 i; i < tokenIdsStaked[_user].length; i++) {
            if (tokens[tokenIdsStaked[_user][i]].timeOfLastStake == 0) {
                totalTimeStaked += tokens[tokenIdsStaked[_user][i]]
                    .timeStakedBefore;
            } else {
                totalTimeStaked += (tokens[tokenIdsStaked[_user][i]]
                    .timeStakedBefore +
                    (block.timestamp -
                        tokens[tokenIdsStaked[_user][i]].timeOfLastStake));
            }
        }
        return totalTimeStaked / SECONDS_IN_A_DAY;
    }

    function getUserNftsStaked(address _user)
        public
        view
        returns (uint256[] memory)
    {
        return tokenIdsStaked[_user];
    }

    function getStakers() external view returns (address[] memory) {
        return stakers;
    }

    function getWinner(uint256 _randomNumber) public view returns (address) {
        address winner;
        uint256 total;
        uint256 stakersLength = stakers.length;
        uint256[] memory chances = new uint256[](stakersLength);
        chances[0] = calculateDaysStaked(stakers[0]);
        for (uint256 i = 1; i < stakersLength; i++) {
            uint256 chance = calculateDaysStaked(stakers[i]);
            chances[i] += chances[i - 1] + chance;
        }
        total = chances[stakersLength - 1];
        uint256 luckyNumber = _randomNumber % total;
        for (uint256 i; i < stakersLength; i++) {
            if (luckyNumber < chances[i]) {
                winner = stakers[i];
                break;
            }
        }
        return winner;
    }
}
