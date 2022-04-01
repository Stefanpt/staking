// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface ERC721 /* is ERC165 */ {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    function mint(uint256 _mintAmount) public payable;
    function mintForAddress(uint256 _mintAmount, address _receiver) public;
    function walletOfOwner(address _owner) public view returns (uint256[] memory);
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory);

}

interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}