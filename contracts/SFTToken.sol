// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract SFTToken is Ownable2Step, ERC20, ERC20Burnable {

    mapping(address => bool) private _minters;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    modifier onlyMinter() {
        require(isMinter(msg.sender), "Only minter can call");
        _;
    }

    constructor() ERC20("SFT Token", "SFT") {}

     /**
     * @dev Add a new minter.
     * @param _account Address of the minter
     */
    function addMinter(address _account) external onlyOwner {
        _addMinter(_account);
    }

    /**
     * @dev Remove a minter.
     * @param _account Address of the minter
     */
    function removeMinter(address _account) external onlyOwner {
        _removeMinter(_account);
    }

    /**
     * @dev Renounce to be a minter.
     */
    function renounceMinter() external {
        _removeMinter(msg.sender);
    }

    /**
     * @dev Mint new tokens.
     * @param _to Address to send the newly minted tokens
     * @param _amount Amount of tokens to mint
     */
    function mint(address _to, uint256 _amount) external onlyMinter {
        _mint(_to, _amount);
    }

    /**
     * @dev Return if the `_account` is a minter or not.
     * @param _account Address to check
     * @return True if the `_account` is minter
     */
    function isMinter(address _account) public view returns (bool) {
        return _minters[_account];
    }

    /**
     * @dev Add a new minter.
     * @param _account Address of the minter
     */
    function _addMinter(address _account) private {
        _minters[_account] = true;
        emit MinterAdded(_account);
    }

    /**
     * @dev Remove a minter.
     * @param _account Address of the minter
     */
    function _removeMinter(address _account) private {
        _minters[_account] = false;
        emit MinterRemoved(_account);
    }

}