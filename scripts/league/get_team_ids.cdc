// get_team_ids.cdc

// returns an array of Team IDs that belong to the League

import Athletaverse from 0x01cf0e2f2f715450
import AthletaverseLeague from 0x01cf0e2f2f715450

pub fun main(account: Address, leagueID: UInt64) {

    let account = getAccount(account)

    let collection = account.getCapability
        <&AthletaverseLeague.Collection{AthletaverseLeague.CollectionPublic}>
        (AthletaverseLeague.leagueCollectionPublicPath)
        .borrow() ?? panic("could not borrow a reference to the CollectionPublic interface")

    let league = collection.borrowLeague(id: leagueID)

    log(league!.getTeamIDs())
}