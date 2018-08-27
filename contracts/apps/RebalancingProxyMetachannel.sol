pragma solidity 0.4.24;
pragma experimental "ABIEncoderV2";

import "../Registry.sol";
import "../lib/Transfer.sol";
import "../MetachannelMultisig.sol";


/*
- ETH only
- 2 users only
*/
contract RebalancingProxyMetachannel {

  struct AppState {
    address registryAddr;
    bytes32 observedCfAddr;
    address[2] beneficiaries;
    uint256 deadline;
  }

  function resolve(AppState state, Transfer.Terms terms)
    public
    view
    returns (Transfer.Details)
  {

    Registry registry = Registry(state.registryAddr);
    MetachannelMultisig mm = MetachannelMultisig(
      registry.resolver(state.observedCfAddr)
    );
    if (now < state.deadline) {
      require(
        mm.isFinal(),
        "RebalancingProxyMetachannel is not allowed to close on a non-final Metachannel Multisig before deadline"
      );
    }

    uint256 aBal = mm.aBal();

    require(aBal <= terms.limit);

    uint256[] memory amounts = new uint256[](2);
    amounts[0] = aBal;
    amounts[1] = terms.limit - aBal;

    address[] memory to = new address[](2);
    to[0] = state.beneficiaries[0];
    to[1] = state.beneficiaries[1];

    bytes memory data;

    return Transfer.Details(
      terms.assetType,
      terms.token,
      to,
      amounts,
      data
    );
  }
}
