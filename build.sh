mkdir -p studio-data/profile/AndroidStudio2024.2.1.11 || exit
mkdir -p studio-data/Android || exit
mkdir -p studio-data/profile/.android || exit
mkdir -p studio-data/profile/.java || exit
mkdir -p studio-data/profile/.gradle || exit
docker build -t deadolus/android-studio-2024.2.1.11 . || exit
