#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QMediaPlayer>
#include <QQmlContext>
#include <QMediaMetaData>
#include <QDebug>
#include <QDir>

#include "musicplayer.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    // Declare the player model
    MusicPlayer* player = new MusicPlayer;
    player->setVolume(50);

    // Read the playlist from ../qtmediaplayer/music
    QDir dir("../qtmediaplayer/music");
    QStringList filenamelist = dir.entryList(QStringList() << "*.mp3" << "*.MP3", QDir::Files); // This give us filenames
    // Playlist contains urls
    QStringList playlist;
    QString tempstr;
    foreach (tempstr, filenamelist) {
        playlist << dir.filePath(tempstr);
        qInfo() << "Importing" << tempstr;
    }
    player->setSongList(playlist);

    // Create the QQml application engine
    QQmlApplicationEngine engine;

    // Set context property to connect with models in QML
    engine.rootContext()->setContextProperty("playerModel", player);

    // Run the QQml application engine
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
                &engine,
                &QQmlApplicationEngine::objectCreated,
                &app,
                [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    },
    Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
