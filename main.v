module main

import vweb
import webapp {new_app}


fn main() {
    app := new_app() or { return }

    vweb.run_at(app, vweb.RunParams {
        port: 7000
    }) or { return }
}
