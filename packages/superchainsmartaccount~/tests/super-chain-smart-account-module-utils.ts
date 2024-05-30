import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  EIP712DomainChanged,
  OwnerAdded,
  OwnerPopulated,
  OwnershipTransferred,
  PointsIncremented
} from "../generated/SuperChainSmartAccountModule/SuperChainSmartAccountModule"

export function createEIP712DomainChangedEvent(): EIP712DomainChanged {
  let eip712DomainChangedEvent = changetype<EIP712DomainChanged>(newMockEvent())

  eip712DomainChangedEvent.parameters = new Array()

  return eip712DomainChangedEvent
}

export function createOwnerAddedEvent(
  safe: Address,
  newOwner: Address,
  superChainId: string
): OwnerAdded {
  let ownerAddedEvent = changetype<OwnerAdded>(newMockEvent())

  ownerAddedEvent.parameters = new Array()

  ownerAddedEvent.parameters.push(
    new ethereum.EventParam("safe", ethereum.Value.fromAddress(safe))
  )
  ownerAddedEvent.parameters.push(
    new ethereum.EventParam("newOwner", ethereum.Value.fromAddress(newOwner))
  )
  ownerAddedEvent.parameters.push(
    new ethereum.EventParam(
      "superChainId",
      ethereum.Value.fromString(superChainId)
    )
  )

  return ownerAddedEvent
}

export function createOwnerPopulatedEvent(
  safe: Address,
  newOwner: Address,
  superChainId: string
): OwnerPopulated {
  let ownerPopulatedEvent = changetype<OwnerPopulated>(newMockEvent())

  ownerPopulatedEvent.parameters = new Array()

  ownerPopulatedEvent.parameters.push(
    new ethereum.EventParam("safe", ethereum.Value.fromAddress(safe))
  )
  ownerPopulatedEvent.parameters.push(
    new ethereum.EventParam("newOwner", ethereum.Value.fromAddress(newOwner))
  )
  ownerPopulatedEvent.parameters.push(
    new ethereum.EventParam(
      "superChainId",
      ethereum.Value.fromString(superChainId)
    )
  )

  return ownerPopulatedEvent
}

export function createOwnershipTransferredEvent(
  previousOwner: Address,
  newOwner: Address
): OwnershipTransferred {
  let ownershipTransferredEvent = changetype<OwnershipTransferred>(
    newMockEvent()
  )

  ownershipTransferredEvent.parameters = new Array()

  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam(
      "previousOwner",
      ethereum.Value.fromAddress(previousOwner)
    )
  )
  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam("newOwner", ethereum.Value.fromAddress(newOwner))
  )

  return ownershipTransferredEvent
}

export function createPointsIncrementedEvent(
  recipient: Address,
  points: BigInt
): PointsIncremented {
  let pointsIncrementedEvent = changetype<PointsIncremented>(newMockEvent())

  pointsIncrementedEvent.parameters = new Array()

  pointsIncrementedEvent.parameters.push(
    new ethereum.EventParam("recipient", ethereum.Value.fromAddress(recipient))
  )
  pointsIncrementedEvent.parameters.push(
    new ethereum.EventParam("points", ethereum.Value.fromUnsignedBigInt(points))
  )

  return pointsIncrementedEvent
}
