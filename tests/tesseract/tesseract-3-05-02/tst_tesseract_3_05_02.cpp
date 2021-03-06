#include <QtTest>
#include <QCoreApplication>
#include <QFile>

#include "utils.h"

#include "tesseract/baseapi.h"
#include "leptonica/allheaders.h"

class tesseract_3_05_02 : public QObject
{
    Q_OBJECT

public:
    tesseract_3_05_02();
    ~tesseract_3_05_02();

private slots:
    void initTestCase();
    void cleanupTestCase();
    void test_getUTF8Text();

#ifdef BENCHMARKS
    void benchmark_getUTF8Text();
#endif

private:
  Pix *m_image;
  tesseract::TessBaseAPI *m_tess;
  char *m_text;
};

tesseract_3_05_02::tesseract_3_05_02()
{
}

tesseract_3_05_02::~tesseract_3_05_02()
{
}

void tesseract_3_05_02::initTestCase()
{
  QString image_path = Utils::migrateAsset("assets:/phototest.tif");
  QVERIFY2(image_path != "", "phototest.tif not migrated");

  m_image = pixRead(image_path.toStdString().c_str());

  QVERIFY2(m_image != nullptr, "Failed to create PIX* from image data.");

  m_tess = new tesseract::TessBaseAPI();
  QVERIFY2(m_tess != nullptr, "Failed to create new tesseract::TessBaseAPI.");

  QString tessdata_path =
          Utils::migrateAsset("assets:/tessdata/eng.traineddata").
          remove("tessdata/eng.traineddata");

  QVERIFY2(m_tess->Init(tessdata_path.toStdString().c_str(), "eng") != -1,
           "Failed to initialize Tesseract.");
}

void tesseract_3_05_02::cleanupTestCase()
{
  delete [] m_text;
  m_tess->End();
  pixDestroy(&m_image);
}

void tesseract_3_05_02::test_getUTF8Text()
{
  // Note the misdetection in the first line here vs. 3.02; 'ocr' vs. 'cor'.
  // 3.02: ... to test the\nocr code ...
  // 3.05: ... to test the\ncor code ...
  QString expected("This is a lot of 12 point text to test the\ncor code and " \
                   "see if it works on all types\nof file format.\n\nThe " \
                   "quick brown dog jumped over the\nlazy fox. The quick " \
                   "brown dog jumped\nover the lazy fox. The quick brown " \
                   "dog\njumped over the lazy fox. The quick\nbrown dog " \
                   "jumped over the lazy fox.\n\n");

  m_tess->SetImage(m_image);
  m_text = m_tess->GetUTF8Text();
  QString actual = QString(m_text);

  QCOMPARE(actual, expected);
}

#ifdef BENCHMARKS
void tesseract_3_05_02::benchmark_getUTF8Text()
{
  qint64 iterations = 10;
  qint64 t0 = 0;
  qint64 t1 = 0;

  QElapsedTimer timer;
  timer.start();

  for(qint64 i = 0; i < iterations; ++i)
  {
    m_tess->SetImage(m_image);
    t0 += timer.restart();

    m_tess->GetUTF8Text();
    t1 += timer.restart();
  }

  qDebug() << "\tAverage duration:\n";
  qDebug() << "\t  SetImage:" << t0 / iterations << "ms";
  qDebug() << "\t  GetUTF8Text:" << t1 / iterations << "ms";
}
#endif

QTEST_MAIN(tesseract_3_05_02)

#include "tst_tesseract_3_05_02.moc"
