// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title DisperseOptimized
/// @notice Batch‐send Ether or any ERC20 in a single transaction, minimizing gas
import "./openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DisperseOptimized is ReentrancyGuard {
    event DispersedEther(uint256 totalAmount, uint256 recipientsCount);
    event DispersedToken(address indexed token, uint256 totalAmount, uint256 recipientsCount);

    /// @notice Disperse native ETH to multiple recipients
    /// @dev Uses `.call{value:…}("")` + nonReentrant + unchecked loops for gas savings
    /// @param recipients list of target addresses
    /// @param amounts list of wei amounts, same length as `recipients`
    function disperseEther(
        address payable[] calldata recipients,
        uint256[] calldata amounts
    ) external payable nonReentrant {
        uint256 len = recipients.length;
        require(len == amounts.length, "Arrays mismatch");
        uint256 totalSent = 0;
        for (uint256 i = 0; i < len; ) {
            uint256 amt = amounts[i];
            totalSent += amt;
            (bool ok, ) = recipients[i].call{value: amt}("");
            require(ok, "ETH transfer failed");
            unchecked { ++i; }
        }
        require(totalSent <= msg.value, "Too little ETH");
        // refund dust
        uint256 refund = msg.value - totalSent;
        if (refund > 0) {
            (bool ok, ) = msg.sender.call{value: refund}("");
            require(ok, "Refund failed");
        }
        emit DispersedEther(msg.value, len);
    }

    /// @notice Disperse an ERC20 token to multiple recipients
    /// @dev First does one transferFrom, then multiple transfers out
    /// @param token the ERC20 to disperse
    /// @param recipients list of target addresses
    /// @param amounts list of token amounts, same length as `recipients`
    function disperseToken(
        IERC20 token,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external nonReentrant {
        uint256 len = recipients.length;
        require(len == amounts.length, "Arrays mismatch");
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < len; ) {
            totalAmount += amounts[i];
            unchecked { ++i; }
        }
        require(token.transferFrom(msg.sender, address(this), totalAmount), "TransferFrom failed");
        for (uint256 i = 0; i < len; ) {
            require(token.transfer(recipients[i], amounts[i]), "Token transfer failed");
            unchecked { ++i; }
        }
        emit DispersedToken(address(token), totalAmount, len);
    }
}
