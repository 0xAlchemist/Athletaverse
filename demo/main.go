package main

import (
	"github.com/bjartek/go-with-the-flow/gwtf"
)

func main() {
	g := gwtf.
		NewGoWithTheFlowEmulator().
		CreateAccountPrintEvents("user_1", "user_2")

	var ignoreFields = map[string][]string{
		"flow.AccountCodeUpdated": {"codeHash"},
		"flow.AccountKeyAdded":    {"publicKey"},
	}

	// Minting test Flow tokens for "user_1"
	g.
		TransactionFromFile("emulator/mintFlowTokens").
		AccountArgument("user_1").
		UFix64Argument("1000.0").
		SignProposeAndPayAs("emulator-account")

	// Minting test Flow tokens for "user_2"
	g.
		TransactionFromFile("emulator/mintFlowTokens").
		AccountArgument("user_2").
		UFix64Argument("1000.0").
		SignProposeAndPayAs("emulator-account")

	// Request a league minter for user 1
	g.
		TransactionFromFile("league/request_league_minter").
		SignProposeAndPayAs("user_1").
		RunPrintEvents(ignoreFields)

	// Approve league minter for user 1
	g.
		TransactionFromFile("league/approve_league_minter").
		AccountArgument("user_1").
		SignProposeAndPayAs("athletaverse").
		RunPrintEvents(ignoreFields)

	// Create a league with user 1
	g.
		TransactionFromFile("league/create_league").
		SignProposeAndPayAs("user_1").
		RunPrintEvents(ignoreFields)

	// Setup team minter for user 2
	g.
		TransactionFromFile("team/setup/setup_team_minter").
		SignProposeAndPayAs("user_2").
		RunPrintEvents(ignoreFields)

	// Create a team with user 2
	g.
		TransactionFromFile("team/create/create_team").
		StringArgument("Huge Beauts").
		SignProposeAndPayAs("user_2").
		RunPrintEvents(ignoreFields)

	// Request to register the team to the league
	g.
		TransactionFromFile("team/manage/register_team").
		AccountArgument("user_1").
		UInt64Argument(1).
		UInt64Argument(1).
		SignProposeAndPayAs("user_2").
		RunPrintEvents(ignoreFields)

	// Request to register the team to the league
	g.
		TransactionFromFile("league/approve_team").
		UInt64Argument(1).
		UInt64Argument(1).
		SignProposeAndPayAs("user_1").
		RunPrintEvents(ignoreFields)

	// Check the team IDs registered to the league
	g.
		ScriptFromFile("league/get_team_info").
		AccountArgument("user_1").
		UInt64Argument(1).
		Run()

	// Remove the team from the league
	g.
		TransactionFromFile("team/manage/remove_team").
		UInt64Argument(1).
		UInt64Argument(1).
		SignProposeAndPayAs("user_1").
		RunPrintEvents(ignoreFields)

	// Check the team IDs registered to the league
	g.
		ScriptFromFile("league/get_team_ids").
		AccountArgument("user_1").
		UInt64Argument(1).
		Run()

}