pragma solidity 0.4.24;
pragma experimental "ABIEncoderV2";

import "./lib/Signatures.sol";
import "./lib/Transfer.sol";


/*
Uses https://github.com/zeppelinos/labs/blob/master/upgradeability_using_unstructured_storage/contracts/UpgradeabilityProxy.sol
for the `aBal` "variable" to be accessible in contracts delegated to
*/
contract MetachannelMultisig {

  using Signatures for bytes;
  mapping(bytes32 => bool) isExecuted;
  address[2] private _owners;
  uint256 finalizesAt;

  /*
  client is responsible for making sure no applications
  have a timeout greater than this
  */
  uint256 _timeout;

  uint256 public aBal;

  function setup(address[2] owners, uint256 timeout) public {
    require(_owners.length == 0); // Contract hasn't been set up before
    _owners = owners;
    _timeout = timeout;
  }

  function isFinal() public view returns (bool) {
    return (now > finalizesAt);
  }

  function aBal() public view returns (uint256 ret) {
    bytes32 key = keccak256("org.counterfactual.MetachannelMultisig.aBal");
    assembly {
      ret := sload(key)
    }
  }

}
