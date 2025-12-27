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
    # Todas las medidas deben estar en milímetros
    # ancho: ancho del cajón (profundidad)
    # alto: altura del cajón
    # fondo: profundidad del cajón
    # grosor_melamina: grosor del tablero (típicamente 18mm)
    # grosor_fondo: grosor del fondo (típicamente 4mm MDF o 6mm melamina)
    # entities: entidades donde crear el cajón (opcional, por defecto crea nuevo grupo)
    def create_drawer(ancho, alto, fondo, grosor_melamina = 18.0, grosor_fondo = 4.0, entities = nil)
      model = Sketchup.active_model
      
      # Convertir milímetros a las unidades del modelo de SketchUp
      # SketchUp internamente trabaja en pulgadas, pero respeta las unidades del modelo
      begin
        length_unit = model.options['UnitsOptions'].get_value('LengthUnit')
        if length_unit != Length::Millimeter
          # Convertir de milímetros a pulgadas (1 pulgada = 25.4 mm)
          scale = 1.0 / 25.4
          ancho = ancho * scale
          alto = alto * scale
          fondo = fondo * scale
          grosor_melamina = grosor_melamina * scale
          grosor_fondo = grosor_fondo * scale
        end
      rescue
        # Si hay error al leer las unidades, asumir que están en milímetros
        # SketchUp convertirá automáticamente según la configuración del modelo
      end
      
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
      fondo_int = fondo - grosor_melamina  # Profundidad interna sin la trasera
      alto_int = alto - grosor_fondo  # Altura interna sin el fondo

      # Fondo del cajón primero (en Z=0, dentro del cajón)
      p1 = Geom::Point3d.new(grosor_melamina, grosor_melamina, 0)
      p2 = Geom::Point3d.new(ancho - grosor_melamina, grosor_melamina, 0)
      p3 = Geom::Point3d.new(ancho - grosor_melamina, grosor_melamina + fondo_int, 0)
      p4 = Geom::Point3d.new(grosor_melamina, grosor_melamina + fondo_int, 0)
      fondo_cajon = g.add_face(p1, p2, p3, p4)
      fondo_cajon.pushpull(grosor_fondo)

      # Lateral izquierdo (en X=0, desde Y=grosor_melamina, desde Z=grosor_fondo)
      p1 = Geom::Point3d.new(0, grosor_melamina, grosor_fondo)
      p2 = Geom::Point3d.new(grosor_melamina, grosor_melamina, grosor_fondo)
      p3 = Geom::Point3d.new(grosor_melamina, grosor_melamina, alto)
      p4 = Geom::Point3d.new(0, grosor_melamina, alto)
      lateral_izq = g.add_face(p1, p2, p3, p4)
      lateral_izq.pushpull(fondo_int)

      # Lateral derecho (en X=ancho, desde Y=grosor_melamina, desde Z=grosor_fondo)
      p1 = Geom::Point3d.new(ancho - grosor_melamina, grosor_melamina, grosor_fondo)
      p2 = Geom::Point3d.new(ancho, grosor_melamina, grosor_fondo)
      p3 = Geom::Point3d.new(ancho, grosor_melamina, alto)
      p4 = Geom::Point3d.new(ancho - grosor_melamina, grosor_melamina, alto)
      lateral_der = g.add_face(p1, p2, p3, p4)
      lateral_der.pushpull(fondo_int)

      # Trasera (en Y=grosor_melamina+fondo_int, desde Z=grosor_fondo)
      p1 = Geom::Point3d.new(grosor_melamina, grosor_melamina + fondo_int, grosor_fondo)
      p2 = Geom::Point3d.new(ancho - grosor_melamina, grosor_melamina + fondo_int, grosor_fondo)
      p3 = Geom::Point3d.new(ancho - grosor_melamina, grosor_melamina + fondo_int, alto)
      p4 = Geom::Point3d.new(grosor_melamina, grosor_melamina + fondo_int, alto)
      trasera = g.add_face(p1, p2, p3, p4)
      trasera.pushpull(grosor_melamina)

      # Frente del cajón (en Y=0, cubre todo el ancho y alto, alineado con laterales)
      p1 = ORIGIN
      p2 = Geom::Point3d.new(ancho, 0, 0)
      p3 = Geom::Point3d.new(ancho, 0, alto)
      p4 = Geom::Point3d.new(0, 0, alto)
      frente = g.add_face(p1, p2, p3, p4)
      frente.pushpull(grosor_melamina)

      if return_group
        group.name = "Cajón"
        group
      else
        nil
      end
    end

    # Crear sistema modular de cajones con columnas
    # Los cajones se apilan verticalmente en cada columna
    # num_cajones: número total de cajones
    # num_columnas: número de columnas
    # ancho_cajon: ancho de cada cajón
    # alto_cajon: altura de cada cajón
    # fondo_cajon: profundidad de cada cajón
    # separacion: separación entre cajones (típicamente 2-3mm)
    def create_drawer_system(num_cajones, num_columnas, ancho_cajon, alto_cajon, fondo_cajon, separacion = 2.0)
      model = Sketchup.active_model
      ents  = model.active_entities

      system_group = ents.add_group
      system_entities = system_group.entities
      
      # Calcular cajones por columna (apilados verticalmente)
      cajones_por_columna = (num_cajones.to_f / num_columnas).ceil

      model.start_operation("Crear Sistema de Cajones", true)
      
      cajon_actual = 0
      
      # Crear cajones distribuidos en columnas
      (0...num_columnas).each do |columna|
        break if cajon_actual >= num_cajones
        
        # Calcular cuántos cajones en esta columna
        cajones_restantes = num_cajones - cajon_actual
        cajones_en_columna = [cajones_por_columna, cajones_restantes].min
        
        # Posición X (columna)
        pos_x = columna * (ancho_cajon + separacion)
        
        # Posición Y (todos los cajones en la misma posición Y)
        pos_y = 0
        
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

      model.commit_operation
      system_group.name = "Sistema de Cajones (#{num_cajones} cajones, #{num_columnas} columnas)"
      system_group
    end

    # Crear mueble tipo mesa de noche con cajones
    # num_cajones: número total de cajones
    # num_columnas: número de columnas
    # profundidad: profundidad del mueble (en mm)
    # grosor_tablero: grosor de los tableros MDF (10-25mm, por defecto 18mm)
    # espaciado_y: espaciado entre cajones en eje Y (mínimo 20mm)
    # espaciado_lateral: espaciado lateral entre columnas (mínimo 3mm)
    def create_nightstand(num_cajones, num_columnas, profundidad, grosor_tablero = 18.0, espaciado_y = 20.0, espaciado_lateral = 3.0)
      model = Sketchup.active_model
      
      # Convertir milímetros a las unidades del modelo de SketchUp
      begin
        length_unit = model.options['UnitsOptions'].get_value('LengthUnit')
        if length_unit != Length::Millimeter
          # Convertir de milímetros a pulgadas (1 pulgada = 25.4 mm)
          scale = 1.0 / 25.4
          profundidad = profundidad * scale
          grosor_tablero = grosor_tablero * scale
          espaciado_y = espaciado_y * scale
          espaciado_lateral = espaciado_lateral * scale
        end
      rescue
        # Si hay error al leer las unidades, asumir que están en milímetros
        # SketchUp convertirá automáticamente según la configuración del modelo
      end
      
      # Validaciones (después de la conversión, pero los valores mínimos también deben convertirse)
      grosor_min = 10.0
      grosor_max = 25.0
      espaciado_y_min = 20.0
      espaciado_lateral_min = 3.0
      
      begin
        length_unit = model.options['UnitsOptions'].get_value('LengthUnit')
        if length_unit != Length::Millimeter
          scale = 1.0 / 25.4
          grosor_min = grosor_min * scale
          grosor_max = grosor_max * scale
          espaciado_y_min = espaciado_y_min * scale
          espaciado_lateral_min = espaciado_lateral_min * scale
        end
      rescue
      end
      
      if grosor_tablero < grosor_min || grosor_tablero > grosor_max
        UI.messagebox("El grosor del tablero debe estar entre 10mm y 25mm")
        return nil
      end
      
      if espaciado_y < espaciado_y_min
        UI.messagebox("El espaciado entre cajones debe ser mínimo 20mm")
        return nil
      end
      
      if espaciado_lateral < espaciado_lateral_min
        UI.messagebox("El espaciado lateral debe ser mínimo 3mm")
        return nil
      end
      
      # Altura mínima de cajón: 115mm
      alto_cajon_min = 115.0
      begin
        length_unit = model.options['UnitsOptions'].get_value('LengthUnit')
        if length_unit != Length::Millimeter
          scale = 1.0 / 25.4
          alto_cajon_min = alto_cajon_min * scale
        end
      rescue
      end
      
      # Calcular cajones por columna
      cajones_por_columna = (num_cajones.to_f / num_columnas).ceil
      
      # Calcular altura total del mueble
      # Altura = (cajones_por_columna * alto_cajon_min) + ((cajones_por_columna - 1) * espaciado_y)
      altura_total = (cajones_por_columna * alto_cajon_min) + ((cajones_por_columna - 1) * espaciado_y)
      
      # Calcular ancho de cada columna
      # Si hay múltiples columnas, necesitamos dividir el espacio considerando los tableros divisores
      # Ancho total = (num_columnas * ancho_columna) + ((num_columnas - 1) * grosor_tablero) + (2 * espaciado_lateral)
      # Para simplificar, calculamos el ancho disponible por columna
      # Asumimos que el ancho de cada columna es igual a la profundidad (mueble cuadrado en planta)
      ancho_columna = profundidad
      
      # Calcular ancho total del mueble
      if num_columnas == 1
        ancho_total = ancho_columna
      else
        # Ancho total = columnas + tableros divisores + espaciados laterales
        ancho_total = (num_columnas * ancho_columna) + ((num_columnas - 1) * grosor_tablero) + (2 * espaciado_lateral)
      end
      
      ents = model.active_entities
      system_group = ents.add_group
      system_entities = system_group.entities
      
      model.start_operation("Crear Mesa de Noche", true)
      
      cajon_actual = 0
      grosor_fondo = 4.0  # Grosor del fondo del cajón (MDF)
      begin
        length_unit = model.options['UnitsOptions'].get_value('LengthUnit')
        if length_unit != Length::Millimeter
          scale = 1.0 / 25.4
          grosor_fondo = grosor_fondo * scale
        end
      rescue
      end
      
      # Crear cajones distribuidos en columnas
      (0...num_columnas).each do |columna|
        break if cajon_actual >= num_cajones
        
        # Calcular cuántos cajones en esta columna
        cajones_restantes = num_cajones - cajon_actual
        cajones_en_columna = [cajones_por_columna, cajones_restantes].min
        
        # Calcular posición X de la columna
        if num_columnas == 1
          pos_x_columna = 0
        else
          # Posición X = espaciado_lateral + (columna * (ancho_columna + grosor_tablero))
          pos_x_columna = espaciado_lateral + (columna * (ancho_columna + grosor_tablero))
        end
        
        # Posición Y inicial (todos los cajones empiezan en Y=0)
        pos_y = 0
        
        # Crear cajones en esta columna (apilados verticalmente)
        (0...cajones_en_columna).each do |cajon_idx|
          break if cajon_actual >= num_cajones
          
          # Posición Z (altura - apilados desde el suelo)
          pos_z = cajon_idx * (alto_cajon_min + espaciado_y)
          
          # Crear un subgrupo para este cajón
          cajon_group = system_entities.add_group
          cajon_entities = cajon_group.entities
          
          # Dimensiones internas del cajón
          fondo_int = profundidad - grosor_tablero  # Profundidad interna sin la trasera
          alto_int = alto_cajon_min - grosor_fondo  # Altura interna sin el fondo
          
          # === FONDO DEL CAJÓN ===
          p1 = Geom::Point3d.new(grosor_tablero, grosor_tablero, 0)
          p2 = Geom::Point3d.new(ancho_columna - grosor_tablero, grosor_tablero, 0)
          p3 = Geom::Point3d.new(ancho_columna - grosor_tablero, grosor_tablero + fondo_int, 0)
          p4 = Geom::Point3d.new(grosor_tablero, grosor_tablero + fondo_int, 0)
          fondo_cajon = cajon_entities.add_face(p1, p2, p3, p4)
          fondo_cajon.pushpull(grosor_fondo)
          
          # === LATERAL IZQUIERDO ===
          p1 = Geom::Point3d.new(0, grosor_tablero, grosor_fondo)
          p2 = Geom::Point3d.new(grosor_tablero, grosor_tablero, grosor_fondo)
          p3 = Geom::Point3d.new(grosor_tablero, grosor_tablero, alto_cajon_min)
          p4 = Geom::Point3d.new(0, grosor_tablero, alto_cajon_min)
          lateral_izq = cajon_entities.add_face(p1, p2, p3, p4)
          lateral_izq.pushpull(fondo_int)
          
          # === LATERAL DERECHO ===
          p1 = Geom::Point3d.new(ancho_columna - grosor_tablero, grosor_tablero, grosor_fondo)
          p2 = Geom::Point3d.new(ancho_columna, grosor_tablero, grosor_fondo)
          p3 = Geom::Point3d.new(ancho_columna, grosor_tablero, alto_cajon_min)
          p4 = Geom::Point3d.new(ancho_columna - grosor_tablero, grosor_tablero, alto_cajon_min)
          lateral_der = cajon_entities.add_face(p1, p2, p3, p4)
          lateral_der.pushpull(fondo_int)
          
          # === TRASERA ===
          p1 = Geom::Point3d.new(grosor_tablero, grosor_tablero + fondo_int, grosor_fondo)
          p2 = Geom::Point3d.new(ancho_columna - grosor_tablero, grosor_tablero + fondo_int, grosor_fondo)
          p3 = Geom::Point3d.new(ancho_columna - grosor_tablero, grosor_tablero + fondo_int, alto_cajon_min)
          p4 = Geom::Point3d.new(grosor_tablero, grosor_tablero + fondo_int, alto_cajon_min)
          trasera = cajon_entities.add_face(p1, p2, p3, p4)
          trasera.pushpull(grosor_tablero)
          
          # === TAPA DELANTERA ===
          # Si es una sola columna, la tapa ocupa todo el ancho del mueble
          # Si hay múltiples columnas, la tapa se ajusta para no chocar con otras columnas
          if num_columnas == 1
            # Una sola columna: tapa ocupa todo el ancho
            ancho_tapa = ancho_columna
            pos_x_tapa = 0
          else
            # Múltiples columnas: la tapa se ajusta para no chocar
            # El ancho de la tapa es el ancho de la columna, pero considerando el espaciado
            # La tapa debe quedar dentro de los límites de su columna
            ancho_tapa = ancho_columna
            pos_x_tapa = 0
          end
          
          p1 = Geom::Point3d.new(pos_x_tapa, 0, 0)
          p2 = Geom::Point3d.new(pos_x_tapa + ancho_tapa, 0, 0)
          p3 = Geom::Point3d.new(pos_x_tapa + ancho_tapa, 0, alto_cajon_min)
          p4 = Geom::Point3d.new(pos_x_tapa, 0, alto_cajon_min)
          tapa = cajon_entities.add_face(p1, p2, p3, p4)
          tapa.pushpull(grosor_tablero)
          
          # Mover el cajón a la posición correcta
          cajon_group.move!(Geom::Vector3d.new(pos_x_columna, pos_y, pos_z))
          cajon_group.name = "Cajón #{cajon_actual + 1}"
          
          cajon_actual += 1
        end
        
        # === CREAR TABLERO DIVISOR ENTRE COLUMNAS ===
        if num_columnas > 1 && columna < num_columnas - 1
          # El tablero divisor va entre esta columna y la siguiente
          divisor_group = system_entities.add_group
          divisor_entities = divisor_group.entities
          
          # Posición X del divisor
          pos_x_divisor = pos_x_columna + ancho_columna
          
          # El divisor va desde el suelo hasta la altura total
          p1 = Geom::Point3d.new(0, 0, 0)
          p2 = Geom::Point3d.new(grosor_tablero, 0, 0)
          p3 = Geom::Point3d.new(grosor_tablero, 0, altura_total)
          p4 = Geom::Point3d.new(0, 0, altura_total)
          divisor_face = divisor_entities.add_face(p1, p2, p3, p4)
          divisor_face.pushpull(profundidad)
          
          divisor_group.move!(Geom::Vector3d.new(pos_x_divisor, 0, 0))
          divisor_group.name = "Tablero Divisor #{columna + 1}"
        end
      end
      
      model.commit_operation
      system_group.name = "Mesa de Noche (#{num_cajones} cajones, #{num_columnas} columnas)"
      system_group
    end

  end
end
