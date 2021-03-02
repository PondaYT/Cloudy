// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

struct FortniteButtonType {

    enum Build: String, CaseIterable {
        case edit            = "Edit"
        case emoteWheel      = "Emote Wheel"
        case floorSelected   = "Floor Selected"
        case jump            = "Jump"
        case ping            = "Ping"
        case pyramidSelected = "Pyramid Selected"
        case repair          = "Repair"
        case reset           = "Reset"
        case changeMaterials = "Change Materials"
        case shootBig        = "Shoot Big"
        case shoot           = "Shoot"
        case stairSelected   = "Stair Selected"
        case switchToCombat  = "Switch To Combat"
        case use             = "Use"
        case wallSelected    = "Wall Selected"
    }

    enum Combat: String, CaseIterable {
        case aim              = "Aim"
        case crouchDown       = "Crouch Down"
        case edit             = "Edit"
        case emoteWheel       = "Emote Wheel"
        case floorSelected    = "Floor Selected"
        case inventory        = "Inventory"
        case interact         = "Interact"
        case jump             = "Jump"
        case ping             = "Ping"
        case pyramidSelected  = "Pyramid Selected"
        case shootBig         = "Shoot Big"
        case shoot            = "Shoot"
        case stairSelected    = "Stair Selected"
        case switchToBuild    = "Switch To Build"
        case use              = "Use"
        case wallSelected     = "Wall Selected"
        case reload           = "Reload"
        case slotPickaxe      = "Slot Pickaxe"
        case cycleWeaponsDown = "Cycle Weapons Down"
        case cycleWeaponsUp   = "Cycle Weapons Up"
    }

    enum Edit: String, CaseIterable {
        case confirm        = "Confirm"
        case edit           = "Edit"
        case ping           = "Ping"
        case reset          = "Reset"
        case rotate         = "Rotate"
        case shootBig       = "Shoot Big"
        case shoot          = "Shoot"
        case switchToCombat = "Switch To Combat"
    }

}
