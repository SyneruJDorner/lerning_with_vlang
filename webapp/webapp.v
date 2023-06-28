module webapp

import vweb
import os

pub struct App {
    vweb.Context
    secret string [vweb_global] // This will allow you to print the secrets on the api then called through app.secret
    private_key string [vweb_global] // This will allow you to print the secrets on the api then called through app.private_key
}

fn read_env(file_path string) map[string]string {
    data := os.read_file(file_path) or { return {} }
    lines := data.split_into_lines()
    mut env := map[string]string
    for line in lines {
        if line.trim_space().starts_with('#') || !line.contains('=') {
            continue // Skip comments and lines without equals sign
        }
        parts := line.split('=')
        if parts.len == 2 {
            key := parts[0].trim_space()
            value := parts[1].trim_space()
            env[key] = value
        }
    }
    return env
}

pub fn new_app() ?&App {
    env := read_env('dev.env')
    secret := env['SECRET']
    private_key := env['PRIVATE_KEY']

    if secret.len == 0 || private_key.len == 0 {
        println('Missing environment variables. Terminating application.')
        return none
    }

    mut app := &App{
        secret: secret
        private_key: private_key
    }
    // makes all static files available.
    app.mount_static_folder_at(os.resource_abs_path('.'), '/')
    return app
}








pub fn (mut app App) index() vweb.Result {
    return app.text('My secret is: ${app.secret} & my private key is: ${app.private_key}')
}

["/api/v1/connection"; get] //[post], [get], [put], [patch] or [delete]
pub fn (mut app App) connection() vweb.Result {
    response := {"status": "online"}
    return app.json(response)
}

['/hello/:param']
pub fn (mut app App) hello_param(param string) vweb.Result {
    return app.text('Hello param $param')
}

['/query'; get]
pub fn (mut app App) query() vweb.Result {
    query_test := app.query["test"]
    println(query_test) // This will print 'Hello'
    return app.text(query_test)
}

['/limit'; host: 'example.com']
pub fn (mut app App) hello_web() vweb.Result {
    return app.text('Hello World')
}

['/limit/api'; host: 'api.example.org']
pub fn (mut app App) hello_api() vweb.Result {
    return app.text('Hello API')
}



[middleware: check_auth]
['/admin/data']
pub fn (mut app App) admin() vweb.Result {
    return app.text('You an admin')
}

// check_auth is a method of App, so we don't need to pass the context as parameter.
pub fn (mut app App) check_auth() bool {
    // ...
    return true
}