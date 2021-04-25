var Parent = $.GetContextPanel().GetParent().GetParent().GetParent();
var TooltipHeroMovie, TooltipHeroName, HeroCardTooltip;
var fully_init = false;

function SetSelectionImages(bSetWebms) {
	var Container = Parent.FindChildTraverse("GridCategories");

	if (Container.GetChildCount() == 0) {
		$.Schedule(0.03, SetSelectionImages);
		return;
	}

	for (var i = 0; i < Container.GetChildCount(); i++) {
		var child_container = Container.GetChild(i).FindChildTraverse("HeroList");

		for (var j = 0; j < child_container.GetChildCount(); j++) {
			var button = child_container.GetChild(j);
			var image = button.FindChildTraverse("HeroImage");

			if (image)
				image.SetImage('file://{images}/heroes/selection/npc_dota_hero_' + image.heroname + '.png');

			if (bSetWebms && bSetWebms == true) {
				if (button) {
					(function (button, hero_name) {
						SetWebmPanels(button, hero_name);
					})(button, image.heroname);
				}
			}
		}
	}
}

function OnUpdateHeroSelection() {
	var localPlayerInfo = Game.GetLocalPlayerInfo();
	if ( !localPlayerInfo )
		return;

	UpdatePortrait(localPlayerInfo.possible_hero_selection);

	GameEvents.SendCustomGameEventToAllClients("update_hero_selection_topbar", {
		iPlayerID: Game.GetLocalPlayerID(),
		iTeamNumber: localPlayerInfo.player_team_id,
		sHeroName: localPlayerInfo.possible_hero_selection,
	});
}

function UpdatePortrait(sHeroName) {
	var PortraitContainer = Parent.FindChildTraverse("HeroPortrait");

	if (PortraitContainer) {
		PortraitContainer.GetChild(0).style.backgroundImage = 'url("file://{images}/heroes/selection/npc_dota_hero_' + sHeroName + '.png")';
		PortraitContainer.GetChild(0).style.backgroundSize = "cover";

		if (Parent.FindChildTraverse("CustomHeroMoviePortrait"))
			Parent.FindChildTraverse("CustomHeroMoviePortrait").DeleteAsync(0);

		var MovieContainer = $.CreatePanel( "Panel", PortraitContainer, "CustomHeroMoviePortrait" )
		MovieContainer.BLoadLayoutFromString( '<root><Panel><MoviePanel src="s2r://panorama/videos/heroes/npc_dota_hero_' + sHeroName + '.webm" repeat="true" autoplay="onload" /></Panel></root>', false, false )
		MovieContainer.style.width = "160px";
		MovieContainer.style.height = "203px";
		MovieContainer.style.boxShadow = "#000000aa 0px 0px 16px 0px";
	}
}

function UpdateTopBar(data) {
	var team = "Radiant";

	var loopstart = 0;
	var loopend = 5;
	var playerInfo = Game.GetPlayerInfo( data.iPlayerID );

	if (data.iTeamNumber && data.iTeamNumber == 3) {
		team = "Dire";
		loopend = 10;
		loopstart = 5;
	}

	var hero_topbar_team = Parent.FindChildTraverse(team + "TeamPlayers");

	for (var i = loopstart;i<loopend;i++) {
		var slot_panel = hero_topbar_team.FindChildrenWithClassTraverse("Slot" + i)[0]
		var name_container = slot_panel.FindChildTraverse("NameContainer");
		var player_name_panel = name_container.FindChildTraverse("PlayerNameContainer");
		var player_name = player_name_panel.FindChildTraverse("PlayerName");

		if (player_name.text === playerInfo.player_name) {
			var hero_image = slot_panel.FindChildTraverse("HeroImage");

			if (hero_image) {
				hero_image.SetImage('file://{images}/heroes/npc_dota_hero_' + data.sHeroName + '.png');
				hero_image.style.backgroundImage = 'url("file://{images}/heroes/npc_dota_hero_' + data.sHeroName + '.png")';
				hero_image.style.backgroundSize = "100% 100%";
			}
		}

	}
}

function SetWebmPanels(button, hero_name) {
	var offset_x = -90;
	var offset_y = -90;

	if (HeroCardTooltip && fully_init == false) {
		button.SetPanelEvent("onmouseover", function() {
//			$.Msg("Hero Name: " + hero_name)
			HeroCardTooltip.SetHasClass("TooltipVisible", false);
			var position = button.GetPositionWithinWindow();
			HeroCardTooltip.style.transform = 'translateX( ' + (position["x"] + offset_x) + 'px ) translateY( ' + (position["y"] + offset_y) + 'px )';
			HeroCardTooltip.SetHasClass("TooltipVisible", true);

			TooltipHeroName.text = $.Localize("npc_dota_hero_" + hero_name).toUpperCase();

			var MovieContainer = $.CreatePanel( "Panel", Parent.FindChildTraverse("ImageContainer"), "CustomHeroMovie" )
			MovieContainer.BLoadLayoutFromString( '<root><Panel><MoviePanel src="s2r://panorama/videos/heroes/npc_dota_hero_' + hero_name + '.webm" repeat="true" autoplay="onload" /></Panel></root>', false, false )

			fully_init = true;
		})

		button.SetPanelEvent("onmousout", function() {
			HeroCardTooltip.SetHasClass("TooltipVisible", false);

			if (Parent.FindChildTraverse("CustomHeroMovie"))
				Parent.FindChildTraverse("CustomHeroMovie").DeleteAsync(0);
		})
	}
}

function SetStrategyHeroModel(data) {
	var HeroModel = $.CreatePanel("Panel", Parent.FindChildTraverse("EconSetPreview2"), "");
	HeroModel.style.width = "100%";
	HeroModel.style.height = "100%";
	HeroModel.BLoadLayoutFromString('<root><Panel><DOTAScenePanel style="width:100%; height:100%;" particleonly="false" unit="' + data.sHeroName + '"/></Panel></root>', false, false);
//	HeroModel.style.opacityMask = 'url("s2r://panorama/images/masks/hero_model_opacity_mask_png.vtex");'
}

function Init() {
	if (fully_init == false && Parent.FindChildTraverse("HeroCardTooltip")) {
		HeroCardTooltip = Parent.FindChildTraverse("HeroCardTooltip");
		TooltipHeroName = HeroCardTooltip.FindChildTraverse("HeroName");

		SetSelectionImages(true);
	} else {
		$.Schedule(0.03, Init);
	}

/*
	if (Game.IsInToolsMode()) {
		while (Parent.FindChildTraverse("CustomHeroMovie") != undefined) {
			$.Msg(Parent.FindChildTraverse("CustomHeroMovie"));
			if (Parent.FindChildTraverse("CustomHeroMovie"))
				Parent.FindChildTraverse("CustomHeroMovie").DeleteAsync(0);
		}
	}
*/
}

(function() {
	GameEvents.Subscribe( "update_hero_selection_topbar", UpdateTopBar );
	GameEvents.Subscribe( "dota_player_hero_selection_dirty", OnUpdateHeroSelection );
//	GameEvents.Subscribe( "dota_player_update_hero_selection", OnUpdateHeroSelection );
	GameEvents.Subscribe( "set_strategy_time_hero_model", SetStrategyHeroModel );

	SetSelectionImages();
	Init();
})();

