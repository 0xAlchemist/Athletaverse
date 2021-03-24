// get_request_ids.cdc

// returns an array of Team IDs that have requested to register to the League

import Athletaverse from 0xf8d6e0586b0a20c7
import AthletaverseLeague from 0xf8d6e0586b0a20c7

pub fun main(account: Address) {

    let account = getAccount(account)

    let leagueCapability = account.getCapability(/public/AthletaverseLeague)

    let leagueReference = leagueCapability.borrow<&AthletaverseLeague.League>()
    ?? panic("unable to borrow the League reference")

    log(leagueReference!.getRequestIDs())
}