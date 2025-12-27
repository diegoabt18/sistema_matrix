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
            Crea dos hileras de cajones organizados en columnas
          </p>

          <label><strong>Número de Cajones</strong></label><br>
          <input type="number" id="num_cajones" value="6" min="1" style="width: 100%; padding: 5px; margin-bottom: 10px;"><br>

          <label><strong>Número de Columnas</strong></label><br>
          <input type="number" id="num_columnas" value="3" min="1" style="width: 100%; padding: 5px; margin-bottom: 10px;"><br>

          <hr style="margin: 15px 0;">

          <label><strong>Dimensiones de cada cajón:</strong></label><br><br>

          <label>Ancho (profundidad del cajón)</label><br>
          <input type="number" id="ancho_cajon" value="400" min="50" style="width: 100%; padding: 5px; margin-bottom: 10px;"><br>

          <label>Alto (altura del cajón)</label><br>
          <input type="number" id="alto_cajon" value="150" min="50" style="width: 100%; padding: 5px; margin-bottom: 10px;"><br>

          <label>Fondo (profundidad interna)</label><br>
          <input type="number" id="fondo_cajon" value="500" min="50" style="width: 100%; padding: 5px; margin-bottom: 10px;"><br>

          <label>Separación entre cajones (mm)</label><br>
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

      toolbar.show
      @loaded = true
    end

  end
end
