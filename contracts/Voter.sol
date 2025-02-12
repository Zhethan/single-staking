// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@ubeswap/governance/contracts/interfaces/IVotingDelegates.sol";

import "./interfaces/IRomulusDelegate.sol";

contract Voter is Ownable {
  using SafeERC20 for IERC20;

  IVotingDelegates public immutable votingToken;
  IRomulusDelegate public immutable romulusDelegate;

  constructor(
    IVotingDelegates _votingToken,
    IRomulusDelegate _romulusDelegate
  ) {
    votingToken = _votingToken;
    romulusDelegate = _romulusDelegate;

    _votingToken.delegate(address(this));
  }

  /**
   * @notice Transfers voting tokens from 'msg.sender' to this voter
   * @param amount The amount of voting tokens to transfer
   */
  function addVotes(uint256 amount) external onlyOwner {
    IERC20(address(votingToken)).safeTransferFrom(
      msg.sender,
      address(this),
      amount
    );
  }

  /**
   * @notice Transfers voting tokens from this voter to 'msg.sender' 
   * @param amount The amount of voting tokens to transfer
   */
  function removeVotes(uint256 amount) external onlyOwner {
    IERC20(address(votingToken)).safeTransfer(msg.sender, amount);
  }

  /** 
   * @notice Casts vote for/against/abstain proposal of voter
   * @param proposalId id of the proposal to vote for/against/abstain
   * @param support - If 0, vote against - If 1, vote for - If 2, abstain
   */
  function castVote(uint256 proposalId, uint8 support) external onlyOwner {
    romulusDelegate.castVote(proposalId, support);
  }

  /// @notice Creates a proposal from this voter
  function propose(
    address[] memory targets,
    uint256[] memory values,
    string[] memory signatures,
    bytes[] memory calldatas,
    string memory description
    ) external onlyOwner {
      romulusDelegate.propose(
      targets,
      values,
      signatures,
      calldatas,
      description
    );
  }

  /**
   * @notice Delegate votes of voter to `delegatee`
   * @param delegatee The address to delegate votes to
   */
  function delegate(address delegatee) external onlyOwner {
    votingToken.delegate(delegatee);
  }
}
