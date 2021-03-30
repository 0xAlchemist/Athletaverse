// get_request_ids.cdc

// returns an array of Team IDs that have requested to register to the League

// TODO: Add this method back to Leagues!

import Athletaverse from 0x01cf0e2f2f715450
import AthletaverseLeague from 0x01cf0e2f2f715450

pub fun main(account: Address) {

    let account = getAccount(account)

    let leagueCapability = account.getCapability(/public/AthletaverseLeague)

    let leagueReference = leagueCapability.borrow<&AthletaverseLeague.League>()
    ?? panic("unable to borrow the League reference")

    log(leagueReference.getRequestIDs())
}