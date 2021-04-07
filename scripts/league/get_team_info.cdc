// get_team_ids.cdc

// returns an array of Team IDs that belong to the League

import Athletaverse from 0x01cf0e2f2f715450
import AthletaverseLeague from 0x01cf0e2f2f715450



pub fun main(account: Address, leagueID: UInt64) {

    let account = getAccount(account)

    let collectionRef = account.getCapability
        <&AthletaverseLeague.Collection{AthletaverseLeague.CollectionPublic}>
        (AthletaverseLeague.leagueCollectionPublicPath)
        .borrow() ?? panic("could not borrow a reference to the public League Collection")

    let league = collectionRef.borrowLeague(id: leagueID) ?? panic("league does not exist")

    log(league.getTeamInfo())
}