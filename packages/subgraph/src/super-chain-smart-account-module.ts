import {
  EIP712DomainChanged as EIP712DomainChangedEvent,
  OwnerAdded as OwnerAddedEvent,
  OwnerPopulated as OwnerPopulatedEvent,
  OwnerPopulationRemoved as OwnerPopulationRemovedEvent,
  PointsIncremented as PointsIncrementedEvent,
  SuperChainSmartAccountCreated as SuperChainSmartAccountCreatedEvent,
  NounUpdated as NounUpdatedEvent,
} from "../generated/SuperChainSmartAccountModule/SuperChainSmartAccountModule";
import {
  EIP712DomainChanged,
  OwnerAdded,
  OwnerPopulated,
  PointsIncremented,
  OwnerPopulationRemoved,
  SuperChainSmartAccount,
  Meta,
} from "../generated/schema";
import { BigInt, store } from "@graphprotocol/graph-ts";

export function handleEIP712DomainChanged(
  event: EIP712DomainChangedEvent,
): void {
  let entity = new EIP712DomainChanged(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  );

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleOwnerAdded(event: OwnerAddedEvent): void {
  let entity = new OwnerAdded(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  );
  entity.safe = event.params.safe;
  entity.newOwner = event.params.newOwner;
  entity.superChainId = event.params.superChainId.toString();

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;
  let superChainSmartAccount = SuperChainSmartAccount.load(entity.safe);
  if (superChainSmartAccount == null) {
    superChainSmartAccount = new SuperChainSmartAccount(entity.safe);
  }
  entity.superChainSmartAccount = superChainSmartAccount.id;
  entity.save();
  let entityId = event.params.safe.concat(event.params.newOwner);
  let populatedEntity = OwnerPopulated.load(entityId);
  if (populatedEntity != null) {
    store.remove("OwnerPopulated", entityId.toHexString());
  }
}

export function handleOwnerPopulated(event: OwnerPopulatedEvent): void {
  let entityId = event.params.safe.concat(event.params.newOwner);
  let entity = new OwnerPopulated(entityId);
  let meta = Meta.load("OwnerPopulated");
  if (meta == null) {
    meta = new Meta("OwnerPopulated");
    meta.count = BigInt.fromI32(0);
  }
  meta.count = meta.count.plus(BigInt.fromI32(1));
  meta.save();
  entity.safe = event.params.safe;
  entity.newOwner = event.params.newOwner;
  entity.superChainId = event.params.superChainId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;
  let superChainSmartAccount = SuperChainSmartAccount.load(entity.safe);
  if (superChainSmartAccount == null) {
    superChainSmartAccount = new SuperChainSmartAccount(entity.safe);
  }
  entity.superChainSmartAccount = superChainSmartAccount.id;
  entity.save();
}

export function handleOwnerPopulationRemoved(
  event: OwnerPopulationRemovedEvent,
): void {
  let entity = new OwnerPopulationRemoved(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  );
  let meta = Meta.load("OwnerPopulated");
  if (meta == null) {
    meta = new Meta("OwnerPopulated");
    meta.count = BigInt.fromI32(0);
  }
  meta.count = meta.count.minus(BigInt.fromI32(1));
  meta.save();

  entity.safe = event.params.safe;
  entity.owner = event.params.owner;
  entity.superChainId = event.params.superChainId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;
  let superChainSmartAccount = SuperChainSmartAccount.load(entity.safe);
  if (superChainSmartAccount == null) {
    superChainSmartAccount = new SuperChainSmartAccount(entity.safe);
  }
  entity.superChainSmartAccount = superChainSmartAccount.id;
  entity.save();
  let entityId = event.params.safe.concat(event.params.owner);
  let populatedEntity = OwnerPopulated.load(entityId);
  if (populatedEntity != null) {
    store.remove("OwnerPopulated", entityId.toHexString());
  }
}

export function handlePointsIncremented(event: PointsIncrementedEvent): void {
  let entity = new PointsIncremented(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  );
  entity.recipient = event.params.recipient;
  entity.points = event.params.points;
  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;
  let superChainSmartAccount = SuperChainSmartAccount.load(entity.recipient);
  if (superChainSmartAccount == null) {
    superChainSmartAccount = new SuperChainSmartAccount(entity.recipient);
  }
  superChainSmartAccount.points = superChainSmartAccount.points.plus(
    entity.points,
  );
  if(event.params.levelUp){
    superChainSmartAccount.level = superChainSmartAccount.level.plus(BigInt.fromI32(1));
  }
  superChainSmartAccount.save();
  entity.superChainSmartAccount = superChainSmartAccount.id;
  entity.save();
}

export function handleSuperChainSmartAccountCreated(
  event: SuperChainSmartAccountCreatedEvent,
): void {
  let entity = new SuperChainSmartAccount(event.params.safe);
  entity.safe = event.params.safe;
  entity.initialOwner = event.params.initialOwner;
  entity.superChainId = event.params.superChainId;
  entity.noun_background = event.params.noun.background;
  entity.noun_body = event.params.noun.body;
  entity.noun_accessory = event.params.noun.accessory;
  entity.noun_head = event.params.noun.head;
  entity.noun_glasses = event.params.noun.glasses;
  entity.points = BigInt.fromI32(0);
  entity.level = BigInt.fromI32(0);

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleNounUpdated(event: NounUpdatedEvent): void {
  let entity = SuperChainSmartAccount.load(event.params.safe);
if(entity != null){
  entity.noun_background = event.params.noun.background;
    entity.noun_body = event.params.noun.body;
  entity.noun_accessory = event.params.noun.accessory;
  entity.noun_head = event.params.noun.head;
  entity.noun_glasses = event.params.noun.glasses;
  entity.save();
}
}