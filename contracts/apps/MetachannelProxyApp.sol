pragma solidity 0.4.24;
pragma experimental "ABIEncoderV2";

import "../lib/Transfer.sol";
import "../Registry.sol";
import "../MetachannelMultisig.sol";


/*
Proxy Contract used to implement two-party metachannels

This has not been tested, or even compiled
*/
contract MetachannelProxyApp {

  struct AppState {
    bytes32 observedCfAddr; // cfAddr of the observed metachannel multisig contract
    uint256 deadline;
    address registryAddr;
    address[2] beneficiaries;
  }

  function resolve(AppState state, Transfer.Terms terms)
    public
    view
    returns (Transfer.Details)
  {

    Registry registry = Registry(state.registryAddr);

    address observedAddr = registry.resolver(state.observedCfAddr);

    MetachannelMultisig mm = MetachannelMultisig(observedAddr);

    bytes memory data;

    if (mm.balance(terms) == 0 && !mm.isFinal()) {
      return Transfer.Details(
        terms.assetType,
        terms.token,
        Transfer.address1(observedAddr),
        Transfer.uint256_1(terms.limit),
        data
      );
    }

    if (!(mm.isFinal() && now < state.deadline && mm.balance(terms) >= terms.limit)) {
      revert();
    }

    if (mm.isFinal()) {
      uint256 a = mm.aBal();

      return Transfer.Details(
        terms.assetType,
        terms.token,
        Transfer.address2(state.beneficiaries[0], state.beneficiaries[1]),
        Transfer.uint256_2(a, terms.limit - a),
        abi.encode(state.beneficiaries[0]) // used to set sender
      );
    }

    if (!mm.isFinal() && now >= state.deadline && mm.balance(terms) >= terms.limit) {
      // assume addresses are ordered by <

      address mmSender = mm.sender();
      if (state.beneficiaries[0] < mmSender) {

        return Transfer.Details(
          terms.assetType,
          terms.token,
          Transfer.address1(state.beneficiaries[1]),
          Transfer.uint256_1(terms.limit),
          data
        );
      }
      if (state.beneficiaries[0] > mmSender) {

        return Transfer.Details(
          terms.assetType,
          terms.token,
          Transfer.address1(state.beneficiaries[0]),
          Transfer.uint256_1(terms.limit),
          data
        );
      }
    }

    revert("error: exhaustive case match did not match");
  }

}
