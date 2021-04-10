var Parent = $.GetContextPanel().GetParent().GetParent().GetParent();

function OverrideImage(hParent, sHeroName) {
	var newheroimage = $.CreatePanel('Panel', hParent, '');
	newheroimage.style.width = "100%";
	newheroimage.style.height = "100%";
	newheroimage.style.backgroundImage = 'url("file://{images}/heroes/' + sHeroName + '.png")';
	newheroimage.style.backgroundSize = "cover";
}

function OverrideTopBarHeroImage(args) {
//	$.Msg("OverrideTopBarHeroImage")
	var team = "Radiant"

	if (Players.GetTeam(args.player_id) == 3) {
		team = "Dire"
	}

	var container = Parent.FindChildTraverse(team + "Player" + args.player_id).FindChildTraverse("HeroImage");

	OverrideImage(container, args.icon_path);
}

function OverrideScoreboardHeroImage(args) {
//	$.Msg("OverrideScoreboardHeroImage")
	var team = "Radiant"

	if (Players.GetTeam(args.player_id) == 3) {
		team = "Dire"
	}

//	$.Msg(container.FindChildTraverse("AvatarImage").steamid) // ES note: if struggling finding the right player to apply the image, use this instead
	var team_container = Parent.FindChildTraverse(team + "TeamContainer");
	if (!team_container) {
		$.Schedule(1.0, function() {
			OverrideScoreboardHeroImage(args);
		})

		return;
	}

	var player_container = team_container.FindChildTraverse(team + "Player" + args.player_id);
	if (!player_container) {
		$.Schedule(1.0, function() {
			OverrideScoreboardHeroImage(args);
		})

		return;
	}

	var image_container = player_container.FindChildTraverse("HeroImage");
	if (!image_container) {
		$.Schedule(1.0, function() {
			OverrideScoreboardHeroImage(args);
		})

		return;
	}

	OverrideImage(image_container, args.icon_path);
}

function SetTopBarBackground() {
	var container = Parent.FindChildTraverse("HUDSkinTopBarBG");

	container.style.visibility = "visible";
//	container.style.backgroundImage = "url('s2r://panorama/images/custom_game/tophud.png')";
	container.style.backgroundImage = "url('s2r://panorama/images/custom_game/tophud2.png')";
	container.style.backgroundSize = "100% 100%";
	container.style.width = "76.8%";
	container.style.height = "90px";
}

(function() {
	GameEvents.Subscribe("override_hero_image", OverrideTopBarHeroImage);
	GameEvents.Subscribe("override_hero_image", OverrideScoreboardHeroImage);

	// test
/*
	OverrideTopBarHeroImage({
		player_id: 0,
		icon_path: "npc_dota_hero_kakashi",
	})

	OverrideScoreboardHeroImage({
		player_id: 0,
		icon_path: "npc_dota_hero_kakashi",
	})
*/

	SetTopBarBackground();
})();
