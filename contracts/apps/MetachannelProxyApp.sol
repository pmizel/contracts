pragma solidity 0.4.24;
pragma experimental "ABIEncoderV2";

import "../lib/Transfer.sol";
import "../Registry.sol";

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

    Registry registry = Registry(registryAddr);

    address observedAddr = registry.resolver(observedCfAddr);

    MetachannelMultisig mm = MetachannelMultisig(observedAddr);

    address[] memory to = new address[](1);
    to[0] = mm.address;

    uint256[] memory amounts = new uint256[](1);
    amounts[0] = terms.limit;

    bytes memory data;

    if (mm.balance(terms.assetType, term.token) == 0 && !(mm.isFinal())) {
      return Transfer.Details(
        terms.assetType,
        terms.token,
        to,
        amounts,
        data;
      );
    }

    if (!(mm.isFinal() && now < state.deadline && mm.balance(terms.assetType, term.token) >= terms.limit)) {
      revert();
    }

    if (mm.isFinal()) {
      uint256 a = mm.aBal();

      uint256[] memory amounts = new uint256[](2);
      amounts[0] = a;
      amounts[1] = terms.limit - a;

      return Transfer.Details(
        terms.assetType,
        terms.token,
        beneficiaries,
        amounts,
        abi.encode(beneficiaries[0]); // used to set sender
      );
    }

    if (!(mm.isFinal()) && now >= state.deadline && mm.balance(terms.assetType, term.token) >= terms.limit) {
      // assume addresses are ordered by <

      uint256[] memory amounts = new uint256[](1);
      amounts[0] = terms.limit;
      address[] memory to = new address[](1);

      address mmSender = mm.sender();
      if (beneficiaries[0] < mmSender) {

        to[0] = beneficiaries[1];

        return Transfer.Details(
          terms.assetType,
          terms.token,
          beneficiaries,
          amounts,
          data
        );
      }
      if (beneficiaries[0] > mmSender) {

        to[0] = beneficiaries[0];

        return Transfer.Details(
          terms.assetType,
          terms.token,
          beneficiaries,
          amounts,
          data
        );
      }
    }

    revert("error: exhaustive case match did not match");
  }

}
