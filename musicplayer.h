#ifndef MUSICPLAYER_H
#define MUSICPLAYER_H

#include <QMediaPlayer>
#include <QObject>

class MusicPlayer : public QMediaPlayer
{
    Q_OBJECT
public:
    explicit MusicPlayer(QObject *parent = nullptr);

    // getter and setter
    QStringList getSongList() const;
    void setSongList(const QStringList &newSongList);
    QString getCurrentSong() const;
    void setCurrentSong(const QString &newCurrentSong);
    QStringList getSongNameList() const;
    void setSongNameList(const QStringList &newSongNameList);

    // parse url to get song name
    QString getSongName(const QString &songUrl);

signals:
    void songListChanged();
    void currentSongChanged();
    void songNameListChanged();
    void currentSongDurationChanged(int data);

public slots:
    void handleCurrentSongChanged(const int &newSongIndex);
    void handleMediaStatusChanged(QMediaPlayer::MediaStatus status);
    void handleCurrentPositionChanged(const int &newPos);
    void handleVolumeAdjusted(const int &newVolume);

private:
    QStringList m_songNameList;
    QStringList m_songList;
    QString m_currentSong;
    Q_PROPERTY(QStringList songList READ getSongList WRITE setSongList NOTIFY songListChanged)
    Q_PROPERTY(QString currentSong READ getCurrentSong WRITE setCurrentSong NOTIFY currentSongChanged)
    Q_PROPERTY(QStringList songNameList READ getSongNameList WRITE setSongNameList NOTIFY songNameListChanged)
};

#endif // MUSICPLAYER_H
