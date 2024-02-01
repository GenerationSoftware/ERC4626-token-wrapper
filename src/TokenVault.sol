// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import { ERC4626, ERC20, IERC20 } from "openzeppelin-contracts/token/ERC20/extensions/ERC4626.sol";

contract TokenVault is ERC4626 {
    
    constructor(
        IERC20 asset_,
        string memory name_,
        string memory symbol_
    ) ERC4626(asset_) ERC20(name_, symbol_) { }

}
