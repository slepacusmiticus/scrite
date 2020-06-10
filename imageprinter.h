/****************************************************************************
**
** Copyright (C) TERIFLIX Entertainment Spaces Pvt. Ltd. Bengaluru
** Author: Prashanth N Udupa (prashanth.udupa@teriflix.com)
**
** This code is distributed under GPL v3. Complete text of the license
** can be found here: https://www.gnu.org/licenses/gpl-3.0.txt
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/

#ifndef PRINTTOIMAGE_H
#define PRINTTOIMAGE_H

#include <QObject>
#include <QReadWriteLock>
#include <QQmlParserStatus>
#include <QPagedPaintDevice>
#include <QQuickImageProvider>

#include "modifiable.h"
#include "qtextdocumentpagedprinter.h"

class ImagePrinterEngine;
class ImagePrinter : public QAbstractListModel,
                     public QPagedPaintDevice,
                     public QQmlParserStatus,
                     public Modifiable
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)

public:
    ImagePrinter(QObject *parent=nullptr);
    ~ImagePrinter();
    Q_SIGNAL void aboutToDelete(ImagePrinter *ptr);

    Q_PROPERTY(HeaderFooter* header READ header CONSTANT)
    HeaderFooter* header() const { return m_header; }

    Q_PROPERTY(HeaderFooter* footer READ footer CONSTANT)
    HeaderFooter* footer() const { return m_footer; }

    Q_PROPERTY(Watermark* watermark READ watermark CONSTANT)
    Watermark *watermark() const { return m_watermark; }

    void setHeaderFooterFields(const QMap<HeaderFooter::Field,QString> &fields) { m_headerFooterFields = fields; }
    void clearHeaderFooterFields() { m_headerFooterFields.clear(); }
    QMap<HeaderFooter::Field,QString> headerFooterFields() const { return m_headerFooterFields; }

    Q_PROPERTY(QString directory READ directory WRITE setDirectory NOTIFY directoryChanged)
    void setDirectory(const QString &val);
    QString directory() const { return m_directory; }
    Q_SIGNAL void directoryChanged();

    enum ImageFormat { PNG, JPEG };
    Q_ENUM(ImageFormat)
    Q_PROPERTY(ImageFormat imageFormat READ imageFormat WRITE setImageFormat NOTIFY imageFormatChanged)
    void setImageFormat(ImageFormat val);
    ImageFormat imageFormat() const { return m_imageFormat; }
    Q_SIGNAL void imageFormatChanged();

    Q_PROPERTY(qreal scale READ scale WRITE setScale NOTIFY scaleChanged)
    void setScale(qreal val);
    qreal scale() const { return m_scale; }
    Q_SIGNAL void scaleChanged();

    Q_PROPERTY(int pageCount READ pageCount NOTIFY pagesChanged)
    int pageCount() const { return m_pageImages.size(); }
    Q_SIGNAL void pagesChanged();

    Q_PROPERTY(qreal pageWidth READ pageWidth NOTIFY pagesChanged)
    qreal pageWidth() const { return qMax(m_pageSize.width(),1); }

    Q_PROPERTY(qreal pageHeight READ pageHeight NOTIFY pagesChanged)
    qreal pageHeight() const { return qMax(m_pageSize.height(),1); }

    QImage pageImageAt(int index); // this function is non-const on purpose.
    Q_INVOKABLE QString pageUrl(int index) const;

    Q_INVOKABLE void clear();

    Q_PROPERTY(bool printing READ isPrinting WRITE setPrinting NOTIFY printingChanged)
    void setPrinting(bool val);
    bool isPrinting() const { return m_printing; }
    Q_SIGNAL void printingChanged();

    // QAbstractItemModel interface
    enum Roles { PageUrlRole = Qt::UserRole, PageWidthRole, PageHeightRole };
    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int,QByteArray> roleNames() const;

public:
    // QPaintDevice interface
    int devType() const;
    QPaintEngine *paintEngine() const;

protected:
    int metric(PaintDeviceMetric metric) const;
    void initPainter(QPainter *painter) const;
    QPaintDevice *redirected(QPoint *offset) const;
    QPainter *sharedPainter() const;

public:
    // QPagedPaintDevice interface
    bool newPage();
    void setPageSize(PageSize size);
    void setPageSizeMM(const QSizeF &size);
    void setMargins(const Margins &margins);

protected:
    // QQmlParserStatus implementation
    void classBegin();
    void componentComplete();

private:
    void begin();
    void end();
    void capturePrintedPageImage();

private:
    friend class ImagePrinterEngine;
    qreal m_scale = 1.0;
    bool m_printing = false;
    QSize m_pageSize;
    QString m_directory;
    ImageFormat m_imageFormat = PNG;
    QList<QImage> m_pageImages;
    QReadWriteLock m_pageImagesLock;
    mutable QImage m_templatePageImage;
    mutable ImagePrinterEngine *m_engine = nullptr;

    HeaderFooter* m_header = new HeaderFooter(HeaderFooter::Header, this);
    HeaderFooter* m_footer = new HeaderFooter(HeaderFooter::Footer, this);
    Watermark *m_watermark = new Watermark(this);
    QMap<HeaderFooter::Field,QString> m_headerFooterFields;
};

#endif // PRINTTOIMAGE_H
