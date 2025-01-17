#include "FL/Fl.H"
#include "FL/fl_draw.H"
#include "FL/platform.H"

#define CAIRO_HAS_GL_SURFACE 1

#if defined (_WIN32) || defined (__WIN32)
#define CAIRO_HAS_WGL_FUNCTIONS 1
#else
#define CAIRO_HAS_GLX_FUNCTIONS 1
#endif

#include "cairo/cairo-gl.h"

#include <cassert>

#include "cairoglwindow.hpp"

//////////////////////////////////////////////////////////////////////////////
Cairo_Gl_Window::Cairo_Gl_Window(int const x, int const y,
  int const w, int const h, const char* const l) :
  Fl_Gl_Window(x, y, w, h, l)
{
  mode(FL_SINGLE | FL_RGB);
  Fl_Group::current(this);
}

//////////////////////////////////////////////////////////////////////////////
Cairo_Gl_Window::Cairo_Gl_Window(int const w, int const h,
  const char* const l) :
  Fl_Gl_Window(w, h, l)
{
  mode(FL_SINGLE | FL_RGB);
  Fl_Group::current(this);
}

//////////////////////////////////////////////////////////////////////////////
Cairo_Gl_Window::~Cairo_Gl_Window()
{
  cairo_destroy(cr_);
}

//////////////////////////////////////////////////////////////////////////////
void Cairo_Gl_Window::draw()
{
  auto const w{this->w()}, h{this->h()};

  auto cr(cr_);
  auto surf(surf_);

  if (!context_valid())
  {
    Fl_Window::make_current();

#if defined (_WIN32) || defined (__WIN32)
    auto const device(cairo_wgl_device_create((HGLRC)fl_display));
    cairo_gl_device_set_thread_aware(device, false);
#else
    auto const device(cairo_glx_device_create(fl_display,                      
      static_cast<GLXContext>(context())));
    cairo_gl_device_set_thread_aware(device, false);
#endif
    assert(cairo_device_status(device) == CAIRO_STATUS_SUCCESS);

    cairo_destroy(cr);

#if defined (_WIN32) || defined (__WIN32)
    cr_ = cr = cairo_create(surf_ = surf =
      cairo_gl_surface_create(device, CAIRO_CONTENT_COLOR_ALPHA, w, h));
#else
    cr_ = cr = cairo_create(surf_ = surf =
      cairo_gl_surface_create_for_window(device, fl_window, w, h));
#endif

    cairo_device_destroy(device);
    cairo_surface_destroy(surf);
    assert(CAIRO_STATUS_SUCCESS == cairo_surface_status(surf_));
    assert(CAIRO_STATUS_SUCCESS == cairo_status(cr));

    //
    i_(cr, w, h);
  }
  else if (!valid())
  {
    cairo_gl_surface_set_size(surf, w, h);
  }

  //
  cairo_save(cr);

  d_(cr, w, h);

  cairo_restore(cr);

  //
  if (children())
  {
    //
    cairo_save(cr);

    //
    cairo_set_antialias(cr, CAIRO_ANTIALIAS_NONE);
//  cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);

    cairo_set_line_width(cr, 1.);

    cairo_identity_matrix(cr);
    cairo_translate(cr, .5, .5);

    surface_device_->set_current();

    Fl_Group::draw_children();

    Fl_Display_Device::display_device()->set_current();

    //
    cairo_restore(cr);
  }

  //
  cairo_surface_flush(surf);
}
