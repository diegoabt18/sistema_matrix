module SistemaMatrix
  module Shapes
    extend self

    def create_cube(alto, largo, ancho)
      model = Sketchup.active_model
      ents  = model.active_entities

      group = ents.add_group
      g = group.entities

      p1 = ORIGIN
      p2 = Geom::Point3d.new(largo, 0, 0)
      p3 = Geom::Point3d.new(largo, ancho, 0)
      p4 = Geom::Point3d.new(0, ancho, 0)

      face = g.add_face(p1, p2, p3, p4)
      face.pushpull(alto)

      group.name = "Cubo"
    end

    def create_cone(alto, largo, _ancho)
      model = Sketchup.active_model
      ents  = model.active_entities

      group = ents.add_group
      g = group.entities

      radius = largo / 2.0

      edges = g.add_circle(ORIGIN, Z_AXIS, radius, 32)
      base = g.add_face(edges)

      apex = Geom::Point3d.new(0, 0, alto)
      path = g.add_line(ORIGIN, apex)

      base.followme(path)

      group.name = "Cono"
    end

  end
end
