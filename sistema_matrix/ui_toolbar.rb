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

      toolbar.show
      @loaded = true
    end

  end
end
