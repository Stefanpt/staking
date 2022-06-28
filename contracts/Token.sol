// SPDX-License-Identifier: MIT LICENSE
pragma solidity >=0.8.4 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


contract GTokens is ERC20Burnable, Ownable, Pausable {

    mapping(address => bool) controllers;

    constructor() ERC20("GTokens", "GT") {}

    function mint(address to, uint256 amount) external whenNotPaused {
        require(controllers[msg.sender], "Only controllers can mint");
        _mint(to, amount);
    }

    function burnFrom(address account, uint256 amount) public override whenNotPaused {
        if (controllers[msg.sender]) {
            _burn(account, amount);
        }
        else {
            super.burnFrom(account, amount);
        }
    }

    function addController(address controller) external onlyOwner {
        controllers[controller] = true;
    }

    function removeController(address controller) external onlyOwner {
        controllers[controller] = false;
    }

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

    function burn(uint256 amount) public override whenNotPaused {
        _burn(_msgSender(), amount);
    }
    
}