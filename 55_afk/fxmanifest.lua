fx_version 'cerulean'
game 'gta5'

author '55 Development'
description '55 Development I Afk zone'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

lua54 'yes'
