#!/bin/sh
#######
#up.sh#
#######

source kolory.sh
initializeANSI

katalog=($HOME'/BACKUP/ZIM')
if [ ! -d $katalog ]; then
mkdir -p $katalog
fi

DATE=$(date +%Y-%m-%d-%H-%M-%S)
archiwum=('archiwum_zima_'$DATE'.tar.gz')

echo -e $yellowf'Archiwizuję dane...'$reset
tar -zcf ~/BACKUP/ZIM/$archiwum ~/Notebooks 2>/dev/null
flaga01=$?

if [ $flaga01 -eq 0 ]
then
echo -e $greenf'Proces archiwizacji danych zakończony sukcesem.'$reset
else
echo -e $redf'Błąd. Nie wykonano procesu archiwizacji danych.'$reset
echo -e $redf'Przerywam wykonywanie skryptu.'$reset
exit 1
fi

echo -e $yellowf'Szyfruję dane...'$reset
dane=($archiwum'.gpg')
gpg2 --output ~/BACKUP/ZIM/$dane -r marcin.piotrowski --encrypt ~/BACKUP/ZIM/$archiwum 2>/dev/null
flaga02=$?

if [ $flaga02 -eq 0 ]
then
echo -e $greenf'Proces szyfrowania danych zakończony sukcesem.'$reset
else
echo -e $redf'Błąd. Nie wykonano procesu szyfrowania danych.'$reset
echo -e $redf'Przerywam wykonywanie skryptu.'$reset
exit 2
fi

rclone ls google:/backup/zim/ 2>/dev/null 1>/dev/null
flaga03=$?

if [ $flaga03 -eq 3 ]
then
rclone mkdir google:/backup/zim/
echo -e $greenf'Uworzyłem katalog /backup/zim/'$reset
fi

echo -e $yellowf'Wysyłam dane do chmury...'$reset
rclone copy ~/BACKUP/ZIM/$dane google:/backup/zim/ 2>/dev/null
flaga04=$?

if [ $flaga04 -eq 0 ]
then
echo -e $greenf'Wysłanie danych do chmury zakończone sukcesem.'$reset
else
echo -e $redf'Błąd. Nie wykonano procesu wysłania danych do chmury.'$reset
echo -e $redf'Przerywam wykonywanie skryptu.'$reset
exit 3
fi

echo -e $greenf'KONIEC'$reset
