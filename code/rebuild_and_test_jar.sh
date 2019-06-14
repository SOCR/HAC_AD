rm sense_detection.jar
echo 'removed old sense_detection.jar'
jar cmf MANIFEST.MF sense_detection.jar SenseDetection/
echo 'compiled to sense_detection.jar with manifest:'
cat ./MANIFEST.MF
echo 'testing'
echo "the pt walked along the riverbed. For three h they did things." | java -jar sense_detection.jar \
    card_resources/word.txt \
    card_resources/abbr.txt \
    card_resources/profile/ \
    card_resources/VABBR_DS_beta.txt.add_semantic_type
