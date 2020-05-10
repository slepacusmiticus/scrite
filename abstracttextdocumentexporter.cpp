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

#include "abstracttextdocumentexporter.h"

AbstractTextDocumentExporter::AbstractTextDocumentExporter(QObject *parent)
    :AbstractExporter(parent)
{

}

AbstractTextDocumentExporter::~AbstractTextDocumentExporter()
{

}

void AbstractTextDocumentExporter::setListSceneCharacters(bool val)
{
    if(m_listSceneCharacters == val)
        return;

    m_listSceneCharacters = val;
    emit listSceneCharactersChanged();
}

void AbstractTextDocumentExporter::generate(QTextDocument *textDoc, const qreal pageWidth)
{
    // Refer to the following link to know about the standard formatting rules
    // https://screenwriting.io/what-is-standard-screenplay-format/

    const ScreenplayFormat *screenplayFormat = this->document()->printFormat();
    const Screenplay *screenplay = this->document()->screenplay();
    const int nrScreenplayElements = screenplay->elementCount();

    const QFont defaultFont = screenplayFormat->defaultFont();

    QTextDocument &textDocument = *textDoc;

    textDocument.setDefaultFont(defaultFont);
    textDocument.setProperty("#title", screenplay->title());
    textDocument.setProperty("#subtitle", screenplay->subtitle());
    textDocument.setProperty("#author", screenplay->author());
    textDocument.setProperty("#contact", screenplay->contact());
    textDocument.setProperty("#version", screenplay->version());

    QTextCursor cursor(&textDocument);

    // Title Page
    {
        // Title
        {
            QTextBlockFormat blockFormat;
            blockFormat.setAlignment(Qt::AlignHCenter);
            blockFormat.setBottomMargin(100);

            QTextCharFormat charFormat;
            charFormat.setFontFamily(defaultFont.family());
            charFormat.setFontPointSize(36);

            cursor.setBlockFormat(blockFormat);
            cursor.setCharFormat(charFormat);

            QString title = screenplay->title();
            if(title.isEmpty())
                title = "Untitled Screenplay";
            cursor.insertText(title);
            if(!screenplay->subtitle().isEmpty())
            {
                cursor.insertText(" - ");
                cursor.insertText(screenplay->subtitle());
            }
        }

        // Author
        {
            QTextBlockFormat blockFormat;
            blockFormat.setAlignment(Qt::AlignHCenter);

            QTextCharFormat charFormat;
            charFormat.setFontFamily(defaultFont.family());
            charFormat.setFontPointSize(defaultFont.pointSize());

            cursor.insertBlock();
            cursor.setBlockFormat(blockFormat);
            cursor.setCharFormat(charFormat);

            QString author = screenplay->author();
            if(author.isEmpty())
                author = "Unknown Author";
            cursor.insertText(author);
        }

        // Contact
        {
            QTextBlockFormat blockFormat;
            blockFormat.setAlignment(Qt::AlignHCenter);

            QTextCharFormat charFormat;
            charFormat.setFontFamily(defaultFont.family());
            charFormat.setFontPointSize(defaultFont.pointSize());

            cursor.insertBlock();
            cursor.setBlockFormat(blockFormat);
            cursor.setCharFormat(charFormat);

            QString contact = screenplay->contact();
            if(contact.isEmpty())
                contact = "No Contact Information";
            cursor.insertText(contact);
        }

        // Version
        {
            QTextBlockFormat blockFormat;
            blockFormat.setAlignment(Qt::AlignHCenter);

            QTextCharFormat charFormat;
            charFormat.setFontFamily(defaultFont.family());
            charFormat.setFontPointSize(defaultFont.pointSize());

            cursor.insertBlock();
            cursor.setBlockFormat(blockFormat);
            cursor.setCharFormat(charFormat);

            QString version = screenplay->version();
            if(version.isEmpty())
                version = "First Version";
            cursor.insertText("Version: " + version);
        }

        // Generator
        {
            QTextBlockFormat blockFormat;
            blockFormat.setAlignment(Qt::AlignHCenter);
            blockFormat.setTopMargin(100);

            QTextCharFormat charFormat;
            charFormat.setFontFamily(defaultFont.family());
            charFormat.setFontPointSize(9);

            cursor.insertBlock();
            cursor.setBlockFormat(blockFormat);
            cursor.setCharFormat(charFormat);
            cursor.insertHtml("This screenplay was generated using <strong>scrite</strong><br/>(<a href=\"https://www.scrite.io\">https://www.scrite.io</a>)");
        }

        cursor.insertBlock();
    }

    int nrBlocks = 0, nrSceneHeadings=0;
    auto createNewTextBlock = [&nrBlocks,pageWidth,screenplayFormat](QTextCursor &cursor, SceneElement::Type type) {
        const SceneElementFormat *format = screenplayFormat->elementFormat(type);
        QTextBlockFormat blkFormat = format->createBlockFormat(&pageWidth);
        if(nrBlocks == 0)
            blkFormat.setPageBreakPolicy(QTextFormat::PageBreak_AlwaysBefore);

        QTextCharFormat chrFormat = format->createCharFormat(&pageWidth);

        if(nrBlocks > 0)
            cursor.insertBlock(blkFormat, chrFormat);
        else {
            cursor.setBlockFormat(blkFormat);
            cursor.setCharFormat(chrFormat);
        }
    };

    for(int i=0; i<nrScreenplayElements; i++)
    {
        const ScreenplayElement *screenplayElement = screenplay->elementAt(i);
        if(screenplayElement->elementType() != ScreenplayElement::SceneElementType)
            continue;

        const Scene *scene = screenplayElement->scene();
        const int nrSceneElements = scene->elementCount();

        // Scene heading
        SceneHeading *heading = scene->heading();
        if(heading->isEnabled())
        {
            ++nrSceneHeadings;
            const QString sceneNr = QString("[%1] ").arg(nrSceneHeadings);
            createNewTextBlock(cursor,SceneElement::Heading);
            // cursor.insertText(sceneNr + heading->text());
            TransliterationEngine::instance()->evaluateBoundariesAndInsertText(cursor, sceneNr + heading->text());

            ++nrBlocks;
        }

        // Characters in the scene.
        const QStringList characterNames = scene->characterNames();
        if(m_listSceneCharacters && !characterNames.isEmpty())
        {
            SceneElementFormat *format = screenplayFormat->elementFormat(SceneElement::Action);
            const QTextBlockFormat blockFormat = format->createBlockFormat();
            QTextCharFormat charFormat = format->createCharFormat();
            charFormat.setBackground(QBrush(QColor("yellow")));
            cursor.insertBlock(blockFormat, charFormat);
            cursor.insertText("{ " + characterNames.join(", ") + " }");
        }

        for(int j=0; j<nrSceneElements; j++)
        {
            SceneElement *element = scene->elementAt(j);
            createNewTextBlock(cursor, element->type());
            // cursor.insertText(element->formattedText());
            TransliterationEngine::instance()->evaluateBoundariesAndInsertText(cursor, element->formattedText());

            ++nrBlocks;
        }
    }
}
