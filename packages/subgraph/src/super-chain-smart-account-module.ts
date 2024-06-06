import {
  EIP712DomainChanged as EIP712DomainChangedEvent,
  OwnerAdded as OwnerAddedEvent,
  OwnerPopulated as OwnerPopulatedEvent,
  OwnershipTransferred as OwnershipTransferredEvent,
  PointsIncremented as PointsIncrementedEvent,
} from '../generated/SuperChainSmartAccountModule/SuperChainSmartAccountModule';
import {
  EIP712DomainChanged,
  OwnerAdded,
  OwnerPopulated,
  OwnershipTransferred,
  PointsIncremented,
} from '../generated/schema';

export function handleEIP712DomainChanged(
  event: EIP712DomainChangedEvent
): void {
  let entity = new EIP712DomainChanged(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleOwnerAdded(event: OwnerAddedEvent): void {
  let entity = new OwnerAdded(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.safe = event.params.safe;
  entity.newOwner = event.params.newOwner;
  entity.superChainId = event.params.superChainId.toString();

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleOwnerPopulated(event: OwnerPopulatedEvent): void {
  let entity = new OwnerPopulated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.safe = event.params.safe;
  entity.newOwner = event.params.newOwner;
  entity.superChainId = event.params.superChainId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleOwnershipTransferred(
  event: OwnershipTransferredEvent
): void {
  let entity = new OwnershipTransferred(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.previousOwner = event.params.previousOwner;
  entity.newOwner = event.params.newOwner;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handlePointsIncremented(event: PointsIncrementedEvent): void {
  let entity = new PointsIncremented(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.recipient = event.params.recipient;
  entity.points = event.params.points;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}
