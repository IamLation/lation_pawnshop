fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'lation_pawnshop'
author 'iamlation'
version '1.1.1'
description 'A Pawn Shop script for ESX, QBCore & QBox using ox_inventory'

server_scripts {
    'bridge/server.lua',
    'server/*.lua',
    'logs.lua'
}

client_scripts {
    'bridge/client.lua',
    'client/*.lua'
}

shared_scripts {
    'config.lua',
    'strings.lua',
    '@ox_lib/init.lua'
}

dependencies {
	'ox_lib',
    'ox_inventory'
}