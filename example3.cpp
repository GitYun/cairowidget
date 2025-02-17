#include <QApplication>
#include <QBitmap>
#include <QCursor>
#include <QMouseEvent>

#include "cairo/cairo.h"

#include "nanosvg/src/nanosvg.h"

#include "caironanosvg.hpp"

#include "CairoWidget.hpp"

class MyWidget final: public CairoWidget
{
  struct NSVGimage* image_{};
  QPoint p_;

public:
  explicit MyWidget():
    CairoWidget(nullptr, Qt::FramelessWindowHint)
  {
    setAttribute(Qt::WA_TranslucentBackground);

    image_ = nsvgParseFromFile("nanosvg/example/23.svg", "px", 96);

    init([](auto const cr, auto, auto) noexcept
      {
        cairo_set_antialias(cr, CAIRO_ANTIALIAS_BEST);
      }
    );

    draw([&](cairo_t* const cr, int const w, int const h)
      {
        cairo_set_operator(cr, CAIRO_OPERATOR_CLEAR);
        cairo_paint(cr);

        if (image_)
        {
          cairo_set_operator(cr, CAIRO_OPERATOR_OVER);

          draw_svg_image(cr, image_, 0, 0, w, h);
        }
      }
    );
  }

private:
  void mouseMoveEvent(QMouseEvent* const e) final
  {
    if (Qt::LeftButton & e->buttons())
    {
      move(QCursor::pos() + p_);
    }
  }

  void mousePressEvent(QMouseEvent* const e) final
  {
    if (Qt::LeftButton == e->button())
    {
      p_ = -e->pos();
    }
  }

/*
  void resizeEvent(QResizeEvent*) final
  {
    clearMask();
    QImage image(size(), QImage::Format_Alpha8);
    render(&image);
    setMask(QBitmap::fromImage(image.createMaskFromColor(qRgba(0, 0, 0, 0))));
  }
*/
};

//////////////////////////////////////////////////////////////////////////////
int main(int argc, char* argv[])
{
  QApplication app(argc, argv);

  MyWidget w;
  w.show();

  return app.exec();
}
