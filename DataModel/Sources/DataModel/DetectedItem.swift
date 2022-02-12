//
//  DetectedItem.swift
//  
//
//  Created by Danis Tazetdinov on 10.12.2021.
//

import Foundation
import Logger
import Localization

public enum DetectedItem: String, CustomStringConvertible {
    case other
    case bird
    case fish
    case cat
    case dog
    case livingThing
    case food
    case book
    case comicBook
    case magazine
    case hygiene
    case mug
    case plate
    case spoon
    case fork
    case knife
    case sportInventory
    case chair
    case screwdriver
    case hammer
    case glasses
    case fridge
    case player
    case gadget
    case guitar
    case piano
    case instrument
    case clock
    case watch
    case phone
    case computer
    case laptop
    case photo
    case gun
    case tool
    case backpack
    case bag
    case wallet
    case vehicle
    case medical
    case jewelry
    case shoes
    case storage
    case audio
    case tv
    case desk
    case bed
    case table
    case cabinet
    case toy
    case tie
    case umbrella

    case hat
    case denim
    case swimsuit
    case sweatshirt
    case tShirt
    case suit
    case skirt
    case coat
    case clothers

    case beauty
    case bathing
    case lighting
    case stationery
    case kitchen

    case climate
    case washing
    case cleaning
    case appliance
    case coffeeMaker
    case cooking
    case teaMaker

    case accessory
    case houseItem
    case trashBin

    public var category: AppCategory {
        switch self {

        case .other, .food, .hygiene, .gun, .vehicle, .medical, .toy, .beauty, .bathing, .lighting, .stationery, .kitchen, .houseItem, .trashBin, .storage:
            return .other

        case .hat, .denim, .swimsuit, .sweatshirt, .tShirt, .suit, .skirt, .coat, .clothers:
            return .clothers

        case .bed, .chair, .desk, .cabinet, .table:
            return .furniture

        case .shoes:
            return .shoes

        case .jewelry:
            return .jewelry

        case .backpack, .bag, .wallet, .glasses, .watch, .tie, .umbrella, .accessory:
            return .accessories

        case .instrument, .guitar, .piano:
            return .music

        case .player, .gadget, .clock, .phone, .computer, .laptop, .audio, .tv, .photo:
            return .gadgets

        case .fridge, .cooking, .washing, .cleaning, .coffeeMaker, .teaMaker, .climate, .appliance:
            return .appliances

        case .screwdriver, .hammer, .tool:
            return .tools

        case .sportInventory:
            return .sports

        case .book, .comicBook, .magazine:
            return .books

        case .mug, .plate, .spoon, .fork, .knife:
            return .tableware

        case .bird, .fish, .cat, .dog, .livingThing:
            return .pets
        }
    }

    public var description: String {
        "\(rawValue) (\(category.rawValue))"
    }

    public var localizedTitle: String {
        switch self {
        case .other:
            return L10n.DetectedItem.other.localized
        case .bird:
            return L10n.DetectedItem.bird.localized
        case .fish:
            return L10n.DetectedItem.fish.localized
        case .cat:
            return L10n.DetectedItem.cat.localized
        case .dog:
            return L10n.DetectedItem.dog.localized
        case .livingThing:
            return L10n.DetectedItem.livingThing.localized
        case .food:
            return L10n.DetectedItem.food.localized
        case .book:
            return L10n.DetectedItem.book.localized
        case .comicBook:
            return L10n.DetectedItem.comicBook.localized
        case .magazine:
            return L10n.DetectedItem.magazine.localized
        case .hygiene:
            return L10n.DetectedItem.hygiene.localized
        case .mug:
            return L10n.DetectedItem.mug.localized
        case .plate:
            return L10n.DetectedItem.plate.localized
        case .spoon:
            return L10n.DetectedItem.spoon.localized
        case .fork:
            return L10n.DetectedItem.fork.localized
        case .knife:
            return L10n.DetectedItem.knife.localized
        case .sportInventory:
            return L10n.DetectedItem.sportInventory.localized
        case .chair:
            return L10n.DetectedItem.chair.localized
        case .screwdriver:
            return L10n.DetectedItem.screwdriver.localized
        case .hammer:
            return L10n.DetectedItem.hammer.localized
        case .glasses:
            return L10n.DetectedItem.glasses.localized
        case .fridge:
            return L10n.DetectedItem.fridge.localized
        case .player:
            return L10n.DetectedItem.player.localized
        case .gadget:
            return L10n.DetectedItem.gadget.localized
        case .guitar:
            return L10n.DetectedItem.guitar.localized
        case .piano:
            return L10n.DetectedItem.piano.localized
        case .instrument:
            return L10n.DetectedItem.instrument.localized
        case .clock:
            return L10n.DetectedItem.clock.localized
        case .watch:
            return L10n.DetectedItem.watch.localized
        case .phone:
            return L10n.DetectedItem.phone.localized
        case .computer:
            return L10n.DetectedItem.computer.localized
        case .laptop:
            return L10n.DetectedItem.laptop.localized
        case .photo:
            return L10n.DetectedItem.photo.localized
        case .gun:
            return L10n.DetectedItem.gun.localized
        case .tool:
            return L10n.DetectedItem.tool.localized
        case .backpack:
            return L10n.DetectedItem.backpack.localized
        case .bag:
            return L10n.DetectedItem.bag.localized
        case .wallet:
            return L10n.DetectedItem.wallet.localized
        case .vehicle:
            return L10n.DetectedItem.vehicle.localized
        case .medical:
            return L10n.DetectedItem.medical.localized
        case .jewelry:
            return L10n.DetectedItem.jewelry.localized
        case .shoes:
            return L10n.DetectedItem.shoes.localized
        case .storage:
            return L10n.DetectedItem.storage.localized
        case .audio:
            return L10n.DetectedItem.audio.localized
        case .tv:
            return L10n.DetectedItem.tv.localized
        case .desk:
            return L10n.DetectedItem.desk.localized
        case .bed:
            return L10n.DetectedItem.bed.localized
        case .table:
            return L10n.DetectedItem.table.localized
        case .cabinet:
            return L10n.DetectedItem.storage.localized
        case .toy:
            return L10n.DetectedItem.toy.localized
        case .tie:
            return L10n.DetectedItem.tie.localized
        case .umbrella:
            return L10n.DetectedItem.umbrella.localized
        case .hat:
            return L10n.DetectedItem.hat.localized
        case .denim:
            return L10n.DetectedItem.denim.localized
        case .swimsuit:
            return L10n.DetectedItem.swimsuit.localized
        case .sweatshirt:
            return L10n.DetectedItem.sweatshirt.localized
        case .tShirt:
            return L10n.DetectedItem.tShirt.localized
        case .suit:
            return L10n.DetectedItem.suit.localized
        case .skirt:
            return L10n.DetectedItem.skirt.localized
        case .coat:
            return L10n.DetectedItem.coat.localized
        case .clothers:
            return L10n.DetectedItem.clothers.localized
        case .beauty:
            return L10n.DetectedItem.beauty.localized
        case .bathing:
            return L10n.DetectedItem.bathing.localized
        case .lighting:
            return L10n.DetectedItem.lighting.localized
        case .stationery:
            return L10n.DetectedItem.stationery.localized
        case .kitchen:
            return L10n.DetectedItem.kitchen.localized
        case .climate:
            return L10n.DetectedItem.climate.localized
        case .washing:
            return L10n.DetectedItem.washing.localized
        case .cleaning:
            return L10n.DetectedItem.cleaning.localized
        case .appliance:
            return L10n.DetectedItem.appliance.localized
        case .coffeeMaker:
            return L10n.DetectedItem.coffeeMaker.localized
        case .cooking:
            return L10n.DetectedItem.cooking.localized
        case .teaMaker:
            return L10n.DetectedItem.teaMaker.localized
        case .accessory:
            return L10n.DetectedItem.accessory.localized
        case .houseItem:
            return L10n.DetectedItem.houseItem.localized
        case .trashBin:
            return L10n.DetectedItem.trashBin.localized
        }
    }

