#include "musicplayer.h"
#include <QAudioBuffer>

MusicPlayer::MusicPlayer(QObject *parent)
    : QMediaPlayer{parent}
{
    connect(this, &QMediaPlayer::mediaStatusChanged, this, &MusicPlayer::handleMediaStatusChanged);
}

QStringList MusicPlayer::getSongList() const
{
    return m_songList;
}

void MusicPlayer::setSongList(const QStringList &newSongList)
{
    if (m_songList == newSongList)
        return;
    m_songList = newSongList;
    QString song;
    foreach (song, m_songList) {
        m_songNameList << getSongName(song);
    }
    emit songListChanged();
}

QString MusicPlayer::getCurrentSong() const
{
    return m_currentSong;
}

void MusicPlayer::setCurrentSong(const QString &newCurrentSong)
{
    if (m_currentSong == newCurrentSong)
        return;
    m_currentSong = newCurrentSong;
    emit currentSongChanged();
}

QString MusicPlayer::getSongName(const QString &songUrl)
{
    QString songName = songUrl;
    int pos = songName.lastIndexOf(QChar('/'));
    songName.remove(0, pos+1);
    songName.remove(".mp3");
    songName.remove(".m4a");
    return songName;
}

QStringList MusicPlayer::getSongNameList() const
{
    return m_songNameList;
}

void MusicPlayer::setSongNameList(const QStringList &newSongNameList)
{
    if (m_songNameList == newSongNameList)
        return;
    m_songNameList = newSongNameList;
    emit songNameListChanged();
}

void MusicPlayer::handleCurrentSongChanged(const int &newSongIndex)
{
    setMedia(QUrl::fromLocalFile(m_songList[newSongIndex]));
    setCurrentSong(getSongName(m_songList[newSongIndex]));
}

void MusicPlayer::handleMediaStatusChanged(QMediaPlayer::MediaStatus status)
{
    if(status == QMediaPlayer::LoadedMedia)
    {
        qInfo() << "GetMetaData";
    }

    if (duration() != 0) {
        emit currentSongDurationChanged(duration());
    }
}

void MusicPlayer::handleCurrentPositionChanged(const int &newPos)
{
    int songDuration = duration();
    qint64 setPos = (newPos*songDuration)/400;
    setPosition(setPos);
}

void MusicPlayer::handleVolumeAdjusted(const int &newVolume)
{
    setVolume(newVolume);
}
