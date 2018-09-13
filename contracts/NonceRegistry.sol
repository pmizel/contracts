pragma solidity 0.4.24;
pragma experimental "ABIEncoderV2";


/// @title NonceRegistry - A global nonce time-lock registry. Maps nonce keys to nonce values.
/// @author Liam Horne - <liam@l4v.io>
/// @notice Supports a global mapping of sender and salt based keys to sequential nonces and the ability to consider a key "finalized" or not at a particular nonce
contract NonceRegistry {

  event NonceSet (bytes32 key, uint256 nonceValue);

  struct State {
    uint256 nonceValue;
    uint256 finalizesAt;
  }

  mapping(bytes32 => State) public table;

  /// @notice Determine whether a particular key has been set and finalized at a nonce
  /// @param key A unique entry in the mapping, computed using `computeKey`
  /// @param expectedNonce The nonce that the key is expected to be finalized at
  /// @return A boolean referring to whether or not the key has been finalized at the nonce
  function isFinalized(bytes32 key, uint256 expectedNonce)
    external
    view
    returns (bool)
  {
    require(
      table[key].finalizesAt <= block.number,
      "Nonce is not yet finalized"
    );
    require(
      table[key].nonceValue == expectedNonce,
      "Nonce is not equal to expectedNonce"
    );
    return true;
  }

  /// @notice Set a nonce in the mapping and triggers the timeout period to begin
  /// @param salt A salt used to generate the nonce key
  /// @param nonce A nonce at which to set the computed key's value in the mapping
  function setNonce(uint256 timeout, bytes32 salt, uint256 nonceValue) external {
    bytes32 key = computeKey(msg.sender, timeout, salt);
    require(table[key].nonceValue < nonceValue);
    table[key].nonceValue = nonceValue;
    table[key].finalizesAt = block.number + timeout;
    emit NonceSet(key, nonce);
  }

  /// @notice Computes a unique key for the particular salt and msg.sender
  /// @param salt A salt used to generate the nonce key
  /// @return A unique nonce key derived from the salt and msg.sender
  function computeKey(address sender, uint256 timeout, bytes32 salt)
    view
    internal
    returns (bytes32)
  {
    return keccak256(abi.encodePacked(sender, timeout, salt));
  }

}
