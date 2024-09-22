// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Oracle
/// @dev This contract is an oracle that fetches price data from a Chainlink Price Feed.
///      It is also Ownable, meaning it has an owner that can manage its access.
contract Oracle is Ownable {
    // The Chainlink AggregatorV3Interface used to fetch price data.
    AggregatorV3Interface internal priceFeed;

    /// @dev Constructor to initialize the Oracle contract with the Chainlink Price Feed address.
    /// @param _priceFeed Address of the Chainlink Price Feed contract.
    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    /// @dev Function to retrieve the latest price from the Chainlink Price Feed.
    /// @return The latest price as an integer.
    function getPrice() external view returns (int) {
        // Fetching the latest round data from the price feed.
        (, int price, , ,) = priceFeed.latestRoundData();
        // Returning the price fetched.
        return price;
    }
}
