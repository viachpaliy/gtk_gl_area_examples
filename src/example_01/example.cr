require "gobject/gtk/autorun"
require "lib_gl"
require "./shaderprogram.cr"

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
    vertices =  [
      -0.5, -0.5, 0.0,
       0.5, -0.5, 0.0,
       0.0,  0.5, 0.0,
    ] of Float32

    nr_vertices = (vertices.size/3).to_i
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
    # vbo buffer
    #
    LibGL.gen_buffers(1, out vbo_id)
    LibGL.bind_buffer(LibGL::ARRAY_BUFFER, vbo_id)
    LibGL.buffer_data(LibGL::ARRAY_BUFFER, vertices.size * sizeof(Float32), vertices, LibGL::STATIC_DRAW)
    
    #
    # vao buffer
    #
    LibGL.gen_vertex_arrays(1, out vao_id)
    LibGL.bind_vertex_array(vao_id)

    LibGL.vertex_attrib_pointer(0, nr_vertices, LibGL::FLOAT, LibGL::FALSE, nr_vertices * sizeof(Float32), Pointer(Void).new(0) )
    LibGL.enable_vertex_attrib_array(0)
    
    #
    # rendering here
    #
    LibGL.clear_color(window_red, window_green, window_blue, window_opacity)
    LibGL.clear(LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT)

    shaderprogram.start()
    # bind vao
    LibGL.bind_vertex_array(vao_id)
    # draw triangle
    LibGL.draw_arrays(LibGL::TRIANGLES, 0, 3)
    shaderprogram.stop()
    
  end 
  
 

end

app=GlAreaApp.new
app.show_all
