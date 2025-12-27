require 'sketchup.rb'
require 'extensions.rb'

ext = SketchupExtension.new(
  "Sistema Matrix",
  "sistema_matrix/main"
)

ext.version = "1.0.0"
ext.creator = "Diego"
ext.description = "Herramientas paramétricas de figuras."

Sketchup.register_extension(ext, true)