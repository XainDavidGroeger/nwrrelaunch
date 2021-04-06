var Parent = $.GetContextPanel().GetParent().GetParent().GetParent();
var MovieContainer, TooltipHeroImage, TooltipHeroMovie, TooltipHeroName;
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

			if (bSetWebms && bSetWebms == true) {
				if (button) {
					(function (button, hero_name) {
						SetWebmPanels(button, hero_name);
					})(button, image.heroname);
				}
			} else {
				if (image)
					image.SetImage('file://{images}/heroes/selection/npc_dota_hero_' + image.heroname + '.png');
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
	var hero_portrait = Parent.FindChildTraverse("HeroPortrait").GetChild(0);

	if (hero_portrait) {
		hero_portrait.style.backgroundImage = 'url("file://{images}/heroes/selection/npc_dota_hero_' + sHeroName + '.png")';
		hero_portrait.style.backgroundSize = "cover";
	}
}

function UpdateTopBar(data) {
	var team = "Radiant";

	if (data.iTeamNumber && data.iTeamNumber == 3)
		team = "Dire";

	var hero_topbar = Parent.FindChildTraverse(team + "TeamPlayers").FindChildrenWithClassTraverse("Slot" + data.iPlayerID)[0];

	if (hero_topbar) {
		var hero_image = hero_topbar.FindChildTraverse("HeroImage");

		if (hero_image) {
			hero_image.SetImage('file://{images}/heroes/npc_dota_hero_' + data.sHeroName + '.png');
			hero_image.style.backgroundImage = 'url("file://{images}/heroes/npc_dota_hero_' + data.sHeroName + '.png")';
			hero_image.style.backgroundSize = "100% 100%";
		}
	}
}

function SetWebmPanels(button, hero_name) {
	var offset_x = -90;
	var offset_y = -90;

	if (MovieContainer && TooltipHeroImage && fully_init == false) {
		button.SetPanelEvent("onmouseover", function() {
			MovieContainer.SetHasClass("TooltipVisible", false);
			var position = button.GetPositionWithinWindow();
			MovieContainer.style.transform = 'translateX( ' + (position["x"] + offset_x) + 'px ) translateY( ' + (position["y"] + offset_y) + 'px )';
			MovieContainer.SetHasClass("TooltipVisible", true);

			TooltipHeroImage.SetImage('file://{images}/heroes/selection/npc_dota_hero_' + hero_name + '.png');
			TooltipHeroMovie.heroname = hero_name;
			TooltipHeroName.text = $.Localize("npc_dota_hero_" + hero_name).toUpperCase();

			fully_init = true;
		})

		button.SetPanelEvent("onmousout", function() {
			MovieContainer.SetHasClass("TooltipVisible", false);
		})
	}
}

function Init() {
	if (fully_init == false && Parent.FindChildTraverse("HeroCardTooltip")) {
		MovieContainer = Parent.FindChildTraverse("HeroCardTooltip");
		TooltipHeroImage = MovieContainer.FindChildTraverse("HeroImage");
		TooltipHeroMovie = MovieContainer.FindChildTraverse("HeroMovie");
		TooltipHeroName = MovieContainer.FindChildTraverse("HeroName");

		SetSelectionImages(true);
	} else {
		$.Schedule(0.03, Init);
	}
}

(function() {
	GameEvents.Subscribe( "update_hero_selection_topbar", UpdateTopBar );
	GameEvents.Subscribe( "dota_player_hero_selection_dirty", OnUpdateHeroSelection );
//	GameEvents.Subscribe( "dota_player_update_hero_selection", OnUpdateHeroSelection );


	SetSelectionImages();
	Init();
})();
