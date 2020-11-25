#include "Fl/fl_draw.h"

#include "nanosvg.h"

#include <cstdint>

#include <bit>

#include <utility>

#include "cairowidget.hpp"

//////////////////////////////////////////////////////////////////////////////
template <std::size_t ...I, std::size_t ...J, typename T>
static constexpr T shuffle(T const i, std::index_sequence<J...>) noexcept
{
  return ((((i >> 8 * I) & 0xff) << 8 * J) | ...);
}

template <std::size_t ...I, typename T>
static constexpr T shuffle(T const i) noexcept
{
  return shuffle<I...>(i, std::make_index_sequence<sizeof...(I)>());
}

//////////////////////////////////////////////////////////////////////////////
CairoWidget::CairoWidget(int const x, int const y, int const w, int const h,
  const char* const l) :
  Fl_Widget(x, y, w, h, l)
{
}

//////////////////////////////////////////////////////////////////////////////
CairoWidget::~CairoWidget()
{
  cairo_destroy(cr_);
}

//////////////////////////////////////////////////////////////////////////////
void CairoWidget::draw()
{
  auto const ww(w()), wh(h());

  auto cr(cr_);
  cairo_surface_t* surf;

  if (!cr ||
    (cairo_image_surface_get_width(surf = cairo_get_target(cr)) != ww) ||
    (cairo_image_surface_get_height(surf) != wh))
  {
    // cr invalidated or not existing
    cairo_destroy(cr);

    // generate a cairo context
    cr_ = cr = cairo_create(surf =
      cairo_image_surface_create(CAIRO_FORMAT_RGB24, ww, wh));
    cairo_surface_destroy(surf);

    // some defaults
    cairo_set_line_width(cr, 1.);
    cairo_translate(cr, .5, .5);
  }

  cairo_save(cr);

  d_(cr, ww, wh);

  cairo_restore(cr);

  //cairo_surface_flush(surf);

  auto const converter(
    [](void* const s, int const x, int const y, int w,
      uchar* const buf) noexcept
    {
      auto const surf(static_cast<cairo_surface_t*>(s));

      auto src(reinterpret_cast<std::uint32_t*>(
        cairo_image_surface_get_data(surf) +
        (y * cairo_image_surface_get_stride(surf))) + x);
      auto dst(reinterpret_cast<std::uint32_t*>(buf));

      while (w--)
      {
        if constexpr (std::endian::little == std::endian::native)
          *dst++ = shuffle<2, 1, 0>(*src++); // ARGB -> ABGR -> RGBA
        else if constexpr (std::endian::big == std::endian::native)
          *dst++ = *src++ << 8; // ARGB -> RGBA
      }
    }
  );

  fl_draw_image(converter, surf, x(), y(), ww, wh, 4);
}
