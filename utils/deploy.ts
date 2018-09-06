export function deployTruffleArtifacts(
  loader: ArtifactsLoader,
  deployer: TruffleDeployer
) {
  const Registry = loader.require("Registry");
  const NonceRegistry = loader.require("NonceRegistry");
  const ConditionalTransfer = loader.require("ConditionalTransfer");
  const VirtualAppAgreement = loader.require("VirtualAppAgreement");
  const ProxyFactory = loader.require("ProxyFactory");
  const MultiSend = loader.require("MultiSend");
  const StateChannelAdjudicator = loader.require("StateChannelAdjudicator");
  const StaticCall = loader.require("StaticCall");
  const Signatures = loader.require("Signatures");
  const Conditional = loader.require("Conditional");
  const Transfer = loader.require("Transfer");

  deployer.deploy(Transfer).then(() => {
    deployer.link(Transfer, [VirtualAppAgreement, ConditionalTransfer]);
  });

  deployer.deploy(StaticCall).then(() => {
    deployer.link(StaticCall, [
      ConditionalTransfer,
      Conditional,
      StateChannelAdjudicator
    ]);
  });

  deployer.deploy(Signatures).then(() => {
    deployer.link(StaticCall, [StateChannelAdjudicator]);
  });

  deployer.deploy(NonceRegistry);
  deployer.deploy(MultiSend);
  deployer.deploy(ProxyFactory);
  deployer.deploy(Registry);

  deployer.deploy(ConditionalTransfer);
}
