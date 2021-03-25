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

	// Create a league with user 1
	g.
		TransactionFromFile("league/create_league").
		SignProposeAndPayAs("user_1").
		RunPrintEvents(ignoreFields)

	// Create a team with user 1
	g.
		TransactionFromFile("team/create_team").
		StringArgument("Huge Beauts").
		SignProposeAndPayAs("user_1").
		RunPrintEvents(ignoreFields)

	// Request to register the team to the league
	g.
		TransactionFromFile("team/register_team").
		SignProposeAndPayAs("user_1").
		RunPrintEvents(ignoreFields)

	// Check the team IDs registered to the league
	g.
		ScriptFromFile("league/get_team_info").
		AccountArgument("user_1").
		Run()

	// // Remove the team from the league
	// g.
	// 	TransactionFromFile("team/remove_team").
	// 	UInt64Argument(0).
	// 	SignProposeAndPayAs("user_1").
	// 	RunPrintEvents(ignoreFields)

	// // Check the team IDs registered to the league
	// g.
	// 	ScriptFromFile("league/get_team_ids").
	// 	AccountArgument("user_1").
	// 	Run()

}
