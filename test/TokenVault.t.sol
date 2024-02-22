// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Test.sol";

import { TokenVault } from "../src/TokenVault.sol";
import { ERC20Mock } from "openzeppelin-contracts/mocks/token/ERC20Mock.sol";

contract TokenVaultTest is Test {

    ERC20Mock public asset;
    TokenVault public tokenVault;

    address public alice;
    address public bob;

    function setUp() public {
        asset = new ERC20Mock();
        tokenVault = new TokenVault(asset, "Test Token Vault", "vToken");

        alice = makeAddr("alice");
        bob = makeAddr("bob");
    }

    function testSomeStuff() external {
        asset.mint(alice, 1e18);
        asset.mint(bob, 1e18);

        vm.startPrank(alice);
        asset.approve(address(tokenVault), 1e18);
        tokenVault.deposit(1e18, alice);
        vm.stopPrank();

        assertEq(tokenVault.balanceOf(alice), 1e18);
        assertEq(tokenVault.totalAssets(), 1e18);
        assertEq(tokenVault.totalSupply(), 1e18);

        // mint some yield to the vault
        asset.mint(address(tokenVault), 1e16);
        assertEq(tokenVault.balanceOf(alice), 1e18);
        assertEq(tokenVault.totalAssets(), 1e18 + 1e16);
        assertEq(tokenVault.totalSupply(), 1e18);
        
        // bob deposits
        vm.startPrank(bob);
        asset.approve(address(tokenVault), 1e18);
        tokenVault.deposit(1e18, bob);
        vm.stopPrank();

        assertEq(tokenVault.balanceOf(alice), 1e18);
        assertApproxEqAbs(tokenVault.balanceOf(bob), uint256(1e18 * 1e18) / (1e18 + 1e16), 1); // proportional
        assertEq(tokenVault.totalAssets(), 2e18 + 1e16);
        assertEq(tokenVault.totalSupply(), 1e18 + tokenVault.balanceOf(bob));

        // they both withdraw
        vm.startPrank(bob);
        tokenVault.redeem(tokenVault.balanceOf(bob), bob, bob);
        vm.stopPrank();

        vm.startPrank(alice);
        tokenVault.redeem(tokenVault.balanceOf(alice), alice, alice);
        vm.stopPrank();

        assertEq(tokenVault.balanceOf(alice), 0);
        assertEq(tokenVault.balanceOf(bob), 0);
        assertApproxEqAbs(tokenVault.totalAssets(), 0, 1);
        assertEq(tokenVault.totalSupply(), 0);

        assertApproxEqAbs(asset.balanceOf(alice), uint256(1e18 + 1e16), 1);
        assertApproxEqAbs(asset.balanceOf(bob), uint256(1e18), 1);
    }

}
