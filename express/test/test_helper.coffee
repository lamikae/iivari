fs = require "fs"
path = require "path"
hbs = require "hbs"

# Render handlebars template
exports.render_hbs_template = (view, locals) ->
    filename = path.join(__dirname, "..", "client", "views", view)
    str = fs.readFileSync filename, 'utf8'
    options = {filename: filename}
    fn = hbs.compile str, options
    fn(locals)
