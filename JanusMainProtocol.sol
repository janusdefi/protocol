// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title JanusMainProtocol
/// @dev This contract manages vaults, collateral deposits, and yield claims for the Janus ecosystem.
contract JanusMainProtocol is Ownable {
    
    /// @dev Structure to store information about each vault.
    struct Vault {
        address collateralToken;   // Address of the collateral token
        uint256 collateralAmount;  // Total amount of collateral deposited in the vault
        uint256 yieldRate;         // Yield rate for the vault
    }

    // Mapping to store vaults, keyed by the collateral token address
    mapping(address => Vault) public vaults;
    // Mapping to store user balances, keyed by user address
    mapping(address => uint256) public userBalances;

    // The Janus token used for yield rewards
    ERC20 public janusToken;

    // Event emitted when a vault is created
    event VaultCreated(address indexed vaultAddress, address collateralToken, uint256 yieldRate);
    // Event emitted when collateral is deposited into a vault
    event CollateralDeposited(address indexed user, address vaultAddress, uint256 amount);
    // Event emitted when yield is claimed by a user
    event YieldClaimed(address indexed user, uint256 amount);

    /// @dev Constructor to initialize the JanusMainProtocol contract with the Janus token address.
    /// @param _janusToken Address of the Janus token contract.
    constructor(address _janusToken) {
        janusToken = ERC20(_janusToken);
    }

    /// @dev Function to create a new vault.
    /// @param collateralToken Address of the collateral token.
    /// @param yieldRate Yield rate for the vault.
    function createVault(address collateralToken, uint256 yieldRate) external onlyOwner {
        Vault storage vault = vaults[collateralToken];
        vault.collateralToken = collateralToken;
        vault.yieldRate = yieldRate;
        emit VaultCreated(collateralToken, collateralToken, yieldRate);
    }

    /// @dev Function for users to deposit collateral into a vault.
    /// @param collateralToken Address of the collateral token.
    /// @param amount Amount of collateral to deposit.
    function depositCollateral(address collateralToken, uint256 amount) external {
        require(vaults[collateralToken].collateralToken != address(0), "Vault does not exist");
        
        // Transfer the collateral tokens from the user to this contract
        ERC20(collateralToken).transferFrom(msg.sender, address(this), amount);
        
        // Update the user's balance and the vault's collateral amount
        userBalances[msg.sender] += amount;
        vaults[collateralToken].collateralAmount += amount;
        
        // Emit an event for the deposit
        emit CollateralDeposited(msg.sender, collateralToken, amount);
    }

    /// @dev Function for users to claim their yield rewards.
    /// @param collateralToken Address of the collateral token for which yield is claimed.
    function claimYield(address collateralToken) external {
        uint256 userBalance = userBalances[msg.sender];
        require(userBalance > 0, "No collateral deposited");
        
        // Calculate the yield based on the user's balance and the vault's yield rate
        uint256 yield = (userBalance * vaults[collateralToken].yieldRate) / 100;
        
        // Transfer the yield in Janus tokens to the user
        janusToken.transfer(msg.sender, yield);
        
        // Emit an event for the yield claim
        emit YieldClaimed(msg.sender, yield);
    }
}
