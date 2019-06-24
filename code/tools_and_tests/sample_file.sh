INPUT_DATA=$1
N=$2
OUTPUT_DATA=$3

# get header record
head -n 1 ${INPUT_DATA} > ${OUTPUT_DATA}
echo "Created header record..."

# sample using gshuf (append)
gshuf -n ${N} ${INPUT_DATA} >> ${OUTPUT_DATA}
echo "Created ${N} sample records ..."
echo "Saved to ${OUTPUT_DATA}"
