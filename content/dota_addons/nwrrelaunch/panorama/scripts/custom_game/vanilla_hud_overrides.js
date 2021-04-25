var Parent = $.GetContextPanel().GetParent().GetParent().GetParent();

function OverrideImage(hParent, sHeroName) {
	var newheroimage = $.CreatePanel('Panel', hParent, '');
	newheroimage.style.width = "100%";
	newheroimage.style.height = "100%";
	newheroimage.style.backgroundImage = 'url("file://{images}/heroes/' + sHeroName + '.png")';
	newheroimage.style.backgroundSize = "cover";
}

function OverrideTopBarHeroImage() {
	var team = "Radiant"

	for (var i = 0;i<10;i++) {
		
		var playerInfo = Game.GetPlayerInfo( i );
		if (playerInfo) {
			var container = Parent.FindChildTraverse("RadiantPlayer" + i);

			if (container) {
				var player_panel = container.FindChildTraverse("HeroImage");
				OverrideImage(player_panel, playerInfo.player_selected_hero);
			} else {
				container = Parent.FindChildTraverse("DirePlayer" + i);
				if (container) {
					var player_panel = container.FindChildTraverse("HeroImage");
					OverrideImage(player_panel, playerInfo.player_selected_hero);
				}
			}
		}

	}
	
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

function SetCustomHUD() {
	SetTopBarBackground();
	SetInventoryBackground();
	SetAbilityBackground();
	SetMinimapBackground();
	SetPortraitBackground();
}

function SetTopBarBackground() {
	var container = Parent.FindChildTraverse("HUDSkinTopBarBG");

	container.style.visibility = "visible";
	container.style.backgroundImage = "url('s2r://panorama/images/custom_game/tophud.png')";
	container.style.backgroundSize = "100% 100%";
	container.style.width = "76.8%";
	container.style.height = "90px";

	var backgrounds = Parent.FindChildrenWithClassTraverse("TopBarBackground");

	for (var i = 0; i < backgrounds.length; i++) {
		var child = backgrounds[i];
		child.style.backgroundImage = "none";
	}
}

function SetInventoryBackground() {
	var container = Parent.FindChildTraverse("HUDSkinInventoryBG");
	var container2 = Parent.FindChildTraverse("right_flare");

	container.style.visibility = "visible";
	container.style.backgroundImage = "url('s2r://panorama/images/custom_game/dhb_abilities.png')";
	container.style.backgroundSize = "103% 105%"; //103 104
	container.style.backgroundPosition = "0px -8px"; // -6 -7
	container.style.backgroundRepeat = "no-repeat";

	container2.style.height = "145px"; // 138px
	container2.style.backgroundImage = "url('s2r://panorama/images/custom_game/dhb_inventory2.png')";
	container2.style.backgroundSize = "100% 100%";
	container2.style.backgroundRepeat = "no-repeat";
}

function SetAbilityBackground() {
	var container = Parent.FindChildTraverse("center_bg");
	var container2 = Parent.FindChildTraverse("right_flare");

	container.style.visibility = "visible";
	container.style.backgroundImage = "url('s2r://panorama/images/custom_game/dhb_abilities.png')";
	container.style.backgroundSize = "100% 105%";
	container.style.backgroundPosition = "0% -8px";
	container.style.backgroundRepeat = "no-repeat";
}

function SetPortraitBackground() {
	var container = Parent.FindChildTraverse("left_flare");
	var container2 = Parent.FindChildTraverse("HUDSkinPortrait");
	var container3 = Parent.FindChildTraverse("HUDSkinStatBranchGlow");
	var container4 = Parent.FindChildTraverse("unitname");

	container.style.visibility = "collapse";

	container2.style.backgroundImage = "url('s2r://panorama/images/custom_game/dhb_portrait1.png')";
	container2.style.backgroundSize = "90% 90%";
	container2.style.backgroundPosition = "63% -9%";
	container2.style.backgroundRepeat = "no-repeat";
	container2.style.zIndex = "6";

	container3.style.boxShadow = "none";

	container4.style.marginLeft = "49px"; // 52px
	container4.style.marginBottom = "150px"; // 145px
	container4.style.zIndex = "7";
}

function SetMinimapBackground() {
	var container = Parent.FindChildTraverse("HUDSkinMinimap");
	var container2 = Parent.FindChildTraverse("GlyphScanContainer");

	container.style.visibility = "visible";
	container.style.backgroundImage = "url('s2r://panorama/images/custom_game/dhb_minimap.png')";
	container.style.backgroundSize = "91.7% 81%";
	container.style.backgroundPosition = "0px 69px";
	container.style.backgroundRepeat = "no-repeat";

	container2.style.backgroundImage = "url('s2r://panorama/images/custom_game/dhb_minimap2.png')";
	container2.style.backgroundSize = "100% 100%";
}


(function() {
	GameEvents.Subscribe("override_hero_image", OverrideTopBarHeroImage);
	GameEvents.Subscribe("override_hero_image", OverrideScoreboardHeroImage);

	var lowhud = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("lower_hud")
	var agha = lowhud.FindChildTraverse("AghsStatusContainer")
	agha.style.width = "0px"


	SetCustomHUD();
})();
