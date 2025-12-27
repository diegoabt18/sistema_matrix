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

    # Crear un cajón individual de melamina
    # ancho: ancho del cajón (profundidad)
    # alto: altura del cajón
    # fondo: profundidad del cajón
    # grosor_melamina: grosor del tablero (típicamente 18mm)
    # grosor_fondo: grosor del fondo (típicamente 4mm MDF o 6mm melamina)
    # entities: entidades donde crear el cajón (opcional, por defecto crea nuevo grupo)
    def create_drawer(ancho, alto, fondo, grosor_melamina = 18.0, grosor_fondo = 4.0, entities = nil)
      model = Sketchup.active_model
      
      if entities.nil?
        ents = model.active_entities
        group = ents.add_group
        g = group.entities
        return_group = true
      else
        g = entities
        return_group = false
      end

      # Dimensiones internas del cajón
      ancho_int = ancho - (2 * grosor_melamina)
      alto_int = alto - grosor_melamina - grosor_fondo
      fondo_int = fondo - grosor_melamina

      # Frente del cajón
      p1 = ORIGIN
      p2 = Geom::Point3d.new(ancho, 0, 0)
      p3 = Geom::Point3d.new(ancho, grosor_melamina, 0)
      p4 = Geom::Point3d.new(0, grosor_melamina, 0)
      frente = g.add_face(p1, p2, p3, p4)
      frente.pushpull(alto)

      # Lateral izquierdo
      p1 = Geom::Point3d.new(0, grosor_melamina, 0)
      p2 = Geom::Point3d.new(grosor_melamina, grosor_melamina, 0)
      p3 = Geom::Point3d.new(grosor_melamina, grosor_melamina, alto_int)
      p4 = Geom::Point3d.new(0, grosor_melamina, alto_int)
      lateral_izq = g.add_face(p1, p2, p3, p4)
      lateral_izq.pushpull(fondo_int)

      # Lateral derecho
      p1 = Geom::Point3d.new(ancho - grosor_melamina, grosor_melamina, 0)
      p2 = Geom::Point3d.new(ancho, grosor_melamina, 0)
      p3 = Geom::Point3d.new(ancho, grosor_melamina, alto_int)
      p4 = Geom::Point3d.new(ancho - grosor_melamina, grosor_melamina, alto_int)
      lateral_der = g.add_face(p1, p2, p3, p4)
      lateral_der.pushpull(fondo_int)

      # Trasera
      p1 = Geom::Point3d.new(grosor_melamina, grosor_melamina + fondo_int, 0)
      p2 = Geom::Point3d.new(ancho - grosor_melamina, grosor_melamina + fondo_int, 0)
      p3 = Geom::Point3d.new(ancho - grosor_melamina, grosor_melamina + fondo_int, alto_int)
      p4 = Geom::Point3d.new(grosor_melamina, grosor_melamina + fondo_int, alto_int)
      trasera = g.add_face(p1, p2, p3, p4)
      trasera.pushpull(grosor_melamina)

      # Fondo del cajón (en la parte inferior)
      p1 = Geom::Point3d.new(grosor_melamina, grosor_melamina, grosor_fondo)
      p2 = Geom::Point3d.new(ancho - grosor_melamina, grosor_melamina, grosor_fondo)
      p3 = Geom::Point3d.new(ancho - grosor_melamina, grosor_melamina + fondo_int, grosor_fondo)
      p4 = Geom::Point3d.new(grosor_melamina, grosor_melamina + fondo_int, grosor_fondo)
      fondo_cajon = g.add_face(p1, p2, p3, p4)
      fondo_cajon.pushpull(grosor_fondo)

      if return_group
        group.name = "Cajón"
        group
      else
        nil
      end
    end

    # Crear sistema modular de cajones con columnas e hileras
    # num_cajones: número total de cajones
    # num_columnas: número de columnas por hilera
    # ancho_cajon: ancho de cada cajón
    # alto_cajon: altura de cada cajón
    # fondo_cajon: profundidad de cada cajón
    # separacion: separación entre cajones (típicamente 2-3mm)
    def create_drawer_system(num_cajones, num_columnas, ancho_cajon, alto_cajon, fondo_cajon, separacion = 2.0)
      model = Sketchup.active_model
      ents  = model.active_entities

      system_group = ents.add_group
      system_entities = system_group.entities
      
      # Calcular número de hileras (siempre 2 según el requerimiento)
      num_hileras = 2
      cajones_por_hilera = (num_cajones.to_f / num_hileras).ceil

      # Calcular cajones por columna (apilados verticalmente en cada columna)
      cajones_por_columna = (cajones_por_hilera.to_f / num_columnas).ceil

      model.start_operation("Crear Sistema de Cajones", true)
      
      cajon_actual = 0
      (0...num_hileras).each do |hilera|
        # Calcular cuántos cajones quedan para esta hilera
        cajones_restantes_hilera = num_cajones - cajon_actual
        cajones_en_hilera = [cajones_por_hilera, cajones_restantes_hilera].min
        
        (0...num_columnas).each do |columna|
          break if cajon_actual >= num_cajones
          
          # Calcular cuántos cajones en esta columna de esta hilera
          cajones_restantes_columna = cajones_en_hilera - (columna * (cajones_en_hilera.to_f / num_columnas).ceil)
          cajones_en_columna = (cajones_en_hilera.to_f / num_columnas).ceil
          
          if columna == num_columnas - 1
            # Última columna toma los cajones restantes
            cajones_en_columna = cajones_restantes_columna.ceil
          end
          
          # Asegurar que no excedamos el número total de cajones
          cajones_en_columna = [cajones_en_columna, num_cajones - cajon_actual].min
          next if cajones_en_columna <= 0

          # Posición X (columna)
          pos_x = columna * (ancho_cajon + separacion)
          
          # Posición Y (hilera - primera hilera atrás, segunda hilera adelante)
          pos_y = hilera * (fondo_cajon + separacion)
          
          # Crear cajones en esta columna (apilados verticalmente)
          (0...cajones_en_columna).each do |cajon_idx|
            break if cajon_actual >= num_cajones
            
            # Posición Z (altura - apilados desde el suelo)
            pos_z = cajon_idx * (alto_cajon + separacion)
            
            # Crear un subgrupo para este cajón dentro del sistema
            cajon_group = system_entities.add_group
            cajon_entities = cajon_group.entities
            
            # Crear el cajón directamente en el grupo del sistema
            create_drawer(ancho_cajon, alto_cajon, fondo_cajon, 18.0, 4.0, cajon_entities)
            
            # Mover el cajón a la posición correcta
            cajon_group.move!(Geom::Vector3d.new(pos_x, pos_y, pos_z))
            cajon_group.name = "Cajón #{cajon_actual + 1}"
            
            cajon_actual += 1
          end
        end
      end

      model.commit_operation
      system_group.name = "Sistema de Cajones (#{num_cajones} cajones, #{num_columnas} columnas)"
      system_group
    end

  end
end
