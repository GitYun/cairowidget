#ifndef CAIROWINDOW_HPP
# define CAIROWINDOW_HPP
# pragma once

#include "Fl/Fl_Window.H"

#include "cairo/cairo.h"

#include <functional>

class CairoWindow: public Fl_Window
{
  struct S;

  cairo_t* cr_{};
  int w_, h_;

  using draw_t = std::function<void(cairo_t*, int, int)>;
  draw_t d_{[](cairo_t*, int, int) noexcept {}};

  void draw() final;

public:
  CairoWindow(int, int, const char* = nullptr);
  CairoWindow(int, int, int, int, const char* = nullptr);
  ~CairoWindow();

  auto ctx() const noexcept;

  auto& draw() const noexcept;

  template <class U>
  void draw(U&& u) noexcept(noexcept(d_ = std::forward<U>(u)))
  {
    d_ = std::forward<U>(u);
  }
};

//////////////////////////////////////////////////////////////////////////////
inline auto CairoWindow::ctx() const noexcept
{
  return cr_;
}

//////////////////////////////////////////////////////////////////////////////
inline auto& CairoWindow::draw() const noexcept
{
  return d_;
}

#endif // CAIROWINDOW_HPP
