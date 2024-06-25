
import { BigInt, Bytes } from "@graphprotocol/graph-ts"
import {
    BadgeLevelSet as BadgeLevelSetEvent,
    BadgeLevelUpdated as BadgeLevelUpdatedEvent,
    BadgeMinted as BadgeMintedEvent,
} from "../generated/SuperChainBadges/SuperChainBadges"
import {
    BadgeTier, Badge, AccountBadge,
} from "../generated/schema"



export function handleBadgeLevelSet(event: BadgeLevelSetEvent): void {
    let entity = new BadgeTier(event.transaction.hash.concatI32(event.logIndex.toI32()))
    let badge = Badge.load(event.params.badgeId.toHexString())
    if (!badge) {
        badge = new Badge(event.params.badgeId.toHexString())
        badge.badgeId = event.params.badgeId
        badge.save()
    }

    entity.points = event.params.points
    entity.tier = event.params.level
    entity.badge = badge.id
    entity.uri = event.params.uri
    entity.save()

}

export function handleBadgeLevelUpdated(event: BadgeLevelUpdatedEvent): void {
    const accountBadgeId = event.params.user.concatI32(event.params.badgeId.toI32())
    let accountBadge = AccountBadge.load(accountBadgeId)
    if (!accountBadge) return
    accountBadge.tier = event.params.level
    accountBadge.points = event.params.points
    accountBadge.save()
}

export function handleBadgeMinted(event: BadgeMintedEvent): void {
    let entity = new AccountBadge(event.params.user.concatI32(event.params.badgeId.toI32()))
    let badge = Badge.load(event.params.badgeId.toHexString())
    if (!badge) {
        badge = new Badge(event.params.badgeId.toHexString())
    }

    entity.badge =  badge.id
    entity.tier = event.params.initialLevel
    entity.points = event.params.points
    entity.user = event.params.user
    entity.save()

}