    public init(prediction: String) {
        switch prediction {
        case
            "background",
            "fire screen, fireguard",
            "spindle",
            "stupa, tope",
            "sundial",
            "swing",
            "turnstile",
            "vending machine",
            "washbasin, handbasin, washbowl, lavabo, wash-hand basin",
            "water tower",
            "ear, spike, capitulum",
            "gyromitra",
            "rapeseed",
            "daisy",
            "yellow lady's slipper, yellow lady-slipper, Cypripedium calceolus, Cypripedium parviflorum",
            "corn",
            "acorn",
            "hip, rose hip, rosehip",
            "buckeye, horse chestnut, conker",
            "coral fungus",
            "agaric",
            "stinkhorn, carrion fungus",
            "earthstar",
            "hen-of-the-woods, hen of the woods, Polyporus frondosus, Grifola frondosa",
            "bolete",
            "bubble",
            "promontory, headland, head, foreland",
            "cardoon",
            "hay",
            "sandbar, sand bar",
            "wreck",
            "yurt",
            "wool, woolen, woollen",
            "worm fence, snake fence, snake-rail fence, Virginia fence",
            "breakwater, groin, groyne, mole, bulwark, seawall, jetty",
            "chest",
            "chain",
            "coil, spiral, volute, whorl, helix",
            "dam, dike, dyke",
            "dome",
            "flagpole, flagstaff",
            "grille, radiator grille",
            "honeycomb",
            "knot",
            "lumbermill, sawmill",
            "mailbox, letter box",
            "matchstick",
            "mask",
            "maypole",
            "mortar",
            "muzzle",
            "mosquito net",
            "picket fence, paling",
            "pole",
            "shoji",
            "fountain",
            "gas pump, gasoline pump, petrol pump, island dispenser",
            "manhole cover",
            "nipple",
            "obelisk",
            "oil filter",
            "parking meter",
            "pier",
            "spider web, spider's web",
            "suspension bridge",
            "thatch, thatched roof",
            "tobacco shop, tobacconist shop, tobacconist",
            "totem pole",
            "toyshop",
            "viaduct",
            "window screen",
            "wing",
            "alp",
            "coral reef",
            "cliff, drop, drop-off",
            "geyser",
            "lakeside, lakeshore",
            "seashore, coast, seacoast, sea-coast",
            "valley, vale",
            "volcano",
            "groom, bridegroom",
            "altar",
            "apiary, bee house",
            "bannister, banister, balustrade, balusters, handrail",
            "barbershop",
            "barn",
            "beacon, lighthouse, beacon light, pharos",
            "broom",
            "bell cote, bell cot",
            "bib",
            "chainlink fence",
            "chain mail, ring mail, mail, chain armor, chain armour, ring armor, ring armour",
            "brass, memorial tablet, plaque",
            "boathouse",
            "cinema, movie theater, movie theatre, movie house, picture palace",
            "butcher shop, meat market",
            "castle",
            "church, church building",
            "monastery",
            "mosque",
            "greenhouse, nursery, glasshouse",
            "street sign",
            "traffic light, traffic signal, stoplight",
            "vault",
            "velvet",
            "triumphal arch",
            "tile roof",
            "stone wall",
            "spotlight, spot",
            "stage",
            "steel arch bridge",
            "sliding door",
            "shoe shop, shoe-shop, shoe store",
            "seat belt, seatbelt",
            "restaurant, eating house, eating place, eatery",
            "prayer rug, prayer mat",
            "plane, carpenter's plane, woodworking plane",
            "planetarium",
            "patio, terrace",
            "palace",
            "drilling platform, offshore rig",
            "grocery store, grocery, food market, market",
            "guillotine",
            "half track",
            "maze, labyrinth",
            "megalith, megalithic structure",
            "pedestal, plinth, footstall",
            "perfume, essence",
            "kelpie",
            "prison, prison house":
            self = .other


        case
            "balloon",
            "carousel, carrousel, merry-go-round, roundabout, whirligig",
            "jack-o'-lantern",
            "jigsaw puzzle",
            "candle, taper, wax light",
            "Christmas stocking",
            "piggy bank, penny bank",
            "quill, quill pen",
            "slot, one-armed bandit",
            "teddy, teddy bear",
            "birdhouse":
            self = .toy



        case
            "abacus", // gadget
            "barometer", // gadget
            "cash machine, cash dispenser, automated teller machine, automatic teller machine, automated teller, automatic teller, ATM", // gadget
            "combination lock", // gadget
            "computer keyboard, keypad", // gadget
            "modem", // gadget
            "magnetic compass", // gadget
            "joystick", // gadget
            "loupe, jeweler's loupe", // gadget
            "radio, wireless", // gadget
            "radio telescope, radio reflector", // gadget
            "remote control, remote", // gadget
            "web site, website, internet site, site", // gadget
            "typewriter keyboard", // gadget
            "stopwatch, stop watch", // gadget
            "solar dish, solar collector, solar furnace", // gadget
            "scale, weighing machine", // gadget
            "rule, ruler", // gadget
            "projector", // gadget
            "printer", // gadget
            "photocopier", // gadget
            "mouse, computer mouse", // gadget
            "hard disc, hard disk, fixed disk", // gadget
            "oscilloscope, scope, cathode-ray oscilloscope, CRO", // gadget
            "pinwheel", // gadget
            "switch, electric switch, electrical switch": // gadget
            self = .gadget

        case
            "hourglass", // gadget
            "analog clock", // clock
            "digital clock", // clock
            "wall clock": // clock
            self = .clock

        case
            "digital watch": // clock
            self = .watch

        case
            "library",
            "book jacket, dust cover, dust jacket, dust wrapper",
            "menu":
            self = .book

        case
            "comic book":
            self = .comicBook

        case
            "crossword puzzle, crossword":
            self = .magazine

        case
            "microphone, mike", // audio
            "loudspeaker, speaker, speaker unit, loudspeaker system, speaker system": // audio
            self = .audio

        case
            "television, television system", // tv
            "screen, CRT screen": // tv
            self = .tv

        case
            "pay-phone, pay-station", // phone
            "hand-held computer, hand-held microcomputer", // phone
            "cellular telephone, cellular phone, cellphone, cell, mobile phone", // phone
            "dial telephone, dial phone": // phone
            self = .phone

        case
            "space bar", // computer
            "desktop computer", // computer
            "monitor": // computer
            self = .computer

        case
            "laptop, laptop computer", // laptop
            "notebook, notebook computer": // laptop
            self = .laptop

        case
            "lens cap, lens cover", // photo
            "tripod", // photo
            "reflex camera", // photo
            "Polaroid camera, Polaroid Land camera": // photo
            self = .photo

        case
            "iPod", // player
            "tape player", // player
            "entertainment center", // player
            "cassette",
            "cassette player",
            "CD player":
            self = .player

        case
            "barrel, cask",
            "carton",
            "crate",
            "hamper",
            "milk can",
            "pitcher, ewer", // jug
            "plastic bag",
            "rain barrel",
            "safe", // safe
            "tub, vat":
            self = .storage

        case
            "cowboy boot",
            "clog, geta, patten, sabot",
            "Loafer",
            "running shoe",
            "sandal":
            self = .shoes

        case
            "bulletproof vest",
            "military uniform",
            "breastplate, aegis, egis",
            "cuirass",
            "bow",
            "holster",
            "missile",
            "projectile, missile",
            "pickelhaube",
            "revolver, six-gun, six-shooter",
            "scabbard",
            "shield, buckler",
            "assault rifle, assault gun",
            "cannon",
            "rifle":
            self = .gun

        case
            "neck brace",
            "necklace":
            self = .jewelry

        case
            "Band Aid",
            "diaper, nappy, napkin",
            "soap dispenser",
            "paper towel",
            "toilet seat",
            "swab, swob, mop",
            "face powder",
            "toilet tissue, toilet paper, bathroom tissue":
            self = .hygiene

        case
            "backpack, back pack, knapsack, packsack, rucksack, haversack":
            self = .backpack

        case
            "mailbag, postbag",
            "purse":
            self = .bag


        case
            "plate":
            self = .plate

        case
            "goblet",
            "cup",
            "beaker",
            "beer glass",
            "coffee mug":
            self = .mug

        case
            "refrigerator, icebox":
            self = .fridge

        case
            "wooden spoon":
            self = .spoon

        case
            "screw",
            "screwdriver":
            self = .screwdriver

        case
            "sunglass",
            "sunglasses, dark glasses, shades":
            self = .glasses

        case
            "barbell",
            "crash helmet",
            "bobsled, bobsleigh, bob",
            "dumbbell",
            "golf ball",
            "football helmet",
            "cliff dwelling",
            "croquet ball",
            "balance beam, beam",
            "dogsled, dog sled, dog sleigh",
            "gasmask, respirator, gas helmet",
            "horizontal bar, high bar",
            "knee pad",
            "mountain tent",
            "rugby ball",
            "parachute, chute",
            "parallel bars, bars",
            "ping-pong ball",
            "pool table, billiard table, snooker table",
            "puck, hockey puck",
            "punching bag, punch bag, punching ball, punchball",
            "racket, racquet",
            "scoreboard",
            "bathing cap, swimming cap",
            "ski",
            "ski mask",
            "sleeping bag",
            "snorkel",
            "soccer ball",
            "tennis ball",
            "ballplayer, baseball player",
            "scuba diver",
            "whistle",
            "baseball",
            "basketball",
            "volleyball":
            self = .sportInventory

        case
            "bucket, pail",
            "carpenter's kit, tool kit",
            "hammer",
            "hatchet",
            "hook, claw",
            "lighter, light, igniter, ignitor",
            "mousetrap",
            "nail",
            "packet",
            "padlock",
            "paintbrush",
            "plow, plough",
            "plunger, plumber's helper",
            "potter's wheel",
            "power drill",
            "reel",
            "shopping basket",
            "shovel",
            "slide rule, slipstick",
            "thimble",
            "torch",
            "chain saw, chainsaw":
            self = .tool

        case
            "violin, fiddle",
            "trombone",
            "marimba, xylophone",
            "sax, saxophone",
            "banjo",
            "accordion, piano accordion, squeeze box",
            "bassoon",
            "cello, violoncello",
            "chime, bell, gong",
            "harp",
            "drum, membranophone, tympan",
            "drumstick",
            "cornet, horn, trumpet, trump",
            "home theater, home theatre",
            "flute, transverse flute",
            "French horn, horn",
            "organ, pipe organ",
            "harmonica, mouth organ, harp, mouth harp",
            "maraca",
            "oboe, hautboy, hautbois",
            "ocarina, sweet potato",
            "panpipe, pandean pipe, syrinx",
            "pick, plectrum, plectron",
            "steel drum",
            "upright, upright piano",
            "gong, tam-tam":
            self = .instrument

        case
            "grand piano, grand":
            self = .piano

        case
            "electric guitar",
            "acoustic guitar":
            self = .guitar

        case
            "goldfish, Carassius auratus",
            "great white shark, white shark, man-eater, man-eating shark, Carcharodon carcharias",
            "tiger shark, Galeocerdo cuvieri",
            "hammerhead, hammerhead shark",
            "electric ray, crampfish, numbfish, torpedo",
            "barracouta, snoek",
            "starfish, sea star",
            "sea urchin",
            "anemone fish",
            "gar, garfish, garpike, billfish, Lepisosteus osseus",
            "lionfish",
            "puffer, pufferfish, blowfish, globefish",
            "eel",
            "coho, cohoe, coho salmon, blue jack, silver salmon, Oncorhynchus kisutch",
            "tench, Tinca tinca", "stingray",
            "sturgeon":
            self = .fish

        case
            "cock",
            "hen",
            "ostrich, Struthio camelus",
            "brambling, Fringilla montifringilla",
            "goldfinch, Carduelis carduelis",
            "house finch, linnet, Carpodacus mexicanus",
            "junco, snowbird",
            "indigo bunting, indigo finch, indigo bird, Passerina cyanea",
            "robin, American robin, Turdus migratorius",
            "bulbul",
            "jay",
            "magpie",
            "water ouzel, dipper",
            "bald eagle, American eagle, Haliaeetus leucocephalus",
            "great grey owl, great gray owl, Strix nebulosa",
            "white stork, Ciconia ciconia",
            "black stork, Ciconia nigra",
            "spoonbill",
            "flamingo",
            "little blue heron, Egretta caerulea",
            "American egret, great white heron, Egretta albus",
            "bittern",
            "crane",
            "limpkin, Aramus pictus",
            "European gallinule, Porphyrio porphyrio",
            "American coot, marsh hen, mud hen, water hen, Fulica americana",
            "bustard",
            "ruddy turnstone, Arenaria interpres",
            "red-backed sandpiper, dunlin, Erolia alpina",
            "redshank, Tringa totanus",
            "dowitcher",
            "oystercatcher, oyster catcher",
            "pelican",
            "king penguin, Aptenodytes patagonica",
            "albatross, mollymawk",
            "kite",
            "vulture",
            "black grouse",
            "ptarmigan",
            "ruffed grouse, partridge, Bonasa umbellus",
            "prairie chicken, prairie grouse, prairie fowl",
            "peacock",
            "quail",
            "partridge",
            "African grey, African gray, Psittacus erithacus",
            "macaw",
            "sulphur-crested cockatoo, Kakatoe galerita, Cacatua galerita",
            "lorikeet",
            "coucal",
            "bee eater",
            "hornbill",
            "hummingbird",
            "jacamar",
            "toucan",
            "drake",
            "red-breasted merganser, Mergus serrator",
            "goose",
            "black swan, Cygnus atratus",
            "chickadee":
            self = .bird

        case
            "spotted salamander, Ambystoma maculatum",
            "axolotl, mud puppy, Ambystoma mexicanum",
            "bullfrog, Rana catesbeiana",
            "tree frog, tree-frog",
            "tailed frog, bell toad, ribbed toad, tailed toad, Ascaphus trui",
            "loggerhead, loggerhead turtle, Caretta caretta",
            "leatherback turtle, leatherback, leathery turtle, Dermochelys coriacea",
            "mud turtle",
            "terrapin",
            "box turtle, box tortoise",
            "banded gecko",
            "common iguana, iguana, Iguana iguana",
            "American chameleon, anole, Anolis carolinensis",
            "frilled lizard, Chlamydosaurus kingi",
            "alligator lizard",
            "Gila monster, Heloderma suspectum",
            "green lizard, Lacerta viridis",
            "African chameleon, Chamaeleo chamaeleon",
            "Komodo dragon, Komodo lizard, dragon lizard, giant lizard, Varanus komodoensis",
            "African crocodile, Nile crocodile, Crocodylus niloticus",
            "American alligator, Alligator mississipiensis",
            "triceratops",
            "thunder snake, worm snake, Carphophis amoenus",
            "ringneck snake, ring-necked snake, ring snake",
            "hognose snake, puff adder, sand viper",
            "green snake, grass snake",
            "king snake, kingsnake",
            "garter snake, grass snake",
            "water snake",
            "vine snake",
            "night snake, Hypsiglena torquata",
            "boa constrictor, Constrictor constrictor",
            "rock python, rock snake, Python sebae",
            "Indian cobra, Naja naja",
            "green mamba",
            "sea snake",
            "horned viper, cerastes, sand viper, horned asp, Cerastes cornutus",
            "diamondback, diamondback rattlesnake, Crotalus adamanteus",
            "sidewinder, horned rattlesnake, Crotalus cerastes",
            "trilobite",
            "harvestman, daddy longlegs, Phalangium opilio",
            "scorpion",
            "black and gold garden spider, Argiope aurantia",
            "barn spider, Araneus cavaticus",
            "garden spider, Aranea diademata",
            "black widow, Latrodectus mactans",
            "tarantula",
            "wolf spider, hunting spider",
            "tick",
            "centipede",
            "koala, koala bear, kangaroo bear, native bear, Phascolarctos cinereus",
            "whiptail, whiptail lizard",
            "hyena, hyaena",
            "red fox, Vulpes vulpes",
            "kit fox, Vulpes macrotis",
            "Arctic fox, white fox, Alopex lagopus",
            "grey fox, gray fox, Urocyon cinereoargenteus",
            "brown bear, bruin, Ursus arctos",
            "American black bear, black bear, Ursus americanus, Euarctos americanus",
            "ice bear, polar bear, Ursus Maritimus, Thalarctos maritimus",
            "sloth bear, Melursus ursinus, Ursus ursinus",
            "mongoose",
            "meerkat, mierkat",
            "tiger beetle",
            "ladybug, ladybeetle, lady beetle, ladybird, ladybird beetle",
            "ground beetle, carabid beetle",
            "long-horned beetle, longicorn, longicorn beetle",
            "leaf beetle, chrysomelid",
            "dung beetle",
            "rhinoceros beetle",
            "weevil",
            "fly",
            "bee",
            "ant, emmet, pismire",
            "grasshopper, hopper",
            "cricket",
            "walking stick, walkingstick, stick insect",
            "cockroach, roach",
            "mantis, mantid",
            "cicada, cicala",
            "leafhopper",
            "lacewing, lacewing fly",
            "dragonfly, darning needle, devil's darning needle, sewing needle, snake feeder, snake doctor, mosquito hawk, skeeter hawk",
            "damselfly",
            "admiral",
            "ringlet, ringlet butterfly",
            "monarch, monarch butterfly, milkweed butterfly, Danaus plexippus",
            "cabbage butterfly",
            "sulphur butterfly, sulfur butterfly",
            "lycaenid, lycaenid butterfly",
            "sea cucumber, holothurian",
            "wood rabbit, cottontail, cottontail rabbit",
            "hare",
            "Angora, Angora rabbit",
            "hamster",
            "porcupine, hedgehog",
            "fox squirrel, eastern fox squirrel, Sciurus niger",
            "marmot",
            "beaver",
            "guinea pig, Cavia cobaya",
            "sorrel",
            "zebra",
            "hog, pig, grunter, squealer, Sus scrofa",
            "wild boar, boar, Sus scrofa",
            "warthog",
            "hippopotamus, hippo, river horse, Hippopotamus amphibius",
            "ox",
            "water buffalo, water ox, Asiatic buffalo, Bubalus bubalis",
            "bison",
            "ram, tup",
            "bighorn, bighorn sheep, cimarron, Rocky Mountain bighorn, Rocky Mountain sheep, Ovis canadensis",
            "ibex, Capra ibex",
            "hartebeest",
            "impala, Aepyceros melampus",
            "gazelle",
            "Arabian camel, dromedary, Camelus dromedarius",
            "llama",
            "weasel",
            "mink",
            "polecat, fitch, foulmart, foumart, Mustela putorius",
            "black-footed ferret, ferret, Mustela nigripes",
            "otter",
            "skunk, polecat, wood pussy",
            "badger",
            "armadillo",
            "three-toed sloth, ai, Bradypus tridactylus",
            "orangutan, orang, orangutang, Pongo pygmaeus",
            "gorilla, Gorilla gorilla",
            "chimpanzee, chimp, Pan troglodytes",
            "gibbon, Hylobates lar",
            "siamang, Hylobates syndactylus, Symphalangus syndactylus",
            "guenon, guenon monkey",
            "patas, hussar monkey, Erythrocebus patas",
            "baboon",
            "macaque",
            "langur",
            "colobus, colobus monkey",
            "proboscis monkey, Nasalis larvatus",
            "marmoset",
            "capuchin, ringtail, Cebus capucinus",
            "howler monkey, howler",
            "titi, titi monkey",
            "spider monkey, Ateles geoffroyi",
            "squirrel monkey, Saimiri sciureus",
            "Madagascar cat, ring-tailed lemur, Lemur catta",
            "indri, indris, Indri indri, Indri brevicaudatus",
            "Indian elephant, Elephas maximus",
            "African elephant, Loxodonta africana",
            "lesser panda, red panda, panda, bear cat, cat bear, Ailurus fulgens",
            "giant panda, panda, panda bear, coon bear, Ailuropoda melanoleuca",
            "rock beauty, Holocanthus tricolor",
            "European fire salamander, Salamandra salamandra",
            "common newt, Triturus vulgaris",
            "eft",
            "agama",
            "tusker",
            "echidna, spiny anteater, anteater",
            "platypus, duckbill, duckbilled platypus, duck-billed platypus, Ornithorhynchus anatinus",
            "wallaby, brush kangaroo",
            "wombat",
            "jellyfish",
            "sea anemone, anemone",
            "brain coral",
            "flatworm, platyhelminth",
            "nematode, nematode worm, roundworm",
            "conch",
            "snail",
            "slug",
            "sea slug, nudibranch",
            "chiton, coat-of-mail shell, sea cradle, polyplacophore",
            "chambered nautilus, pearly nautilus, nautilus",
            "Dungeness crab, Cancer magister",
            "rock crab, Cancer irroratus",
            "fiddler crab",
            "king crab, Alaska crab, Alaskan king crab, Alaska king crab, Paralithodes camtschatica",
            "American lobster, Northern lobster, Maine lobster, Homarus americanus",
            "spiny lobster, langouste, rock lobster, crawfish, crayfish, sea crawfish",
            "crayfish, crawfish, crawdad, crawdaddy",
            "hermit crab",
            "isopod",
            "grey whale, gray whale, devilfish, Eschrichtius gibbosus, Eschrichtius robustus",
            "killer whale, killer, orca, grampus, sea wolf, Orcinus orca",
            "dugong, Dugong dugon",
            "sea lion":
            self = .livingThing

        case
            "Chihuahua",
            "Japanese spaniel",
            "Maltese dog, Maltese terrier, Maltese",
            "Pekinese, Pekingese, Peke",
            "Shih-Tzu",
            "Blenheim spaniel",
            "papillon",
            "toy terrier",
            "Rhodesian ridgeback",
            "Afghan hound, Afghan",
            "basset, basset hound",
            "beagle",
            "bloodhound, sleuthhound",
            "bluetick",
            "black-and-tan coonhound",
            "Walker hound, Walker foxhound",
            "English foxhound",
            "redbone",
            "borzoi, Russian wolfhound",
            "Irish wolfhound",
            "Italian greyhound",
            "whippet",
            "Ibizan hound, Ibizan Podenco",
            "Norwegian elkhound, elkhound",
            "otterhound, otter hound",
            "Saluki, gazelle hound",
            "Scottish deerhound, deerhound",
            "Weimaraner",
            "Staffordshire bullterrier, Staffordshire bull terrier",
            "American Staffordshire terrier, Staffordshire terrier, American pit bull terrier, pit bull terrier",
            "Bedlington terrier",
            "Border terrier",
            "Kerry blue terrier",
            "Irish terrier",
            "Norfolk terrier",
            "Norwich terrier",
            "Yorkshire terrier",
            "wire-haired fox terrier",
            "Lakeland terrier",
            "Sealyham terrier, Sealyham",
            "Airedale, Airedale terrier",
            "cairn, cairn terrier",
            "Australian terrier",
            "Dandie Dinmont, Dandie Dinmont terrier",
            "Boston bull, Boston terrier",
            "miniature schnauzer",
            "giant schnauzer",
            "standard schnauzer",
            "Scotch terrier, Scottish terrier, Scottie",
            "Tibetan terrier, chrysanthemum dog",
            "silky terrier, Sydney silky",
            "soft-coated wheaten terrier",
            "West Highland white terrier",
            "Lhasa, Lhasa apso",
            "flat-coated retriever",
            "curly-coated retriever",
            "golden retriever",
            "Labrador retriever",
            "Chesapeake Bay retriever",
            "German short-haired pointer",
            "vizsla, Hungarian pointer",
            "English setter",
            "Irish setter, red setter",
            "Gordon setter",
            "Brittany spaniel",
            "clumber, clumber spaniel",
            "English springer, English springer spaniel",
            "Welsh springer spaniel",
            "cocker spaniel, English cocker spaniel, cocker",
            "Sussex spaniel",
            "Old English sheepdog, bobtail",
            "Shetland sheepdog, Shetland sheep dog, Shetland",
            "collie",
            "Border collie",
            "Bouvier des Flandres, Bouviers des Flandres",
            "Rottweiler",
            "German shepherd, German shepherd dog, German police dog, alsatian",
            "Doberman, Doberman pinscher",
            "miniature pinscher",
            "Greater Swiss Mountain dog",
            "Bernese mountain dog",
            "Appenzeller",
            "EntleBucher",
            "boxer",
            "bull mastiff",
            "Tibetan mastiff",
            "French bulldog",
            "Great Dane",
            "Saint Bernard, St Bernard",
            "Eskimo dog, husky",
            "malamute, malemute, Alaskan malamute",
            "Siberian husky",
            "dalmatian, coach dog, carriage dog",
            "affenpinscher, monkey pinscher, monkey dog",
            "basenji",
            "pug, pug-dog",
            "Leonberg",
            "Newfoundland, Newfoundland dog",
            "Great Pyrenees",
            "Samoyed, Samoyede",
            "Pomeranian",
            "chow, chow chow",
            "keeshond",
            "Brabancon griffon",
            "Pembroke, Pembroke Welsh corgi",
            "Cardigan, Cardigan Welsh corgi",
            "toy poodle",
            "miniature poodle",
            "standard poodle",
            "Mexican hairless",
            "timber wolf, grey wolf, gray wolf, Canis lupus",
            "white wolf, Arctic wolf, Canis lupus tundrarum",
            "red wolf, maned wolf, Canis rufus, Canis niger",
            "coyote, prairie wolf, brush wolf, Canis latrans",
            "dingo, warrigal, warragal, Canis dingo",
            "dhole, Cuon alpinus",
            "African hunting dog, hyena dog, Cape hunting dog, Lycaon pictus",
            "kuvasz",
            "schipperke",
            "groenendael",
            "malinois",
            "briard",
            "komondor",
            "Irish water spaniel":
            self = .dog

        case
            "ice cream, icecream",
            "ice lolly, lolly, lollipop, popsicle",
            "French loaf",
            "bagel, beigel",
            "pretzel",
            "cheeseburger",
            "hotdog, hot dog, red hot",
            "mashed potato",
            "head cabbage",
            "broccoli",
            "cauliflower",
            "zucchini, courgette",
            "spaghetti squash",
            "acorn squash",
            "butternut squash",
            "cucumber, cuke",
            "artichoke, globe artichoke",
            "bell pepper",
            "mushroom",
            "Granny Smith",
            "strawberry",
            "orange",
            "lemon",
            "fig",
            "pineapple, ananas",
            "banana",
            "jackfruit, jak, jack",
            "custard apple",
            "pomegranate",
            "carbonara",
            "chocolate sauce, chocolate syrup",
            "dough",
            "meat loaf, meatloaf",
            "pizza, pizza pie",
            "potpie",
            "burrito",
            "bakery, bakeshop, bakehouse",
            "confectionery, confectionary, candy store",
            "guacamole",
            "consomme",
            "hot pot, hotpot",
            "trifle",
            "espresso",
            "eggnog",
            "red wine":
            self = .food

        case
            "tabby, tabby cat",
            "tiger cat",
            "Persian cat",
            "Siamese cat, Siamese",
            "Egyptian cat",
            "cougar, puma, catamount, mountain lion, painter, panther, Felis concolor",
            "lynx, catamount",
            "leopard, Panthera pardus",
            "snow leopard, ounce, Panthera uncia",
            "jaguar, panther, Panthera onca, Felis onca",
            "lion, king of beasts, Panthera leo",
            "tiger, Panthera tigris",
            "cheetah, chetah, Acinonyx jubatus":
            self = .cat

        case
            "aircraft carrier, carrier, flattop, attack aircraft carrier",
            "airliner",
            "airship, dirigible",
            "ambulance",
            "amphibian, amphibious vehicle",
            "barrow, garden cart, lawn cart, wheelbarrow",
            "beach wagon, station wagon, wagon, estate car, beach waggon, station waggon, waggon",
            "bicycle-built-for-two, tandem bicycle, tandem",
            "cab, hack, taxi, taxicab",
            "canoe",
            "car wheel",
            "car mirror",
            "bullet train, bullet",
            "catamaran",
            "convertible",
            "freight car",
            "go-kart",
            "golfcart, golf cart",
            "fireboat",
            "fire engine, fire truck",
            "gondola",
            "moped",
            "mobile home, manufactured home",
            "Model T",
            "container ship, containership, container vessel",
            "garbage truck, dustcart",
            "forklift",
            "jeep, landrover",
            "horse cart, horse-cart",
            "pirate, pirate ship",
            "liner, ocean liner",
            "minibus",
            "minivan",
            "lifeboat",
            "limousine, limo",
            "tow truck, tow car, wrecker",
            "tractor",
            "trailer truck, tractor trailer, trucking rig, rig, articulated lorry, semi",
            "tricycle, trike, velocipede",
            "trimaran",
            "space shuttle",
            "recreational vehicle, RV, R.V.",
            "moving van",
            "police van, police wagon, paddy wagon, patrol wagon, wagon, black Maria",
            "school bus",
            "snowmobile",
            "snowplow, snowplough",
            "steam locomotive",
            "tank, army tank, armored combat vehicle, armoured combat vehicle",
            "speedboat",
            "disk brake, disc brake",
            "dock, dockage, docking facility",
            "electric locomotive",
            "odometer, hodometer, mileometer, milometer",
            "paddle, boat paddle",
            "passenger car, coach, carriage",
            "racer, race car, racing car",
            "streetcar, tram, tramcar, trolley, trolley car",
            "submarine, pigboat, sub, U-boat",
            "trolleybus, trolley coach, trackless trolley",
            "unicycle, monocycle",
            "harvester, reaper",
            "paddlewheel, paddle wheel",
            "motor scooter, scooter",
            "mountain bike, all-terrain bike, off-roader",
            "jinrikisha, ricksha, rickshaw",
            "lawn mower, mower",
            "oxcart",
            "schooner",
            "shopping cart",
            "sports car, sport car",
            "thresher, thrasher, threshing machine",
            "warplane, military plane",
            "yawl",
            "pickup, pickup truck":
            self = .vehicle

        case
            "crutch",
            "oxygen mask",
            "Petri dish",
            "pill bottle",
            "spatula",
            "stethoscope",
            "stretcher",
            "syringe":
            self = .medical


        case
            "bookcase",
            "bookshop, bookstore, bookstall",
            "wardrobe, closet, press", // cabinet
            "chiffonier, commode", //cabinet
            "china cabinet, china closet", // cabinet
            "file, file cabinet, filing cabinet", // cabinet
            "medicine chest, medicine cabinet": // cabinet
            self = .cabinet

        case
            "dining table, board": // table
            self = .table

        case
            "desk": // desk
            self = .desk

        case
            "bassinet", // bed
            "cradle",// bed
            "crib, cot",// bed
            "four-poster",// bed
            "studio couch, day bed": // bed
            self = .bed

        case
            "barber chair", // chair
            "folding chair", // chair
            "park bench", // chair
            "rocking chair, rocker", // chair
            "throne": // chair
            self = .chair

        case
            "wallet, billfold, notecase, pocketbook": // wallet
            self = .wallet

        case
            "bolo tie, bolo, bola tie, bola", // tie
            "bow tie, bow-tie, bowtie", // tie
            "Windsor tie": // tie
            self = .tie

        case
            "umbrella": // umbrella
            self = .umbrella

        case
            "bearskin, busby, shako", // hat
            "bonnet, poke bonnet", // hat
            "mortarboard", // hat
            "sombrero", // hat
            "cowboy hat, ten-gallon hat", // hat
            "gown": // hat
            self = .hat

        case
            "bikini, two-piece", // swimsuit
            "swimming trunks, bathing trunks", // swimsuit
            "maillot", //swimsuit
            "maillot, tank suit": // swimsuit
            self = .swimsuit

        case
            "miniskirt, mini", // skirt
            "hoopskirt, crinoline", // skirt
            "overskirt": // skirt
            self = .skirt

        case
            "suit, suit of clothes": // suit
            self = .suit

        case
            "jersey, T-shirt, tee shirt": // shirt
            self = .tShirt

        case
            "trench coat", // coat
            "fur coat", // coat
            "lab coat, laboratory coat": // coat
            self = .coat

        case
            "jean, blue jean, denim": // denim
            self = .denim

        case
            "sweatshirt", // sweatshirt
            "cardigan":
            self = .sweatshirt

        case
            "abaya",
            "academic gown, academic robe, judge's robe",
            "apron",
            "brassiere, bra, bandeau",
            "feather boa, boa",
            "kimono",
            "cloak",
            "pajama, pyjama, pj's, jammies",
            "poncho",
            "sarong",
            "sock",
            "stole",
            "vestment":
            self = .clothers

        case
            "lipstick, lip rouge",
            "hair spray",
            "lotion",
            "sunscreen, sunblock, sun blocker":
            self = .beauty

        case
            "shower cap",
            "bath towel",
            "bathtub, bathing tub, bath, tub",
            "shower curtain":
            self = .bathing

        case
            "lampshade, lamp shade",
            "table lamp":
            self = .lighting

        case
            "binder, ring-binder",
            "ballpoint, ballpoint pen, ballpen, Biro",
            "pencil box, pencil case",
            "pencil sharpener",
            "fountain pen",
            "letter opener, paper knife, paperknife",
            "envelope",
            "rubber eraser, rubber, pencil eraser":
            self = .stationery

        case
            "can opener, tin opener",
            "beer bottle",
            "pop bottle, soda bottle",
            "bottlecap",
            "cocktail shaker",
            "corkscrew, bottle screw",
            "cleaver, meat cleaver, chopper",
            "frying pan, frypan, skillet",
            "measuring cup",
            "mixing bowl",
            "caldron, cauldron",
            "Crock Pot",
            "dishrag, dishcloth",
            "ladle",
            "plate rack",
            "saltshaker, salt shaker",
            "soup bowl",
            "strainer",
            "tray",
            "water bottle",
            "water jug",
            "whiskey jug",
            "wine bottle",
            "wok":
            self = .kitchen

        case
            "teapot": // tea
            self = .teaMaker

        case
            "espresso maker", // coffeeMaker
            "coffeepot": // coffeeMaker
            self = .coffeeMaker

        case
            "radiator", // heater
            "space heater": // heater
            self = .climate

        case
            "dishwasher, dish washer, dishwashing machine", // washing
            "washer, automatic washer, washing machine": // washing
            self = .washing

        case
            "Dutch oven", // cooking
            "microwave, microwave oven", // oven
            "rotisserie", // cooking
            "stove", // cooking
            "toaster", // cooking
            "waffle iron": // cooking
            self = .cooking

        case
            "vacuum, vacuum cleaner": // cleaining
            self = .cleaning

        case
            "electric fan, blower", // fan
            "hand blower, blow dryer, blow drier, hair dryer, hair drier", // dryer
            "sewing machine", // appliance
            "iron, smoothing iron": // appliance
            self = .appliance

        case
            "binoculars, field glasses, opera glasses",
            "buckle",
            "hair slide",
            "handkerchief, hankie, hanky, hankey",
            "safety pin",
            "wig",
            "mitten":
            self = .accessory

        case
            "ashcan, trash can, garbage can, wastebin, ash bin, ash-bin, ashbin, dustbin, trash barrel, trash bin":
            self = .trashBin
            
        case
            "doormat, welcome mat",
            "pillow",
            "quilt, comforter, comfort, puff",
            "pot, flowerpot",
            "theater curtain, theatre curtain",
            "vase",
            "window shade":
            self = .houseItem

        default:
            self = .other
            Logger.default.warning("Did not recognize category \(prediction)")
        }
    }
}
