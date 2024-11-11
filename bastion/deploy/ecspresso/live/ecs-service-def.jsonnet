local capacityProviderStrategy = import 'libsonnet/servicedef/capacityProviderStrategy.libsonnet';
local networkConfiguration = import 'libsonnet/servicedef/networkConfiguration.libsonnet';
{
  deploymentConfiguration: {
    deploymentCircuitBreaker: {
      enable: true,
      rollback: true,
    },
    maximumPercent: 200,
    minimumHealthyPercent: 50,
  },
  desiredCount: 0,
  enableECSManagedTags: false,
  capacityProviderStrategy: capacityProviderStrategy,
  networkConfiguration: networkConfiguration,
  placementConstraints: [],
  placementStrategy: [],
  platformVersion: '1.4.0',
  schedulingStrategy: 'REPLICA',
  serviceRegistries: [],
  enableExecuteCommand: true,
}
