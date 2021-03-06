pragma solidity 0.4.24;
pragma experimental "ABIEncoderV2";

import "../lib/Transfer.sol";


contract ExampleTransfer {
  using Transfer for Transfer.Details;
  function transfer(Transfer.Details details) public {
    details.executeTransfer();
  }
}
