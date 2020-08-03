require "gobject/gtk/autorun"
require "lib_gl"
require "./shaderprogram"
require "./color"

class Display
  @window : Gtk::Window
  @gl_area : Gtk::GLArea
  @vertices : Array(Float32)
  @indices : Array(Int32)
  delegate show_all, to: @window
  property title  : String = ""
  property width  : Int32 = 800
  property height : Int32 = 600
  property bg     : Color

  def initialize(title : String, width : Int32, height : Int32, bg : Color)
    @title  = title
    @width  = width
    @height = height
    @bg     = bg
    @window = Gtk::Window.new
    @window.title = @title
    @window.resize  @width, @height
    @window.connect "destroy", &->Gtk.main_quit
    @vertices = Array(Float32).new
    @indices = Array(Int32).new
    @gl_area = Gtk::GLArea.new
    @gl_area.has_depth_buffer= false
    @gl_area.has_stencil_buffer= false
    @gl_area.connect "render", &->render
    @window.add @gl_area
  end
  
  def vertices=(array : Array(Float32))
    @vertices = array
  end
 
  def indices=(array : Array(Int32))
    @indices = array
  end
  
  def render
    # color window background
    window_red     = 0.2
    window_green   = 0.3
    window_blue    = 0.3
    window_opacity = 1.0

    
    
    nr_vertices = (@vertices.size/3).to_i
    nr_indices  = @indices.size

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
    LibGL.buffer_data(LibGL::ARRAY_BUFFER, @vertices.size * sizeof(Float32), @vertices, LibGL::STATIC_DRAW)

    LibGL.gen_buffers(1, out ebo_id)
    LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, ebo_id)
    LibGL.buffer_data(LibGL::ELEMENT_ARRAY_BUFFER, @indices.size * sizeof(Int32), @indices, LibGL::STATIC_DRAW)

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
