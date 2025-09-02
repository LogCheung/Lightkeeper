extends Node

var money : int = 0
var boats : int = 0
var anger : int = 0
var nights : int = 0
var redempCounter : int = 5
var redempMax : int = 5


var upgradeInv : Dictionary = {
	UPGRADES.LIGHTCAPACITY : 0,
	UPGRADES.LIGHTPOTENCY : 0,
	UPGRADES.LIGHTPRESERVER : 0,
	UPGRADES.MOVESPEED : 0,
	UPGRADES.STRONGERHULL : 0,
	UPGRADES.BLOWHOLE : 0,
}

enum UPGRADES {
	LIGHTCAPACITY, LIGHTPOTENCY, LIGHTPRESERVER, MOVESPEED, STRONGERHULL,
	BLOWHOLE
}
