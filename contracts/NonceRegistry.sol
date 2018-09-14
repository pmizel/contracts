pragma solidity 0.4.24;
pragma experimental "ABIEncoderV2";


/// @title NonceRegistry - A global nonce time-lock registry. Maps nonce keys to nonce values.
/// @author Liam Horne - <liam@l4v.io>
/// @notice Supports a global mapping of sender, timeout and salt based keys to sequential nonces
/// A nonce (aka "dependency nonce") is a mapping from a nonce key to a nonce value which can be set 
/// under certain circumstances (to be defined later). A nonce is parametrized by the sender, the salt,
/// and the timeout. These parameters determine the nonce key. A nonce can only be set by its sender.
/// When a nonce is first set, a timer of length `timeout` starts. During this timeout period, it may
/// only be set to higher values; whenever it is set, the timer resets. When the timer finishes, the
/// nonce may no longer be set.
contract NonceRegistry {

  event NonceSet (bytes32 key, uint256 nonceValue);

  struct State {
    uint256 nonceValue;
    uint256 finalizesAt;
  }

  mapping(bytes32 => State) public table;

  /// @notice Determine whether a particular key has been set and finalized at a nonce
  /// @param key A unique entry in the mapping, computed using `computeKey`
  /// @param expectedNonceValue The nonce value that the key is expected to be finalized at
  /// @return A boolean referring to whether or not the key has been finalized at the nonce
  function isFinalized(bytes32 key, uint256 expectedNonceValue)
    external
    view
    returns (bool)
  {
    require(
      table[key].finalizesAt <= block.number,
      "Nonce is not yet finalized"
    );
    require(
      table[key].nonceValue == expectedNonceValue,
      "Nonce value is not equal to expected nonce value"
    );
    return true;
  }

  /// @notice Set a nonce in the mapping and triggers the timeout period to begin
  /// @param salt A salt used to generate the nonce key
  /// @param nonceValue A nonce at which to set the computed key's value in the mapping
  function setNonce(uint256 timeout, bytes32 salt, uint256 nonceValue) external {
    bytes32 key = computeKey(msg.sender, timeout, salt);
    require(
      table[key].nonceValue < nonceValue,
      "Cannot set nonce to a smaller value");
    require(
      table[key].finalizesAt == 0 || block.number < table[key].finalizesAt,
      "Nonce is already finalized"
    );
    table[key].nonceValue = nonceValue;
    table[key].finalizesAt = block.number + timeout;
    emit NonceSet(key, nonceValue);
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
