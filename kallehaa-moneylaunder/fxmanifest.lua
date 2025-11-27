fx_version 'adamant'
game 'gta5'

author 'Kallehaa'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'  
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',  
    'server.lua'
}

client_scripts {
    'client.lua'
}

dependencies {
    'ox_lib', 
    'es_extended'  
}
