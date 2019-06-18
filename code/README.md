# Source Code
This directory contains source code written to perform various pre-processing and analysis steps for the HAC project.

## Notebooks
Notebooks are R Markdown (`*.Rmd`) files that contain code 'blocks' and integrated human readable text.

## Scripts
Scripts are files (`*.R`) that can be used in various different notebooks. The functions in these scripts can be called into a workspace or notebook using the following line:

```
source([function_file_name].R)
```

## SenseDetection

SenseDetection is a wrapper for the open source project: Clinical Abbreviation Recognition and Disambiguation (CARD), available here https://sbmi.uth.edu/ccb/resources/abbreviation.htm. This directory contains modified file I/O methods in the class [SenseDisambiguationText](TightClusteringSenseDetection/bin/MetaMapWrapper/SenseDisambiguationText.class) and is published here with permission from the authors. `SenseDisambiguationText.class` was re-interpreted in order to facilitate input streams from `stdin` and `stdout` to enable piping of bytes from memory instead of from disk. Further, the file resources were moved to command-line arguments to facilitate easier access to these resources. The resources provided by CARD via the initial download are available in the `card_resources` directory.

### Usage:
The `TightSenseClustering.jar` file can be used in the following manner:

```
[pipe input from stdin] | java -jar TightSenseClustering.jar \
      [word_file] \
      [abbreviation_file] \
      [profile_directory] \
      [cui_file]

```

A simple example can be seen by running `./test_jar.sh.`


### MetaMapWrapper Modifications

There are two main differences in this implementation of CARD. First, the data streams are expected from `stdin` and printed to `stdout`. The `SenseDisambiguationText` class file was rewritten with the following input stream method:


```java
Scanner input = new Scanner(System.in);
java.lang.String content = "";

while (input.hasNext()) {
  String line = input.nextLine().toString();
  content = (new StringBuilder(java.lang.String.valueOf(((java.lang.Object) (content))))).append(line).append("\n").toString();
}

disambiguation.parse_file(content);
```

This replaces the original mechanism in `SenseDisambiguationText.parse_file()`

```java
final BufferedReader infile = new BufferedReader(new FileReader(infilename));
```

Further, this modification calls the 'parse' method on the input stream directly, as opposed to reading through a directory. Output is reformatted in the `parse_input()` as follows:

```java
public int parse_file(java.lang.String content)
{
  MetaMapWrapper.Document doc = new Document(content, infilename);
  sb.detect_boundaries(doc);
  doc.break_long_sentence();
  java.lang.String ret = "";
  java.lang.String as[];
  int j = (as = doc.boundary_norm_str().split("\n")).length;
  for(int i = 0; i < j; i++)
  {
      java.lang.String sentence = as[i];

      System.out.println("BEGIN_SENTENCE:");
      System.out.println(sentence.toString());
      System.out.print(parse_sentence(sentence).toString());
      System.out.println("END_SENTENCE." );
  }
    return 0;
}
```

Second, the resource files are expected via command-line arguments. This enables more portability and testing on using different lexical resources.

```java
public static void main(final java.lang.String[] argv) {

    final int arg_len = argv.length;
    final String message = "Incorrect input options. Epected: 0:word_map_file, 1:abbr_map_file, 2:profile_dir, 3:cui_file ";
    if (arg_len != 4) {
        System.out.println(message);
        System.exit(-1);
    }

    final String word_map_file = argv[0];
    final String abbr_map_file = argv[1];
    final String profile_dir = argv[2];
    final String cui_file = argv[3];

    /// ....ect.... ///
  }

```

### SenseDetection Citations:

1. Wu Y, Rosenbloom ST, Denny JC, Miller RA, Mani S, Giuse DA, Xu H. Detecting abbreviations in discharge summaries using machine learning methods. AMIA Annu Symp Proc. 2011, 1541-9. [PMCID: PMC3243185]
1. yonghuiwu / card — Bitbucket [Internet]. [cited 2019 Jun 12]. Available from: https://bitbucket.org/yonghuiwu/card/src/master/
1. Wu Y, Denny JC, Trent Rosenbloom S, Miller RA, Giuse DA, Wang L, et al. A long journey to short abbreviations: developing an open-source framework for clinical abbreviation recognition and disambiguation (CARD). J Am Med Inform Assoc. 2017 Apr 1;24(e1):e79–86.
1. Wu Y, Rosenbloom ST, Denny JC, Miller RA, Mani S, Giuse DA, et al. Detecting Abbreviations in Discharge Summaries using Machine Learning Methods. AMIA Annu Symp Proc. 2011;2011:1541–9.
1. Xu H, Stetson PD, Friedman C. Methods for Building Sense Inventories of Abbreviations in Clinical Notes. J Am Med Inform Assoc. 2009 Jan 1;16(1):103–8.

## Testing
There are a number of bash tests (files ending in `.sh`) in this dir.

## Template
The [TEMPLATE](template.Rmd) notebook is to ensure all analysis is formatted consistently.
