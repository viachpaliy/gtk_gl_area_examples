require "gobject/gtk/autorun"
require "lib_gl"
require "./shaderprogram"
require "./display"



def lesson(title : String = "OpenGL lesson 3, introduce class Display and struct Color", width : Int32 = 800, height : Int32 = 600)

  bg = Color.new(0.2,0.3,0.3,1.0)
  display = Display.new(title, width, height, bg)
  display.vertices = [
                     0.5,  0.5,  0.0,
                     0.5, -0.5,  0.0,
                     -0.5, -0.5,  0.0,
                     -0.5,  0.5,  0.0
                   ] of Float32
  display.indices = [
                    0,1,3, # first triangle
                    1,2,3  # second triangle
                  ] of Int32
  display.show_all

end

lesson()

