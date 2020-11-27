// get_team_ids.cdc

// returns an array of Team IDs that belong to the League

import Athletaverse from 0x01cf0e2f2f715450
pub fun main() {

    let account = getAccount(0x01cf0e2f2f715450)

    let leagueCapability = account.getCapability(/public/AthletaverseLeague)

    let leagueReference = leagueCapability?.borrow<&Athletaverse.League>()
    ?? panic("unable to borrow the League reference")

    log(leagueReference!.getTeamIDs())
}