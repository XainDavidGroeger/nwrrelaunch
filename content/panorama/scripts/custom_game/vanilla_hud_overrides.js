var Parent = $.GetContextPanel().GetParent().GetParent().GetParent();

function OverrideTopBarHeroImage(args) {
	$.Msg(args)
	var team = "Radiant"

	if (Players.GetTeam(args.player_id) == 3) {
		team = "Dire"
	}

	var panel = Parent.FindChildTraverse(team + "Player" + args.player_id).FindChildTraverse("HeroImage")
	var newheroimage = $.CreatePanel('Panel', panel, '');
	newheroimage.style.width = "100%";
	newheroimage.style.height = "100%";
	newheroimage.style.backgroundImage = 'url("file://{images}/heroes/' + args.icon_path + '.png")';
	newheroimage.style.backgroundSize = "cover";
}

(function() {
	GameEvents.Subscribe("override_hero_image", OverrideTopBarHeroImage);
})();
