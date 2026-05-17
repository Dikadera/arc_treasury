// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Vault.sol";

contract VaultFactory {
    Vault[] public vaults;
    
    event VaultCreated(address indexed vaultAddress, address[] members, uint256 threshold);

    function createVault(address _usdc, address[] memory _members, uint256 _threshold) public returns (address) {
        Vault newVault = new Vault(_usdc, _members, _threshold);
        vaults.push(newVault);
        emit VaultCreated(address(newVault), _members, _threshold);
        return address(newVault);
    }

    function getVaults() public view returns (Vault[] memory) {
        return vaults;
    }
}
