"use strict";


var g_ScoreboardHandle = null;


function SetFlyoutScoreboardVisible( bVisible )
{
	$.GetContextPanel().SetHasClass( "flyout_scoreboard_visible", bVisible );
	if ( bVisible )
	{
		ScoreboardUpdater_SetScoreboardActive( g_ScoreboardHandle, true );
	}
	else
	{
		ScoreboardUpdater_SetScoreboardActive( g_ScoreboardHandle, false );
	}
}

function OnKillEvent( event )
{

	var containerPanel = $( "#TeamsContainer" );
	var teamId = event.victim_team_id
	var teamPanelName = "_dynamic_team_" + teamId;
	var teamPanel = containerPanel.FindChild( teamPanelName );
	var playersContainer = teamPanel.FindChildInLayoutFile( "PlayersContainer" );

	var playerPanelName = "_dynamic_player_" + event.victim_id;

	var playerPanel = playersContainer.FindChild( playerPanelName );

	if (playerPanelName !== null){
		var childPanel = playerPanel.FindChildInLayoutFile( "DeathsContainer" );
		var panel = childPanel.FindChildInLayoutFile( "Deaths" );
		panel.text = parseInt(panel.text) + 1;
	}
	
	var containerPanel = $( "#TeamsContainer" );
	var teamId = event.team_id
	var teamPanelName = "_dynamic_team_" + teamId;
	var teamPanel = containerPanel.FindChild( teamPanelName );
	var playersContainer = teamPanel.FindChildInLayoutFile( "PlayersContainer" );
	var playerPanelName = "_dynamic_player_" + event.killer_id;
	if (playerPanelName != null){
		var playerPanel = playersContainer.FindChild( playerPanelName );
		var childPanel = playerPanel.FindChildInLayoutFile( "KillsContainer" );
		var panel = childPanel.FindChildInLayoutFile( "Kills" );
		panel.text = parseInt(panel.text) + 1;
	}
}

function OnLastHitEvent( event )
{

	var containerPanel = $( "#TeamsContainer" );
	var teamId = event.team_id
	var teamPanelName = "_dynamic_team_" + teamId;
	var teamPanel = containerPanel.FindChild( teamPanelName );
	var teamPlayers = Game.GetPlayerIDsOnTeam( teamId );
	var playersContainer = teamPanel.FindChildInLayoutFile( "PlayersContainer" );
	var playerPanelName = "_dynamic_player_" + event.killer_id;
	var playerPanel = playersContainer.FindChild( playerPanelName );
	if (playerPanel != null){
		var childPanel = playerPanel.FindChildInLayoutFile( "LastHitsContainer" );
		var panel = childPanel.FindChildInLayoutFile( "LastHits" );
		panel.text = parseInt(panel.text) + 1;
	}

}

function OnDenyEvent( event )
{
	var containerPanel = $( "#TeamsContainer" );
	var teamId = event.team_id
	var teamPanelName = "_dynamic_team_" + teamId;
	var teamPanel = containerPanel.FindChild( teamPanelName );
	var teamPlayers = Game.GetPlayerIDsOnTeam( teamId );
	var playersContainer = teamPanel.FindChildInLayoutFile( "PlayersContainer" );
	var playerPanelName = "_dynamic_player_" + event.killer_id;
	var playerPanel = playersContainer.FindChild( playerPanelName );
	if (playerPanel != null){
		var childPanel = playerPanel.FindChildInLayoutFile( "DeniesContainer" );
		var panel = childPanel.FindChildInLayoutFile( "Denies" );
		panel.text = parseInt(panel.text) + 1;
	}
}


function OnHeroInGame( event )
{
	var scoreboardConfig =
	{
		"teamXmlName" : "file://{resources}/layout/custom_game/multiteam_flyout_scoreboard_team.xml",
		"playerXmlName" : "file://{resources}/layout/custom_game/multiteam_flyout_scoreboard_player.xml",
	};
	g_ScoreboardHandle = ScoreboardUpdater_InitializeScoreboard( scoreboardConfig, $( "#TeamsContainer" ) );

	var assistsData = event[2]
	var teamData = event[1]
	var count = event[3]

	for (var i = 0; i < count; ++i) 
		{
			var containerPanel = $( "#TeamsContainer" );
		    var teamId = teamData[i+1]
		    var teamPanelName = "_dynamic_team_" + teamId;
		    var teamPanel = containerPanel.FindChild( teamPanelName );
		    var teamPlayers = Game.GetPlayerIDsOnTeam( teamId );
		    var playersContainer = teamPanel.FindChildInLayoutFile( "PlayersContainer" );
		    var playerPanelName = "_dynamic_player_" + (i);
		    var playerPanel = playersContainer.FindChild( playerPanelName );
		    if (playerPanel != null) {
		    	  var childPanel = playerPanel.FindChildInLayoutFile( "AssistsContainer" );
		    	var panel = childPanel.FindChildInLayoutFile( "Assists" );
		    	panel.text = parseInt(assistsData[i+1]);
		    }
		 
		}
}




(function()
{
	if ( ScoreboardUpdater_InitializeScoreboard === null ) { $.Msg( "WARNING: This file requires shared_scoreboard_updater.js to be included." ); }

	var scoreboardConfig =
	{
		"teamXmlName" : "file://{resources}/layout/custom_game/multiteam_flyout_scoreboard_team.xml",
		"playerXmlName" : "file://{resources}/layout/custom_game/multiteam_flyout_scoreboard_player.xml",
	};
	g_ScoreboardHandle = ScoreboardUpdater_InitializeScoreboard( scoreboardConfig, $( "#TeamsContainer" ) );
	
	SetFlyoutScoreboardVisible( false );

	$.RegisterEventHandler( "DOTACustomUI_SetFlyoutScoreboardVisible", $.GetContextPanel(), SetFlyoutScoreboardVisible );

	GameEvents.Subscribe( "hero_killed", OnKillEvent );
	GameEvents.Subscribe( "lasthit", OnLastHitEvent );
	GameEvents.Subscribe( "deny", OnDenyEvent );
	GameEvents.Subscribe( "initiate", OnHeroInGame );
})();
