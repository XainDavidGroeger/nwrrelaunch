function FixHeroIcons(){
    var topbar = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("topbar")
    var playerSlots = topbar.FindChildrenWithClassTraverse("TopBarPlayerSlot")
    for ( k in playerSlots ){
        var img = playerSlots[k].FindChildTraverse("HeroImage")
        if ( img.Children().length == 0 ){
            var new_img = $.CreatePanel( "Image", img, "ImageOverride" )
            if (img.heroname) {
                new_img.SetImage( "file://{images}/custom_game/heroes/npc_dota_hero_" + img.heroname + ".png" )
            }
        }
    }
    $.Schedule( 0.1, FixHeroIcons )
}
FixHeroIcons()