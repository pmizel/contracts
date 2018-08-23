pragma solidity 0.4.24;
pragma experimental "ABIEncoderV2";

import "./lib/Signatures.sol";
import "./lib/Transfer.sol";


contract MetachannelMultisig {

  // all stubs

  function balance(Transfer.Terms) public view returns (uint256) {
    return 42;
  }

  function isFinal() public view returns (bool) {
    return false;
  }

  function aBal() public view returns (uint256) {
    return 5;
  }

  function sender() public view returns (address) {
    return this;
  }

}
