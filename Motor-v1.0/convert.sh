#FILENAME=synchro

find -name \*.tla -printf %f\\n | while read FILENAME
do
java tlatex.TLA -shade $FILENAME
done

find -name \*.tex -print | while read FILENAME
do
pdflatex $FILENAME
done

rm *.dvi
rm *.log
rm *.tex
rm *.aux
rm *.ps
