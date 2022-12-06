/****************************************************************************
**
** Copyright (C) VCreate Logic Pvt. Ltd. Bengaluru
** Author: Prashanth N Udupa (prashanth@scrite.io)
**
** This code is distributed under GPL v3. Complete text of the license
** can be found here: https://www.gnu.org/licenses/gpl-3.0.txt
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/

#include "textlimiter.h"
#include <QTextBoundaryFinder>

TextLimiter::TextLimiter(QObject *parent) : QObject { parent }
{
    connect(this, &TextLimiter::modeChanged, this, &TextLimiter::limitText);
    connect(this, &TextLimiter::maxWordCountChanged, this, &TextLimiter::limitText);
    connect(this, &TextLimiter::maxLetterCountChanged, this, &TextLimiter::limitText);
    connect(this, &TextLimiter::textChanged, this, &TextLimiter::limitText);
}

TextLimiter::~TextLimiter() { }

void TextLimiter::setMode(Mode val)
{
    if (m_mode == val)
        return;

    m_mode = val;
    emit modeChanged();
}

void TextLimiter::setMaxWordCount(int val)
{
    if (m_maxWordCount == val)
        return;

    m_maxWordCount = qMax(0, val);
    emit maxWordCountChanged();
}

void TextLimiter::setMaxLetterCount(int val)
{
    if (m_maxLetterCount == val)
        return;

    m_maxLetterCount = qMax(0, val);
    emit maxLetterCountChanged();
}

void TextLimiter::setText(const QString &val)
{
    if (m_text == val)
        return;

    m_text = val;
    emit textChanged();
}

void TextLimiter::setWordCount(int val)
{
    if (m_wordCount == val)
        return;

    m_wordCount = val;
    emit wordCountChanged();
}

void TextLimiter::setLetterCount(int val)
{
    if (m_letterCount == val)
        return;

    m_letterCount = val;
    emit letterCountChanged();
}

void TextLimiter::setLimitedText(const QString &val)
{
    if (m_limitedText == val)
        return;

    m_limitedText = val;
    emit limitedTextChanged();
}

void TextLimiter::setLimitReached(bool val)
{
    if (m_limitReached == val)
        return;

    m_limitReached = val;
    emit limitReachedChanged();
}

void TextLimiter::limitText()
{
    auto finishingIndexOfBoundary = [](QTextBoundaryFinder::BoundaryType type, const QString &text,
                                       int count) {
        QTextBoundaryFinder boundaryFinder(type, text);
        int counter = 0;
        int ret = -1;
        while (boundaryFinder.position() < text.length()) {
            if (boundaryFinder.boundaryReasons().testFlag(QTextBoundaryFinder::StartOfItem))
                ++counter;
            ret = boundaryFinder.toNextBoundary();
            if (ret < 0 || counter == count)
                break;
        }
        return ret < 0 ? text.length() - 1 : ret;
    };

    auto boundaryCount = [](QTextBoundaryFinder::BoundaryType type, const QString &text) {
        QTextBoundaryFinder boundaryFinder(type, text);
        int counter = 0;
        while (boundaryFinder.position() < text.length()) {
            if (boundaryFinder.boundaryReasons().testFlag(QTextBoundaryFinder::StartOfItem))
                ++counter;
            if (boundaryFinder.toNextBoundary() < 0)
                break;
        }
        return counter;
    };

    const QString simplifiedText = m_text.simplified();
    if (simplifiedText.isEmpty()) {
        this->setLimitedText(simplifiedText);
        this->setWordCount(0);
        this->setLetterCount(0);
        this->setLimitReached(false);
        return;
    }

    QString ltext = simplifiedText;
    if (m_maxWordCount > 0 && (m_mode == LowerOfWordAndLetterCount || m_mode == MatchWordCountOnly))
        ltext = ltext.left(
                finishingIndexOfBoundary(QTextBoundaryFinder::Word, ltext, m_maxWordCount));

    if (m_maxLetterCount > 0
        && (m_mode == LowerOfWordAndLetterCount || m_mode == MatchLetterCountOnly))
        ltext = ltext.left(
                finishingIndexOfBoundary(QTextBoundaryFinder::Grapheme, ltext, m_maxLetterCount));

    const int wcount = boundaryCount(QTextBoundaryFinder::Word, ltext);
    const int lcount = boundaryCount(QTextBoundaryFinder::Grapheme, ltext);

    this->setLimitedText(ltext);
    this->setWordCount(wcount);
    this->setLetterCount(lcount);
    this->setLimitReached(simplifiedText != m_text);
}
