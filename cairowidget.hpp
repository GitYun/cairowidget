#ifndef CAIROWIDGET_HPP
# define CAIROWIDGET_HPP
# pragma once

#include "cairo/cairo.h"

#include "FL/Fl_Widget.H"

#include <functional>

#include <memory>

class CairoWidget: public Fl_Widget
{
  struct S;

  cairo_t* cr_;
  cairo_surface_t* surf_;

  int pixels_;

  std::unique_ptr<unsigned char[]> data_;
  int datasize_{};

  using draw_t = std::function<void(cairo_t*, int, int)>;

  draw_t d_;
  draw_t i_;

  void draw() final;

public:
  CairoWidget(int, int, int, int, const char* = nullptr);
  ~CairoWidget();

  //
  template <class U>
  void init(U&& u) noexcept(noexcept(i_ = std::forward<U>(u)))
  {
    i_ = std::forward<U>(u);
  }

  auto& draw() const noexcept;

  template <class U>
  void draw(U&& u) noexcept(noexcept(d_ = std::forward<U>(u)))
  {
    d_ = std::forward<U>(u);
  }
};

//////////////////////////////////////////////////////////////////////////////
inline auto& CairoWidget::draw() const noexcept
{
  return d_;
}

#endif // CAIROWIDGET_HPP
