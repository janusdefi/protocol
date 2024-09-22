// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Vault
/// @dev This contract allows users to deposit collateral and claim yield based on the deposited collateral.
contract Vault is Ownable {
    
    // The ERC20 token used as collateral
    ERC20 public collateralToken;
    // The yield rate for the deposited collateral
    uint256 public yieldRate;

    // Mapping to store user balances, keyed by user address
    mapping(address => uint256) public userBalances;

    // Event emitted when collateral is deposited
    event CollateralDeposited(address indexed user, uint256 amount);
    // Event emitted when yield is claimed
    event YieldClaimed(address indexed user, uint256 amount);

    /// @dev Constructor to initialize the Vault contract with the collateral token and yield rate.
    /// @param _collateralToken Address of the ERC20 token used as collateral.
    /// @param _yieldRate Yield rate for the deposited collateral.
    constructor(address _collateralToken, uint256 _yieldRate) {
        collateralToken = ERC20(_collateralToken);
        yieldRate = _yieldRate;
    }

    /// @dev Function for users to deposit collateral into the vault.
    /// @param amount Amount of collateral to deposit.
    function depositCollateral(uint256 amount) external {
        // Transfer the collateral tokens from the user to this contract
        collateralToken.transferFrom(msg.sender, address(this), amount);
        
        // Update the user's balance
        userBalances[msg.sender] += amount;
        
        // Emit an event for the deposit
        emit CollateralDeposited(msg.sender, amount);
    }

    /// @dev Function for users to claim their yield rewards.
    function claimYield() external {
        uint256 userBalance = userBalances[msg.sender];
        
        // Ensure the user has deposited collateral
        require(userBalance > 0, "No collateral deposited");

        // Calculate the yield based on the user's balance and the vault's yield rate
        uint256 yield = (userBalance * yieldRate) / 100;
        
        // Transfer the yield in collateral tokens to the user
        collateralToken.transfer(msg.sender, yield);
        
        // Emit an event for the yield claim
        emit YieldClaimed(msg.sender, yield);
    }
}
