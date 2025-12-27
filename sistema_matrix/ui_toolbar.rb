module SistemaMatrix
  module UIControls
    extend self

    def show_dimension_dialog(shape)
      dialog = UI::HtmlDialog.new(
        dialog_title: "Dimensiones #{shape}",
        width: 380,
        height: 300
      )

      html = <<-HTML
        <html>
        <body style="font-family: Arial; padding: 10px;">
          <h3>#{shape.capitalize}</h3>

          <label>Alto</label><br>
          <input id="alto" value="100"><br><br>

          <label>Largo</label><br>
          <input id="largo" value="100"><br><br>

          <label>Ancho</label><br>
          <input id="ancho" value="100"><br><br>

          <button onclick="send()">Crear</button>

          <script>
            function send() {
              sketchup.sendDims(
                "#{shape}",
                document.getElementById("alto").value,
                document.getElementById("largo").value,
                document.getElementById("ancho").value
              );
            }
          </script>
        </body>
        </html>
      HTML

      dialog.set_html(html)

      dialog.add_action_callback("sendDims") do |_, s, a, l, an|
        a = a.to_f; l = l.to_f; an = an.to_f

        case s
        when "cubo"
          SistemaMatrix::Shapes.create_cube(a, l, an)
        when "cono"
          SistemaMatrix::Shapes.create_cone(a, l, an)
        end
      end

      dialog.show
    end

    def show_drawer_system_dialog
      dialog = UI::HtmlDialog.new(
        dialog_title: "Sistema Modular de Cajones",
        width: 450,
        height: 450
      )

      html = <<-HTML
        <html>
        <body style="font-family: Arial; padding: 15px;">
          <h3>Sistema Modular de Cajones</h3>
          <p style="font-size: 12px; color: #666;">
            Crea cajones apilados verticalmente en columnas
          </p>

          <label><strong>Número de Cajones</strong></label><br>
          <input type="number" id="num_cajones" value="6" min="1" style="width: 100%; padding: 5px; margin-bottom: 10px;"><br>

          <label><strong>Número de Columnas</strong></label><br>
          <input type="number" id="num_columnas" value="3" min="1" style="width: 100%; padding: 5px; margin-bottom: 10px;"><br>

          <hr style="margin: 15px 0;">

          <label><strong>Dimensiones de cada cajón (en milímetros):</strong></label><br><br>

          <label>Ancho (profundidad del cajón) - mm</label><br>
          <input type="number" id="ancho_cajon" value="400" min="50" style="width: 100%; padding: 5px; margin-bottom: 10px;"><br>

          <label>Alto (altura del cajón) - mm</label><br>
          <input type="number" id="alto_cajon" value="150" min="50" style="width: 100%; padding: 5px; margin-bottom: 10px;"><br>

          <label>Fondo (profundidad interna) - mm</label><br>
          <input type="number" id="fondo_cajon" value="500" min="50" style="width: 100%; padding: 5px; margin-bottom: 10px;"><br>

          <label>Separación entre cajones - mm</label><br>
          <input type="number" id="separacion" value="2" min="0" step="0.5" style="width: 100%; padding: 5px; margin-bottom: 15px;"><br>

          <button onclick="send()" style="width: 100%; padding: 10px; background-color: #4CAF50; color: white; border: none; cursor: pointer; font-size: 14px; font-weight: bold;">
            Crear Sistema de Cajones
          </button>

          <script>
            function send() {
              var numCajones = parseInt(document.getElementById("num_cajones").value);
              var numColumnas = parseInt(document.getElementById("num_columnas").value);
              var ancho = parseFloat(document.getElementById("ancho_cajon").value);
              var alto = parseFloat(document.getElementById("alto_cajon").value);
              var fondo = parseFloat(document.getElementById("fondo_cajon").value);
              var separacion = parseFloat(document.getElementById("separacion").value);

              if (numCajones < 1 || numColumnas < 1) {
                alert("El número de cajones y columnas debe ser al menos 1");
                return;
              }

              sketchup.createDrawerSystem(
                numCajones,
                numColumnas,
                ancho,
                alto,
                fondo,
                separacion
              );
            }
          </script>
        </body>
        </html>
      HTML

      dialog.set_html(html)

      dialog.add_action_callback("createDrawerSystem") do |_, num_cajones, num_columnas, ancho, alto, fondo, separacion|
        num_cajones = num_cajones.to_i
        num_columnas = num_columnas.to_i
        ancho = ancho.to_f
        alto = alto.to_f
        fondo = fondo.to_f
        separacion = separacion.to_f

        if num_cajones < 1 || num_columnas < 1
          UI.messagebox("El número de cajones y columnas debe ser al menos 1")
        else
          SistemaMatrix::Shapes.create_drawer_system(num_cajones, num_columnas, ancho, alto, fondo, separacion)
          dialog.close
        end
      end

      dialog.show
    end

    def show_nightstand_dialog
      dialog = UI::HtmlDialog.new(
        dialog_title: "Mesa de Noche con Cajones",
        width: 450,
        height: 550
      )

      html = <<-HTML
        <html>
        <body style="font-family: Arial; padding: 15px;">
          <h3>Mesa de Noche con Cajones</h3>
          <p style="font-size: 12px; color: #666;">
            Crea un mueble tipo mesa de noche con cajones modulares
          </p>

          <label><strong>Número de Cajones</strong></label><br>
          <input type="number" id="num_cajones" value="4" min="1" style="width: 100%; padding: 5px; margin-bottom: 10px;"><br>

          <label><strong>Número de Columnas</strong></label><br>
          <input type="number" id="num_columnas" value="2" min="1" style="width: 100%; padding: 5px; margin-bottom: 10px;"><br>

          <hr style="margin: 15px 0;">

          <label><strong>Profundidad del Mueble (mm)</strong></label><br>
          <input type="number" id="profundidad" value="400" min="100" style="width: 100%; padding: 5px; margin-bottom: 10px;"><br>

          <label><strong>Grosor del Tablero MDF (mm)</strong></label><br>
          <input type="number" id="grosor_tablero" value="18" min="10" max="25" step="0.5" style="width: 100%; padding: 5px; margin-bottom: 10px;">
          <p style="font-size: 11px; color: #888; margin-top: 2px;">Rango: 10-25 mm (por defecto 18mm)</p>

          <label><strong>Espaciado entre Cajones - Eje Y (mm)</strong></label><br>
          <input type="number" id="espaciado_y" value="20" min="20" step="0.5" style="width: 100%; padding: 5px; margin-bottom: 10px;">
          <p style="font-size: 11px; color: #888; margin-top: 2px;">Mínimo: 20 mm</p>

          <label><strong>Espaciado Lateral entre Columnas (mm)</strong></label><br>
          <input type="number" id="espaciado_lateral" value="3" min="3" step="0.5" style="width: 100%; padding: 5px; margin-bottom: 15px;">
          <p style="font-size: 11px; color: #888; margin-top: 2px;">Mínimo: 3 mm (para tableros divisores)</p>

          <div style="background-color: #f0f0f0; padding: 10px; border-radius: 5px; margin-bottom: 15px; font-size: 11px;">
            <strong>Notas:</strong><br>
            • Los cajones tienen altura mínima de 115mm<br>
            • Cada cajón está formado por 4 tableros + tapa delantera<br>
            • Las tapas delanteras se ajustan automáticamente según el número de columnas
          </div>

          <button onclick="send()" style="width: 100%; padding: 10px; background-color: #2196F3; color: white; border: none; cursor: pointer; font-size: 14px; font-weight: bold;">
            Crear Mesa de Noche
          </button>

          <script>
            function send() {
              var numCajones = parseInt(document.getElementById("num_cajones").value);
              var numColumnas = parseInt(document.getElementById("num_columnas").value);
              var profundidad = parseFloat(document.getElementById("profundidad").value);
              var grosorTablero = parseFloat(document.getElementById("grosor_tablero").value);
              var espaciadoY = parseFloat(document.getElementById("espaciado_y").value);
              var espaciadoLateral = parseFloat(document.getElementById("espaciado_lateral").value);

              if (numCajones < 1 || numColumnas < 1) {
                alert("El número de cajones y columnas debe ser al menos 1");
                return;
              }

              if (grosorTablero < 10 || grosorTablero > 25) {
                alert("El grosor del tablero debe estar entre 10mm y 25mm");
                return;
              }

              if (espaciadoY < 20) {
                alert("El espaciado entre cajones debe ser mínimo 20mm");
                return;
              }

              if (espaciadoLateral < 3) {
                alert("El espaciado lateral debe ser mínimo 3mm");
                return;
              }

              sketchup.createNightstand(
                numCajones,
                numColumnas,
                profundidad,
                grosorTablero,
                espaciadoY,
                espaciadoLateral
              );
            }
          </script>
        </body>
        </html>
      HTML

      dialog.set_html(html)

      dialog.add_action_callback("createNightstand") do |_, num_cajones, num_columnas, profundidad, grosor_tablero, espaciado_y, espaciado_lateral|
        num_cajones = num_cajones.to_i
        num_columnas = num_columnas.to_i
        profundidad = profundidad.to_f
        grosor_tablero = grosor_tablero.to_f
        espaciado_y = espaciado_y.to_f
        espaciado_lateral = espaciado_lateral.to_f

        if num_cajones < 1 || num_columnas < 1
          UI.messagebox("El número de cajones y columnas debe ser al menos 1")
        elsif grosor_tablero < 10.0 || grosor_tablero > 25.0
          UI.messagebox("El grosor del tablero debe estar entre 10mm y 25mm")
        elsif espaciado_y < 20.0
          UI.messagebox("El espaciado entre cajones debe ser mínimo 20mm")
        elsif espaciado_lateral < 3.0
          UI.messagebox("El espaciado lateral debe ser mínimo 3mm")
        else
          SistemaMatrix::Shapes.create_nightstand(num_cajones, num_columnas, profundidad, grosor_tablero, espaciado_y, espaciado_lateral)
          dialog.close
        end
      end

      dialog.show
    end


    # ===== Toolbar =====
    unless @loaded
      toolbar = UI::Toolbar.new("Sistema Matrix")

      cmd_cube = UI::Command.new("Cubo") do
        show_dimension_dialog("cubo")
      end
      toolbar.add_item(cmd_cube)

      cmd_cone = UI::Command.new("Cono") do
        show_dimension_dialog("cono")
      end
      toolbar.add_item(cmd_cone)

      cmd_drawers = UI::Command.new("Sistema de Cajones") do
        show_drawer_system_dialog
      end
      toolbar.add_item(cmd_drawers)

      cmd_nightstand = UI::Command.new("Mesa de Noche") do
        show_nightstand_dialog
      end
      toolbar.add_item(cmd_nightstand)

      toolbar.show
      @loaded = true
    end

  end
end
