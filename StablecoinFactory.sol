// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title StablecoinFactory
/// @dev This contract allows the creation and management of stablecoins backed by collateral tokens.
contract StablecoinFactory is Ownable {

    /// @dev Structure to store information about each stablecoin.
    struct Stablecoin {
        address tokenAddress;       // Address of the stablecoin ERC20 token
        address collateralToken;    // Address of the collateral token used to back the stablecoin
        uint256 targetPrice;        // Target price for the stablecoin
    }

    // Mapping to store stablecoins, keyed by their name
    mapping(string => Stablecoin) public stablecoins;

    // Reference to the JanusMainProtocol contract
    JanusMainProtocol public janusMainProtocol;

    // Event emitted when a new stablecoin is created
    event StablecoinCreated(string indexed name, address tokenAddress, address collateralToken, uint256 targetPrice);

    /// @dev Constructor to initialize the StablecoinFactory with the JanusMainProtocol contract address.
    /// @param _janusMainProtocol Address of the JanusMainProtocol contract.
    constructor(address _janusMainProtocol) {
        janusMainProtocol = JanusMainProtocol(_janusMainProtocol);
    }

    /// @dev Function to create a new stablecoin.
    /// @param name Name of the stablecoin.
    /// @param collateralToken Address of the collateral token.
    /// @param targetPrice Target price for the stablecoin.
    function createStablecoin(string memory name, address collateralToken, uint256 targetPrice) external onlyOwner {
        // Create a new ERC20 token for the stablecoin
        ERC20 stablecoin = new ERC20(name, name);
        // Store the stablecoin details in the mapping
        stablecoins[name] = Stablecoin(address(stablecoin), collateralToken, targetPrice);
        // Emit an event for the creation of the stablecoin
        emit StablecoinCreated(name, address(stablecoin), collateralToken, targetPrice);
    }

    /// @dev Function to mint new stablecoins by depositing collateral.
    /// @param name Name of the stablecoin.
    /// @param amount Amount of collateral to deposit.
    function mintStablecoin(string memory name, uint256 amount) external {
        // Get the stablecoin details from the mapping
        Stablecoin storage stablecoin = stablecoins[name];
        // Ensure the stablecoin exists
        require(stablecoin.tokenAddress != address(0), "Stablecoin does not exist");

        // Deposit the collateral into the JanusMainProtocol contract
        janusMainProtocol.depositCollateral(stablecoin.collateralToken, amount);
        // Transfer the newly minted stablecoins to the user
        ERC20(stablecoin.tokenAddress).transfer(msg.sender, amount);
    }
}
