require "gobject/gtk/autorun"
require "lib_gl"
require "./shaderprogram.cr"

def twotriangles() : {Array(Float32), Array(Int32)}

  vertices = [
               0.5,  0.5,  0.0,
               0.5, -0.5,  0.0,
              -0.5, -0.5,  0.0,
              -0.5,  0.5,  0.0
            ]

  indices = [
              0,1,3, # first triangle
              1,2,3  # second triangle
            ]

  vertex_arr = [] of Float32
  vertices.each do |v|
    vertex_arr << v.to_f32
  end

  index_arr = [] of Int32
  indices.each do |v|
    index_arr << v.to_i32
  end

  return vertex_arr, index_arr
end

class GlAreaApp
  @window : Gtk::Window
  @gl_area : Gtk::GLArea
  delegate show_all, to: @window

  def initialize
    @window = Gtk::Window.new
    @window.title = "GlArea demo"
    @window.resize  800,600
    @window.connect "destroy", &->Gtk.main_quit
    @gl_area = Gtk::GLArea.new
    @gl_area.has_depth_buffer= false
    @gl_area.has_stencil_buffer= false
    @gl_area.connect "render", &->render
    @window.add @gl_area
  end
  
 
  
  def render
    # color window background
    window_red     = 0.2
    window_green   = 0.3
    window_blue    = 0.3
    window_opacity = 1.0

    # data
    vertices, indices  = twotriangles()

    nr_vertices = (vertices.size/3).to_i
    nr_indices  = indices.size

    #
    # Make the window the current OpenGL context
    #
    @gl_area.make_current
    #
    # compile shaders
    # must be done in run loop
    #
    shaderprogram = ShaderProgram.new("shader.vs","shader.fs")

    #
    # vbo and ebo buffer (element array buffer)
    #
    LibGL.gen_buffers(1, out vbo_id)
    LibGL.bind_buffer(LibGL::ARRAY_BUFFER, vbo_id)
    LibGL.buffer_data(LibGL::ARRAY_BUFFER, vertices.size * sizeof(Float32), vertices, LibGL::STATIC_DRAW)

    LibGL.gen_buffers(1, out ebo_id)
    LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, ebo_id)
    LibGL.buffer_data(LibGL::ELEMENT_ARRAY_BUFFER, indices.size * sizeof(Int32), indices, LibGL::STATIC_DRAW)

    #
    # vao buffer
    #
    LibGL.gen_vertex_arrays(1, out vao_id)
    LibGL.bind_vertex_array(vao_id)

    LibGL.vertex_attrib_pointer(0, 3, LibGL::FLOAT, LibGL::FALSE, 3 * sizeof(Float32), Pointer(Void).new(0) )
    LibGL.enable_vertex_attrib_array(0)

    #
    # rendering here
    #
    LibGL.clear_color(window_red, window_green, window_blue, window_opacity)
    LibGL.clear(LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT)

    shaderprogram.start()
    # bind vao
    LibGL.bind_vertex_array(vao_id)

    #
    # important to bind the EBO buffer before draw_elements
    #
    LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, ebo_id)
    #
    # draw 2 triangles
    #
    # Note: the 6 is the number of indices
    LibGL.draw_elements(LibGL::TRIANGLES, 6, LibGL::UNSIGNED_INT, Pointer(Void).new(0))


    shaderprogram.stop()
    
  end 
  
 

end

app=GlAreaApp.new
app.show_all
