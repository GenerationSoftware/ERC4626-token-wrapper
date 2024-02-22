// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { TokenVault, IERC20 } from "./TokenVault.sol";

contract TokenVaultFactory {
    /* ============ Events ============ */

    /**
     * @notice Emitted when a new TokenVault has been deployed by this factory.
     * @param vault The vault that was deployed
     * @param asset The underlying asset of the vault
     * @param name The name of the vault token
     * @param symbol The symbol for the vault token
     */
    event NewTokenVault(
        TokenVault indexed vault,
        IERC20 indexed asset,
        string name,
        string symbol
    );

    /* ============ Variables ============ */

    /// @notice List of all vaults deployed by this factory.
    TokenVault[] public allVaults;

    /// @notice Mapping to verify if a Vault has been deployed via this factory.
    mapping(address vault => bool deployedByFactory) public deployedVaults;

    /// @notice Mapping to store deployer nonces for CREATE2
    mapping(address deployer => uint256 nonce) public deployerNonces;

    /* ============ External Functions ============ */

    /**
     * @notice Deploy a new vault
     * @param _asset Address of the asset that the vault will accept
     * @param _name Name of the ERC20 share minted by the vault
     * @param _symbol Symbol of the ERC20 share minted by the vault
     */
    function deployVault(
      IERC20 _asset,
      string memory _name,
      string memory _symbol
    ) external returns (TokenVault) {
        TokenVault _vault = new TokenVault{
            salt: keccak256(abi.encode(msg.sender, deployerNonces[msg.sender]++))
        }(
            _asset,
            _name,
            _symbol
        );

        allVaults.push(_vault);
        deployedVaults[address(_vault)] = true;

        emit NewTokenVault(
            _vault,
            _asset,
            _name,
            _symbol
        );

        return _vault;
    }

    /**
     * @notice Total number of vaults deployed by this factory.
     * @return uint256 Number of vaults deployed by this factory.
     */
    function totalVaults() external view returns (uint256) {
        return allVaults.length;
    }
}
